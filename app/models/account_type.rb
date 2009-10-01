class AccountType < ActiveRecord::Base
  has_many :accounts

  def self.CHECKING
    @@CHECKING ||= self.checking_find
  end

  def self.checking_find
    AccountType.find_by_description("Checking").id
  end

  def self.SAVINGS
    @@SAVINGS ||= self.savings_find
  end

  def self.savings_find
    AccountType.find_by_description("Savings").id
  end

  def self.INVESTMENT
    @@INVESTMENT ||= self.investment_find
  end

  def self.investment_find
    AccountType.find_by_description("Investment").id
  end

  def self.CREDIT_CARD
    @@CREDIT_CARD ||= self.credit_card_find

  end

  def self.credit_card_find
    AccountType.find_by_description("Credit Card").id
  end
end
