class Income < ActiveRecord::Base
  belongs_to :user
  has_many :account_histories

  validates_presence_of :amount, :description, :user_id
  validates_numericality_of :amount, :greater_than => 0

  def distribute_income
    amount_left = amount

    accounts = Account.find( :all, :conditions => { :user_id => self.user, :enabled => true }, :order => "`priority` ASC, `add_per_month_as_percent` DESC" )

    current_priority = 0
    priority_start_amount = amount_left
    accounts.each do |loop_account|
      if loop_account.priority != current_priority
        priority_start_amount = amount_left
        current_priority = loop_account.priority
      end

      if loop_account.has_reached_cap? && loop_account.does_overflow? && loop_account.has_fulfilled_prerequisite?
        use_amt = loop_account.distribute_use_amount(amount_left, priority_start_amount, nil, true)
        return false unless( amount_left -= (use_amt - loop_account.overflow_into.distribute_as_overflow!(use_amt, self) ) )
      else
        return false unless( amount_left = loop_account.distribute!(amount_left, self, priority_start_amount) )
      end
    end
    return amount_left
  end

  def created_at_date
    self.created_at.strftime( '%m-%d-%y' )
  end
end