# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  filter_parameter_logging :password

  before_filter :send_current_user

  def verify_current_user
    unless current_user
      redirect_to login_users_path
      return false
    else
      return true
    end
  end

  def current_user
    if session[:user_id]
      @current_user ||= (User.find(session[:user_id]) || false)
    else
      return false
    end
  end

  def send_current_user
    current_user
  end

  def send_type_amounts
    @type_amounts = {}
    savings_account = current_user.accounts.find(:all, :conditions => {:account_type_id => AccountType.SAVINGS})
    @type_amounts["Savings"] = savings_account.map {|account| account.amount}.sum
    checking_account = current_user.accounts.find(:all, :conditions => {:account_type_id => AccountType.CHECKING})
    @type_amounts["Checking"] = checking_account.map {|account| account.amount}.sum
    investment_account = current_user.accounts.find(:all, :conditions => {:account_type_id => AccountType.INVESTMENT})
    @type_amounts["Investment"] = investment_account.map {|account| account.amount}.sum
    credit_card_account = current_user.accounts.find(:all, :conditions => {:account_type_id => AccountType.CREDIT_CARD})
    @type_amounts["Credit Card"] = credit_card_account.map{|account| account.amount}.sum
  end
end
