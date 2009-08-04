require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/accounts/_account" do
  def render_account_partial
    render :partial => 'accounts/account', :locals => {:account => @account, :highlight => nil, :account_history => @account_history}
  end
  
  before(:each) do
    @account_history = stub_model(AccountHistory, :amount => 85.32, :description => "fun fun fun times of funzies")
    @account = stub_model(Account, :name => "act1", :priority => 3, :add_per_month => 450, :add_per_month_as_percent => false, :cap => 890, :prerequisite => nil, :amount => 45)
  end

  it "should display a single account name" do
    render_account_partial
    response.should contain("Name: #{@account.name}")
  end
  
  it "should display the account total" do
    render_account_partial
    response.should contain("Amount:$#{@account.amount}")
  end
  
  it "should display the account priority level" do
    render_account_partial
    response.should contain("Priority:#{@account.priority}")
  end
  
  context "added per month not as percent" do
    it "should display the amount added per month" do
      render_account_partial
      response.should contain("Added per month:$#{@account.add_per_month}")
    end
  end
  
  context "added per month as percent" do
    it "should display the amount added per month as a percent" do
      @account.stub!(:add_per_month => 28, :add_per_month_as_percent => true)
      render_account_partial
      response.should contain("Added per month:#{@account.add_per_month}%")
    end
  end
  
  context "no account cap" do
    it "should display NONE for the account cap" do
      @account.stub!(:cap => nil)
      render_account_partial
      response.should contain("Cap:NONE")
    end
  end
  
  context "has account cap" do
    it "should display the account cap" do
      render_account_partial
      response.should contain("Cap:$#{@account.cap}")
    end
  end
  
  context "doesn't have a prerequisite" do
    it "should not display a prerequisite" do
      render_account_partial
      response.should contain("Prerequisite:NONE")
    end
  end
  
  context "has a prerequisite" do
    it "should display the account prerequisite" do
      prereq = stub_model(Account, :name => "prerequisite_account")
      @account.stub!(:prerequisite => prereq)
      render_account_partial
      response.should contain("Prerequisite:#{prereq.name}")
    end
  end
  
  context "withdraw/deposit form" do
    it "should render a form for the changefunds action" do
      render_account_partial
      response.should have_selector("form[method=post]", :action => changefunds_account_path(@account.id)) do |form|
        form.inner_html.should have_selector("input[type=submit]", :value => "Withdraw")
        form.inner_html.should have_selector("input[type=submit]", :value => "Deposit")
      end
    end
    
    it "should contain a textfield for the amount" do
      render_account_partial
      response.should have_selector("form") do |form|
        form.inner_html.should have_selector("input[type=text]", :name => "account_history[amount]", :value => @account_history.amount.to_s)
      end
    end
    
    it "should contain a textarea for the description" do
      render_account_partial
      response.should have_selector("form") do |form|
        form.inner_html.should have_selector("textarea", :name => "account_history[description]") do |ta|
          ta.inner_html.should =~ /#{@account_history.description}/
        end
      end
    end
  end
end