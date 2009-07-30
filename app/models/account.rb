class Account < ActiveRecord::Base
  belongs_to :prerequisite, :class_name => "Account"
  validates_presence_of :name, :priority, :add_per_month
  validates_presence_of :cap, :if => Proc.new{ |account| account.has_cap }, :message => "is required with 'Has a Cap' selected"
  validates_presence_of :prerequisite_id, :if => Proc.new{ |account| account.has_prerequisite }, :message => "is required if 'Has Prerequisite' is selected"
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
    
    super(attributes)
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
  
  def has_prerequisite
    return @has_prerequisite
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
end
