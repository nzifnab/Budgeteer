class AccountHistory < ActiveRecord::Base
  belongs_to :account
  validates_presence_of :amount, :description
  validates_numericality_of :amount
  validates_exclusion_of :amount, :in => {0, 0.0}
end