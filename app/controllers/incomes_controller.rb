class IncomesController < ApplicationController
  def create
    @income = Income.new(params[:income])
    @income.user = current_user
    if @income.save && @income.distribute_income
      flash[:notice] = "Income saved"
      @history = AccountHistory.find( :all, :conditions => { :income_id => @income } )
      @income = Income.new
    else
      flash[:warning] = "Error when trying to save income"
    end
    @accounts = Account.find_all_by_user_id( current_user.id, :order => 'enabled DESC, priority ASC, amount DESC, name ASC' )
    @account = Account.find( params[:account_id] ) if params[:account_id]
    render 'accounts/index'
  end
end