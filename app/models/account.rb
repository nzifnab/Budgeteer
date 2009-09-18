class Account < ActiveRecord::Base
  belongs_to :prerequisite, :class_name => "Account"
  belongs_to :overflow_into, :class_name => "Account"
  belongs_to :user
  has_many :account_histories
  validates_presence_of :name, :priority, :add_per_month, :user_id
  validates_presence_of :cap, :if => Proc.new{ |account| account.has_cap }, :message => "is required with 'Has a Cap' selected"
  validates_presence_of :prerequisite_id, :if => Proc.new{ |account| account.has_prerequisite }, :message => "is required if 'Has Prerequisite' is selected"
  validates_presence_of :overflow_into_id, :if => Proc.new{ |account| account.does_overflow }, :message => "is required if 'Does Overflow' is selected"
  validates_numericality_of :add_per_month, :unless => Proc.new { |account| account.add_per_month_as_percent == true }
  validates_numericality_of :add_per_month, :less_than_or_equal_to => 100, :message => "cannot be greater than 100%", :if => Proc.new { |account| account.add_per_month_as_percent == true }
  validates_numericality_of :cap, :allow_nil => true
  validates_uniqueness_of :name, :scope => :user_id, :message => "already exists on one of your accounts."
  
  def self.priority_options
    [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
  end
  
  def initialize(attributes = {})
    if attributes["has_cap"] == false || attributes["has_cap"] == "0"
      @has_cap = false
      attributes["cap"] = nil
    elsif attributes["has_cap"] == true || attributes["has_cap"] == "1"
      @has_cap = true
      if !attributes["cap"]
        attributes["cap"] = 0
      end
    end
    
    if attributes["has_prerequisite"] == false || attributes["has_prerequisite"] == "0"
      @has_prerequisite = false
      attributes["prerequisite_id"] = nil
    elsif attributes["has_prerequisite"] == true || attributes["has_prerequisite"] == "1"
      @has_prerequisite = true
    end
    
    if attributes["does_overflow"] == false || attributes["does_overflow"] == "0"
      @does_overflow = false
      attributes["overflow_into_id"] = nil
    elsif attributes["does_overflow"] == true || attributes["does_overflow"] == "1"
      @does_overflow = true
    end
    
    super(attributes)
  end
  
  def distribute!(given_amount, income, priority_start_amount, prereq_left = nil)
    this_left = prereq_left
    if self.should_distribute?
      amt = distribute_use_amount(given_amount, priority_start_amount, prereq_left)

      if amt > 0
        self.amount = self.amount + amt
        self.save
        history = AccountHistory.create!( :amount => amt, :account_id => self.id, :income_id => income.id, :description => income.description )
        
        given_amount -= amt
        
        if self.has_reached_cap?
          this_left = amount_to_use(priority_start_amount) - amt
          if prereq_left
            this_left = prereq_left - this_left
          end
          
          if this_left > 0
            if self.does_overflow?
              amt_left = self.overflow_into.distribute_as_overflow!(this_left, income)
              given_amount -= (this_left - amt_left)
              this_left = amt_left
            end
            
            if this_left > 0
              prereqs_fullfilled_accounts = Account.find( :all, :conditions => ["user_id = ? AND enabled = true AND prerequisite_id = ? AND priority <= ?", self.user, self.id, self.priority ], :order => "`priority` ASC, `add_per_month_as_percent` DESC" )
            
              prereqs_fullfilled_accounts.each do |prereqqed_account|
                returned = prereqqed_account.distribute!(given_amount, income, priority_start_amount, this_left)
                given_amount = returned[:given_amount]
                this_left = returned[:this_left]
              end
            end
          end
        end
      end
    end
    if prereq_left
      return {:given_amount => given_amount, :this_left => this_left}
    else
      return given_amount
    end
  end
  
  def distribute_as_overflow!(amt, income)
    amt = (amt < 0 ? 0 : amt)
    amount_left = amt
    changed = 0
    
    if self.has_cap?
      cap_amt = (self.amount_till_cap < 0 ? 0 : self.amount_till_cap)
      if amt <= cap_amt
        self.amount = self.amount + amt
        self.save
        changed = amt
      else
        self.amount = self.amount + cap_amt
        self.save
        changed = cap_amt
      end
    else
      self.amount = self.amount + amt
      self.save
      changed = amt
    end
    
    if changed != 0
      amount_left -= changed
      history = AccountHistory.create!( :amount => changed, :account_id => self.id, :income_id => income.id, :description => (income.description + " overflow") )
    end
    
    return amount_left
  end
  
  def has_reached_cap?
    return self.has_cap? && self.amount >= self.cap
  end
  
  def distribute_use_amount(given_amount, priority_start_amount, prereq_left = nil, amount_for_overflow = false)
    use_amt = amount_to_use(priority_start_amount)
    amts = [given_amount, use_amt, amount_for_overflow ? nil : amount_till_cap, amount_for_overflow ? nil : amount_till_add_per_month, prereq_left].
    map {|amt|
      if amt && amt < 0
        0
      else
        amt
      end
    }
    
    amts.delete(nil)
    
    return amts.min
  end
  
  def should_distribute?
    return (self.enabled && ((self.has_prerequisite? && self.prerequisite.amount >= self.prerequisite.cap) || !self.has_prerequisite?))
  end
  
  def amount
    super || 0
  end
  
  def amount_till_add_per_month
    if !self.add_per_month_as_percent
      month_account_histories = AccountHistory.find(:all, :conditions => [ "`account_id` = ? AND `amount` > ? AND MONTH(`created_at`) = ? AND `income_id` IS NOT NULL", id, 0, Date.today.month ])
      
      month_used = month_account_histories. 
      map {|account_history| account_history.amount}.
      inject {|sum,amount| (sum || 0) + (amount || 0)}
      
      self.add_per_month - (month_used || 0)
    else
      nil
    end
  end
  
  def amount_to_use(amt)
    if self.add_per_month_as_percent
      amt * (self.add_per_month / 100)
    else
      self.add_per_month
    end
  end
  
  def amount_till_cap
    if has_cap?
      self.cap - self.amount
    else
      nil
    end
  end
  
  def has_cap?
    if cap != nil
      return true
    else
      return has_cap ? true : false
    end
  end
  
  def has_cap
    @has_cap
  end
  
  def has_prerequisite?
    if prerequisite
      return true
    else
      return has_prerequisite ? true : false
    end
  end
  
  def does_overflow?
    if self.overflow_into
      return true
    else
      return does_overflow ? true : false
    end
  end
  
  def has_prerequisite
    return @has_prerequisite
  end
  
  def does_overflow
    return @does_overflow
  end
  
  def has_cap=(value)
    if(value == "1" || value == true)
      self.cap = 0 if !self.cap
    else
      self.cap = nil
    end
  end
  
  def has_prerequisite=(value)
    if(value == "0" || value == false)
      self.prerequisite = nil
    end
  end
  
  def does_overflow=(value)
    if(value == "0" || value == false)
      self.overflow_into = nil
    end
  end
end
