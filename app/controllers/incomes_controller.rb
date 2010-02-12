class IncomesController < ApplicationController
  before_filter :verify_current_user

  def create
    @income = Income.new(params[:income])
    @income.user = current_user
    if @income.save && (income_left = @income.distribute_income)
      if income_left > 0
        @current_user.non_distributed_funds = (@current_user.non_distributed_funds || 0) + income_left
        @current_user.save
      end
      flash[:notice] = "Income saved ($#{income_left} remaining after distribution)"
      @history = AccountHistory.find( :all, :conditions => { :income_id => @income } )
      @income = Income.new
    else
      flash[:warning] = "Error when trying to save income"
    end
    @accounts = Account.find_all_by_user_id( current_user.id, :order => 'enabled DESC, priority ASC, amount DESC, name ASC' )
    @account = Account.find( params[:account_id] ) if params[:account_id]
    send_type_amounts
    render 'accounts/index'
  end

  def index
    @incomes = Income.find_all_by_user_id( current_user.id, :order => 'created_at DESC, amount DESC' )
    if params[:income_id]
      @income = Income.find( params[:income_id] )
      @history = @income.account_histories
    end
  end
end