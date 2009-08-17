class AccountHistory < ActiveRecord::Base
  belongs_to :account
  belongs_to :income
  validates_presence_of :amount, :description
  validates_numericality_of :amount
  validates_exclusion_of :amount, :in => {0, 0.0}
  
  def created_at_date
    self.created_at.strftime( '%m-%d-%y' )
  end
end