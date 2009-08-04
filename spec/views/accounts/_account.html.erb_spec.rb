require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/accounts/_account" do
  before(:each) do
    @account = stub_model(Account, :name => "act1", :priority => 3, :add_per_month => 450, :add_per_month_as_percent => false, :cap => 890, :prerequisite => nil, :amount => 45)
  end

  it "should display a single account name" do
    render :partial => 'accounts/account', :locals => {:account => @account}
    response.should contain("Name: #{@account.name}")
  end
  
  it "should display the account total" do
    render :partial => 'accounts/account', :locals => {:account => @account}
    response.should contain("Amount: $#{@account.amount}")
  end
  
  it "should display the account priority level" do
    render :partial => 'accounts/account', :locals => {:account => @account}
    response.should contain("Priority: #{@account.priority}")
  end
  
  context "added per month not as percent" do
    it "should display the amount added per month" do
      render :partial => 'accounts/account', :locals => {:account => @account}
      response.should contain("Added per month: $#{@account.add_per_month}")
    end
  end
  
  context "added per month as percent" do
    it "should display the amount added per month as a percent" do
      @account.stub!(:add_per_month => 28, :add_per_month_as_percent => true)
      render :partial => 'accounts/account', :locals => {:account => @account}
      response.should contain("Added per month: #{@account.add_per_month}%")
    end
  end
  
  context "no account cap" do
    it "should display NONE for the account cap" do
      @account.stub!(:cap => nil)
      render :partial => 'accounts/account', :locals => {:account => @account}
      response.should contain("Cap: NONE")
    end
  end
  
  context "has account cap" do
    it "should display the account cap" do
      render :partial => 'accounts/account', :locals => {:account => @account}
      response.should contain("Cap: $#{@account.cap}")
    end
  end
  
  context "doesn't have a prerequisite" do
    it "should not display a prerequisite" do
      render :partial => 'accounts/account', :locals => {:account => @account}
      response.should contain("Prerequisite: NONE")
    end
  end
  
  context "has a prerequisite" do
    it "should display the account prerequisite" do
      prereq = stub_model(Account, :name => "prerequisite_account")
      @account.stub!(:prerequisite => prereq)
      render :partial => 'accounts/account', :locals => {:account => @account}
      response.should contain("Prerequisite: #{prereq.name}")
    end
  end
end