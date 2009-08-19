require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe 'accounts/edit' do
  before(:each) do
    @prerequisite = stub_model(Account, :name => "a2")
    @accounts = [stub_model(Account, :name => "a1"), @prerequisite, stub_model(Account, :name => "a3"), stub_model(Account, :name => "a4")]
    @priority_options = [1,2,3,4,5,6,7,8,9,10]
    @account = stub_model(Account, :name => "act1", :priority => 3, :add_per_month => 450, :add_per_month_as_percent => false, :cap => 890, :prerequisite => nil, :amount => 45)
  end

  it "should render the accounts/form partial" do
    template.should_receive(:render).with(:partial => "form", :locals => { :account => @account, :accounts => @accounts, :priority_options => @priority_options}).and_return "rendered from partial"
    
    assigns[:account] = @account
    assigns[:accounts] = @accounts
    assigns[:priority_options] = @priority_options
    render "accounts/edit.html"
    response.should contain("rendered from partial")
  end
end
