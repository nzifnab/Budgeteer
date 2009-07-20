require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Account do
  describe "#priority_options" do
    it "should return an array of values" do
      Account::priority_options.should be_an_instance_of(Array)
    end
  end
  
  describe "#has_cap?" do
    it "should return true if a cap is active on an instance of Account" do
      cap = 48.07
      account = stub_model(Account, :cap => cap)
      account.has_cap?.should == true
    end
    
    it "should return false if a cap is not active on an instance of Account" do
      cap = 0
      account = stub_model(Account, :cap => cap)
      account.has_cap?.should == false
    end
  end
  
  describe "#has_prerequisite?" do
    it "should return true if the account has a prerequisite set on it" do
      prereq = mock_model(Account)
      account = stub_model(Account, :prerequisite => prereq)
      account.has_prerequisite?.should == true
    end
    
    it "should return false if the account doesn't have a prerequisite" do
      prereq = nil
      account = stub_model(Account, :prerequisite => prereq)
      account.has_prerequisite?.should == false
    end
  end
  
  describe "#has_cap =" do
    context "false" do
      it "should set the cap to nil" do
        account = stub_model(Account)
        account.cap = "472.89"
        account.has_cap = "0"
        account.cap.should be_nil
      end
    end
    
    context "true" do
      it "should set the cap to 0 if it was nil" do
        account = stub_model(Account)
        account.has_cap = "1"
        account.cap.should == 0
      end
      
      it "should not affect the cap if the cap was already set" do
        account = stub_model(Account)
        cap_val = "38"
        account.cap = "38"
        account.has_cap = "1"
        account.cap.should == cap_val.to_i
      end
    end
  end
  
  describe "#new" do
    before(:each) do
      @valid_params = {"name" => "actname", "priority" => "7", "add_per_month" => "452", "add_per_month_as_percent" => "0", "has_cap" => "1", "cap" => "204.75", "has_prerequisite" => "0", "prerequisite_id" => "", "enabled" => "1", "commit" => "Add Account"}
      @account = stub_model(Account)
    end
    
    it "should call the parent's super" do
      pending do
        ActiveRecord::Base.should_receive(:new).with(@valid_params)
        @account.new(@valid_params)
      end
    end
    
    context "has_cap = false" do
      before(:each) do
        @valid_params["has_cap"] = "0"
      end
      
      it "should automatically override the cap field to be nil" do
        pending do
          account = @account.new(@valid_params)
          account.cap.should be_nil
        end
      end
    end
    
    context "has_cap = true" do
      it "should should set the cap field to 0 if it was not yet set" do
        pending do
          @valid_params["cap"] = nil
          account = @account.new(@valid_params)
          account.cap.should == 0
        end
      end
      
      it "should not affect the cap field if it has a value" do
        pending do
          account = @account.new(@valid_params)
          account.cap.should == @valid_params["cap"]
        end
      end
    end
  end
end
