class AccountsController < ApplicationController
  before_filter :verify_current_user
  
  def new
    @account = Account.new
    @priority_options = Account::priority_options
    @accounts = Account.find_all_by_user_id(current_user.id)
  end

  def index
    @accounts = Account.find_all_by_user_id( current_user.id, :order => 'enabled DESC, priority ASC, amount DESC, name ASC' )
    if params[:account_id]
      @account = Account.find( params[:account_id] )
      @history = AccountHistory.find( :all, :conditions => { :account_id => @account }, :order => 'created_at DESC')
    end
    @income = Income.new
  end

	def update
		@account = Account.find(params[:id])
		
		if @account.user == current_user
  		if @account.update_attributes(params[:account])
  		  flash[:notice] = "Editing account was successful."
  		  redirect_to :action => 'index', :account_id => @account.id
  	  else
  	    flash[:warning] = "An error has ocurred when updating the account."
  	    @priority_options = Account.priority_options
        @accounts = Account.find_all_by_user_id(current_user.id)
  	    render :action => 'edit'
  	  end
	  else
	    flash[:warning] = "Account does not exist"
	    redirect_to accounts_path
    end
	end
  
  def create
    @account = Account.new(params[:account])
    @account.user_id = current_user.id
    if @account.save
      redirect_to :action => 'index', :account_id => @account.id
    else
      @priority_options = Account::priority_options
      @accounts = Account.find_all_by_user_id(current_user.id)
      render :action => 'new'
    end
  end
  
  def edit
    @account = Account.find(params[:id])
    if @account.user == current_user
      @priority_options = Account.priority_options
      @accounts = Account.find_all_by_user_id(current_user.id)
    else
      flash[:warning] = "Account does not exist"
      redirect_to accounts_path
    end
  end
  
  def changefunds
    index
    @account = Account.find(params[:id])
    
    if params[:account_history][:amount].to_f <= 0
      flash[:warning] = "Error Occurred - The amount for your transaction must be a number greater than 0!"
      @account_history = AccountHistory.new(params[:account_history])
      render 'accounts/index'
      return
    end
    
    if params[:commit] == "Withdraw"
      params[:account_history][:amount] = (params[:account_history][:amount].to_f * (-1)).to_s
    end
    
    @account_history = AccountHistory.new(params[:account_history])
    @account_history.account = @account
    
    if @account_history.save
      @account.amount ||= 0
      @account.amount += params[:account_history][:amount].to_f
      @account.save
      flash[:notice] = params[:commit] + " successful"
      redirect_to :action => 'index', :account_id => @account.id
      return
    else
      @account = nil
      flash[:warning] = "Error occurred"
    end
    
    render 'accounts/index'
  end
end
