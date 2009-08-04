class AccountsController < ApplicationController
  before_filter :verify_current_user
  
  def new
    @account = Account.new
    @priority_options = Account::priority_options
    @accounts = Account.find_all_by_user_id(current_user.id)
  end

  def index
    @accounts = Account.find_all_by_user_id( current_user.id, :order => 'priority DESC, amount ASC, enabled DESC' )
  end
  
  def create
    @account = Account.new(params[:account])
    @account.user_id = current_user.id
    if @account.save
      redirect_to accounts_path
    else
      @priority_options = Account::priority_options
      @accounts = Account.find_all_by_user_id(current_user.id)
      render :action => 'new'
    end
  end

end
