class Income < ActiveRecord::Base
  belongs_to :user
  has_many :account_histories
  
  validates_presence_of :amount, :description, :user_id
  validates_numericality_of :amount, :greater_than => 0
  
  def distribute_income
    amount_left = amount
    
    accounts = Account.find( :all, :conditions => { :user_id => user, :enabled => true }, :order => "`priority` ASC, `add_per_month_as_percent` DESC" )
    
    current_priority = 0
    priority_start_amount = amount_left
    accounts.each do |loop_account|
      if loop_account.priority != current_priority
        priority_start_amount = amount_left
        current_priority = loop_account.priority
      end
      
      amount_left = loop_account.distribute!(amount_left, self, priority_start_amount)
    end
    return amount_left
  end
end