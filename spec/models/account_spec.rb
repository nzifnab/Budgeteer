require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Account do
  before(:each) do
      @valid_params = {"name" => "actname", "priority" => "7", "add_per_month" => "452", "add_per_month_as_percent" => "0", "has_cap" => "1", "cap" => "204.75", "has_prerequisite" => "0", "prerequisite_id" => "", "enabled" => "1"}
  end
  
  describe "#priority_options" do
    it "should return an array of values" do
      Account::priority_options.should be_an_instance_of(Array)
    end
  end #/priority_options
  
  describe "#has_cap?" do
    it "should return true if a cap is active on an instance of Account" do
      cap = 48.07
      account = stub_model(Account, :cap => cap)
      account.has_cap?.should == true
    end
    
    it "should return true even with a cap of '0'" do
      cap = 0
      account = stub_model(Account, :cap => cap)
      account.has_cap?.should == true
    end
    
    it "should return false if a cap is not active on an instance of Account" do
      cap = nil
      account = stub_model(Account, :cap => cap)
      account.has_cap?.should == false
    end
  end #/has_cap?
  
  describe "#has_cap" do
    it "should return true if true was sent in the attributes" do
      @valid_params["has_cap"] = "1"
      account = Account.new(@valid_params)
      account.has_cap.should be_true
    end
    
    it "should return false if false was sent in the attributes" do
      @valid_params["has_cap"] = "0"
      account = Account.new(@valid_params)
      account.has_cap.should be_false
    end
  end #/has_cap
  
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
  end #/has_prerequisite?
  
  describe "#has_prerequisite" do
    it "should return true if true was sent in the attributes" do
      @valid_params["has_prerequisite"] = "1"
      prereq = mock_model(Account)
      @valid_params["prerequisite_id"] = prereq.id
      account = Account.new(@valid_params)
      account.has_prerequisite.should be_true
    end
    
    it "should return false if false was sent in the attributes" do
      @valid_params["has_prerequisite"] = "0"
      account = Account.new(@valid_params)
      account.has_prerequisite.should be_false
    end
  end #/has_prerequisite
  
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
  end #/has_cap =
  
  describe "#has_prerequisite =" do
    context "false" do
      it "should set the prerequisite_id to nil" do
        account = stub_model(Account)
        prerequisite = stub_model(Account)
        account.prerequisite = prerequisite
        account.prerequisite_id.should == prerequisite.id
        account.has_prerequisite = "0"
        account.prerequisite.should be_nil
        account.prerequisite_id.should be_nil
      end
    end
  end #/ has_prerequisite =
  
  describe "#initialize" do
    before(:each) do
      @account = stub_model(Account)
    end
    
    it "should set all of the params on the model" do
      expected_params = {"name" => "actname", "priority" => 7, "add_per_month" => 452, "add_per_month_as_percent" => false, "cap" => 204.75, "prerequisite_id" => nil, "enabled" => true}
      account = Account.new(@valid_params)
      
      expected_params.each do |key,value|
        account.send(key).should == value
      end
    end
    
    context "has_cap = false" do
      before(:each) do
        @valid_params["has_cap"] = "0"
      end
      
      it "should automatically override the cap field to be nil" do
        account = Account.new(@valid_params)
        account.cap.should be_nil
      end
    end
    
    context "has_cap = true" do
      before(:each) do
        @valid_params["has_cap"] = "1"
      end
      
      it "should set the cap field to 0 if it was not yet set" do
        @valid_params["cap"] = nil
        account = Account.new(@valid_params)
        account.cap.should == 0
      end
    end
    
    context "has_prerequisite = false" do
      before(:each) do
        @valid_params["has_prerequisite"] = "0"
      end
      
      it "should remove the prerequisite" do
        prerequisite = stub_model(Account)
        @valid_params["prerequisite_id"] = prerequisite.id
        account = Account.new(@valid_params)
        account.prerequisite.should == nil
        account.prerequisite_id.should == nil
      end
    end
    
    context "has_prerequisite = true" do
      before(:each) do
        @valid_params["has_prerequisite"] = "1"
      end
      
      it "should save the prerequisite to the object" do
        prerequisite = stub_model(Account)
        @valid_params["prerequisite_id"] = prerequisite.id
        account = Account.new(@valid_params)
        account.prerequisite_id.should == prerequisite.id
      end
    end
  end #/initialize
  
  describe "#validation" do
    context "Name" do
      it "should be required" do
        @valid_params["name"] = nil
        account = Account.new(@valid_params)
        valid = account.valid?
        account.errors.full_messages.should == ["Name can't be blank"]
        valid.should be_false
      end
    end #/Name
    
    context "Priority" do
      it "should be required" do
        @valid_params["priority"] = nil
        account = Account.new(@valid_params)
        valid = account.valid?
        account.errors.full_messages.should == ["Priority can't be blank"]
        valid.should be_false
      end
    end #/Priority
    
    context "Add Per Month" do
      it "should be required" do
        @valid_params["add_per_month"] = nil
        account = Account.new(@valid_params)
        valid = account.valid?
        account.errors.full_messages.should include("Add per month can't be blank")
        valid.should be_false
      end
      
      it "should ignore non-numerical data" do
        @valid_params["add_per_month"] = "Bob"
        account = Account.new(@valid_params)
        valid = account.valid?
        account.add_per_month.should == 0
      end
      
      it "should allow two digits following a decimal point" do
        @valid_params["add_per_month"] = "374.82"
        account = Account.new(@valid_params)
        valid = account.valid?
        account.errors.full_messages.should == []
        valid.should be_true
      end
      
      it "should allow more than two digits following a decimal point" do
        @valid_params["add_per_month"] = "874.238293"
        account = Account.new(@valid_params)
        valid = account.valid?
        account.errors.full_messages.should == []
        valid.should be_true
      end
      
      it "should allow negative numbers" do
        @valid_params["add_per_month"] = "-104.72"
        account = Account.new(@valid_params)
        valid = account.valid?
        account.errors.full_messages.should == []
        valid.should be_true
      end
      
      context "As Percent" do
        it "should be less than 100%" do
          @valid_params["add_per_month_as_percent"] = "1"
          @valid_params["add_per_month"] = "100.05"
          account = Account.new(@valid_params)
          valid = account.valid?
          account.errors.full_messages.should == ["Add per month cannot be greater than 100%"]
          valid.should be_false
        end
      end #/As Percent
    end #/Add Per Month
    
    context "Cap" do
      it "should default to 0 is 'Has a Cap' is sent as true" do
        @valid_params["has_cap"] = "1"
        @valid_params["cap"] = nil
        account = Account.new(@valid_params)
        valid = account.valid?
        account.cap.should == 0
        account.errors.full_messages.should == []
        valid.should be_true
      end
      
      it "should not be required if 'Has a Cap' is sent as false" do
        @valid_params["has_cap"] = "0"
        @valid_params["cap"] = nil
        account = Account.new(@valid_params)
        valid = account.valid?
        account.errors.full_messages.should == []
        valid.should be_true
      end
      
      it "should require numericality" do
        @valid_params["has_cap"] = "1"
        @valid_params["cap"] = "Bubbles"
        account = Account.new(@valid_params)
        valid = account.valid?
        account.errors.full_messages.should == ["Cap is not a number"]
        valid.should be_false
      end
    end #/Cap
    
    context "Prerequisite" do
      it "should be required if 'Has Prerequisite' is sent as true" do
        @valid_params["has_prerequisite"] = "1"
        @valid_params["prerequisite"] = nil
        account = Account.new(@valid_params)
        valid = account.valid?
        account.errors.full_messages.should == ["Prerequisite is required if 'Has Prerequisite' is selected"]
        valid.should be_false
      end
      
      it "should not be required if 'Has Prerequisite' is sent as true" do
        @valid_params["has_prerequisite"] = "0"
        @valid_params["prerequisite"] = nil
        account = Account.new(@valid_params)
        valid = account.valid?
        account.errors.full_messages.should == []
        valid.should be_true
      end
    end
  end #/validation
end
