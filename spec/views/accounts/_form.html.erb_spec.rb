require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/accounts/_form" do
  before(:each) do
    @prerequisite = stub_model(Account, :name => "a2")
    @accounts = [stub_model(Account, :name => "a1"), @prerequisite, stub_model(Account, :name => "a3"), stub_model(Account, :name => "a4")]
    @priority_options = [1,2,3,4,5,6,7,8,9,10]
    @account = mock_model(Account, :null_object => true).as_new_record
  end
  
  def render_new_account_page
    render "accounts/_form.html.erb", :locals => {:account => @account, :accounts => @accounts, :priority_options => @priority_options}
  end
  
  context "New Account Form" do
    it "should render a form to create a new account" do
      render_new_account_page
      
      response.should have_selector("form[method=post]", :action => accounts_path) do |form|
        form.inner_html.should have_selector("input[type=submit]", :value => "Add Account")
      end
    end
    
    it "should render a text field for the account name" do
      name = "my name"
      @account.stub!(:name).and_return(name)
      render_new_account_page
      
      response.should have_selector("form") do |form|
        form.inner_html.should have_selector("input[type=text]", :name => "account[name]", :value => name)
      end
    end
    
    it "should render a select box for the account priority" do
      priority = 3
      @account.stub!(:priority).and_return(priority)
      render_new_account_page
      
      response.should have_selector("form") do |form|
        form.inner_html.should have_selector("select", :name => "account[priority]") do |select|
          @priority_options.each do |option|
            unless option == priority
              select.should have_selector("option", :value => option.to_s)
            else
              select.should have_selector("option", :value => option.to_s, :selected => "selected")
            end
          end
        end
      end
    end
    
    it "should render a text field for amount added per month" do
      add_per_month = 10
      @account.stub!(:add_per_month).and_return(add_per_month)
      render_new_account_page
      response.should have_selector("form") do |form|
        form.inner_html.should have_selector("input[type=text]", :name => "account[add_per_month]", :value => add_per_month.to_s)
      end
    end
    
    it "should render a check box for adding monthly amounts by percent" do
      add_per_month_as_percent = 1
      @account.stub!(:add_per_month_as_percent).and_return(add_per_month_as_percent)
      render_new_account_page
      
      response.should have_selector("form") do |form|
        form.inner_html.should have_selector("input[type=checkbox]", :name => "account[add_per_month_as_percent]", :value => add_per_month_as_percent.to_s)
      end
    end
    
    it "should render a check box for setting a cap on the account" do
      has_cap = 1
      @account.stub!(:has_cap).and_return(has_cap)
      render_new_account_page
      
      response.should have_selector("form") do |form|
        form.inner_html.should have_selector("input[type=checkbox]", :name => "account[has_cap]", :value => has_cap.to_s)
      end
    end
    
    it "should render a field for the account cap" do
      cap = 408.34
      @account.stub!(:cap).and_return(cap)
      render_new_account_page
      
      response.should have_selector("form") do |form|
        form.inner_html.should have_selector("input[type=text]", :name => "account[cap]", :value => cap.to_s)
      end
    end
    
    it "should render a check box for setting an account-adding prerequisite" do
      has_prerequisite = 1
      @account.stub!(:has_prerequisite).and_return(has_prerequisite)
      render_new_account_page
      
      response.should have_selector("form") do |form|
        form.inner_html.should have_selector("input[type=checkbox]", :name => "account[has_prerequisite]", :value => has_prerequisite.to_s)
      end
    end
    
    it "should render a select box for the account prerequisite" do
      @account.stub!(:prerequisite_id).and_return(@prerequisite.id)
      render_new_account_page
      
      response.should have_selector("form") do |form|
        form.inner_html.should have_selector("select", :name => "account[prerequisite_id]") do |select|
          @accounts.each do |object|
            unless object == @prerequisite
              select.inner_html.should have_selector("option", :value => object.id.to_s) do |option|
                option.should contain(object.name)
              end
            else
              select.inner_html.should have_selector("option", :value => object.id.to_s, :selected => "selected") do |option|
                option.should contain(object.name)
              end
            end
          end
        end
      end
    end
    
    it "should render a checkbox to enable the account" do
      enabled = 1
      @account.stub!(:enabled).and_return(enabled)
      render_new_account_page
      
      response.should have_selector("form") do |form|
        form.inner_html.should have_selector("input[type=checkbox]", :name => "account[enabled]", :value => enabled.to_s)
      end
    end
  end
end
