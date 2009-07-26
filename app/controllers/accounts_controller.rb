class AccountsController < ApplicationController
  before_filter :verify_current_user
  
  def new
    @account = Account.new
    @priority_options = Account::priority_options
    @accounts = Account.find_all_by_user_id(current_user.id)
  end

  def index
  end
  
  def create
    @account = Account.new(params[:account])
    if @account.save
      redirect_to accounts_path
    else
      @priority_options = Account::priority_options
      @accounts = Account.find_all_by_user_id(current_user.id)
      render :action => 'new'
    end
  end

end
