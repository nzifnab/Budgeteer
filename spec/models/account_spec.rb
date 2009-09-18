require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Account do
  before(:each) do
      @valid_params = {"name" => "actname", "priority" => "7", "add_per_month" => "452", "add_per_month_as_percent" => "0", "has_cap" => "1", "cap" => "204.75", "has_prerequisite" => "0", "prerequisite_id" => "", "enabled" => "1"}
  end
  
  describe "#distribute!" do
    before(:each) do
      @income = stub_model(Income, :description => "Paytime!")
      @account = stub_model(Account, :save => true)
      AccountHistory.stub!(:create!)
      Account.stub!(:find)
    end
    
    it "should check if the account should have distribution performed on it" do
      @account.should_receive(:should_distribute?)
      
      @account.distribute!(1000, @income, 1000)
    end
    
    context "should_distribute? = true" do
      before(:each) do
        @account.stub!(:should_distribute?).and_return(true)
      end
      
      it "should set the amount correctly, if it is positive, and save the account object" do
        @account.stub!(:distribute_use_amount).and_return(235)
        
        @account.should_receive(:amount=).with(235)
        @account.should_receive(:save)
        @account.distribute!(1000, @income, 750)
      end
      
      it "should not attempt to set the amount if it is 0 or under, and it should return the given_amount" do
        @account.stub!(:distribute_use_amount).and_return(-45)
        
        @account.should_not_receive(:amount=)
        @account.distribute!(1000, @income, 750).should == 1000
      end
      
      it "should create a new history object with the correct data" do
        @account.stub!(:distribute_use_amount).and_return(350)
        AccountHistory.should_receive(:create!).with( :amount => 350, :account_id => @account.id, :income_id => @income.id, :description => @income.description )
        
        @account.distribute!(1000, @income, 750)
      end
      
      it "should check if the account has reached it's cap" do
        @account.stub!(:distribute_use_amount).and_return(350)
        @account.should_receive(:has_reached_cap?)
        
        @account.distribute!(1000, @income, 750)
      end
      
      context "has reached cap = true" do
        before(:each) do
          @account.stub!(:distribute_use_amount).and_return(350)
          @account.stub!(:has_reached_cap?).and_return(true)
          @account.stub!(:amount_to_use).and_return(450)
          @account.stub!(:does_overflow?).and_return(false)
          #this_left = {prereq_left} - 100   (or just 100 if prereq_left is nil)
        end
        
        it "should find all fullfilled prerequisites if this_left is greater than 0" do
          Account.should_receive(:find).and_return([])
          @account.distribute!(1000, @income, 750)
        end
        
        it "should not attempt to find accounts if this_left is less than or equal to 0" do
          Account.should_not_receive(:find)
          @account.distribute!(1000, @income, 750, 100)
        end
        
        it "should call distribute! for every fulfilled prerequisite account found" do
          prereq1 = stub_model(Account)
          prereq2 = stub_model(Account)
          prereq3 = stub_model(Account)
          
          prereq1.should_receive(:distribute!).with(650, @income, 750, 100).and_return({:given_amount => 500, :this_left => 300})
          prereq2.should_receive(:distribute!).with(500, @income, 750, 300).and_return({:given_amount => 450, :this_left => 200})
          prereq3.should_receive(:distribute!).with(450, @income, 750, 200).and_return({:given_amount => 800, :this_left => 58})
          
          fullfilled_prereqs = [prereq1, prereq2, prereq3]
          
          Account.stub!(:find).and_return(fullfilled_prereqs)
          
          @account.distribute!(1000, @income, 750).should == 800
        end
        
        context "does overflow = true" do
          before(:each) do
            @account.stub!(:does_overflow?).and_return(true)
            @overflow_account = stub_model(Account)
            @account.stub!(:overflow_into).and_return(@overflow_account)
            Account.stub!(:find).and_return []
          end
          
          it "should send the remaining amount to the overflow account" do
            @overflow_account.should_receive(:distribute_as_overflow!).with(100, @income).and_return(0)
            @account.distribute!(1000, @income, 750)
          end
        end
      end
      
      context "has reached cap = false" do
        before(:each) do
          @account.stub!(:has_reached_cap?).and_return(false)
          @account.stub!(:distribute_use_amount).and_return(300)
        end
        
        it "should return the correct amount for no prereq_left sent" do
          @account.distribute!(1000, @income, 750).should == 700
        end
        
        it "should return the correct array when a prereq_left is sent" do
          @account.distribute!(1000, @income, 750, 400).should == {:given_amount => 700, :this_left => 400}
        end
      end
    end
    
    context "should_distribute? = false" do
      before(:each) do
        @account = stub_model(Account, :should_distribute? => false)
      end
      
      it "should return the given amount" do
        @account.distribute!(1000, @income, 750).should == 1000
      end
      
      it "should return the given amount and the amount left from the capped prerequisite, if applicable" do
        @account.distribute!(1000, @income, 750, 329).should == {:given_amount => 1000, :this_left => 329}
      end
    end
  end#/distribute!
  
  describe "#distribute_as_overflow!" do
    before(:each) do
      @account = stub_model(Account)
      @income = stub_model(Income, :description => "yay monlies")
      AccountHistory.stub!(:create!)
    end
    
    it "should add the full amount to the account if it has no cap" do
      @account.amount = 50
      @account.stub!(:has_cap?).and_return(false)
      AccountHistory.should_receive(:create!)
      @account.distribute_as_overflow!(458.72, @income).should == 0
      @account.amount.should == 508.72
    end
    
    it "should add enough to fill to the cap if the sent amount is less than the amount till cap amount" do
      @account.amount = 80
      @account.stub!(:has_cap?).and_return(true)
      @account.stub!(:amount_till_cap).and_return(100)
      AccountHistory.should_receive(:create!)
      @account.distribute_as_overflow!(120, @income).should == 20
      @account.amount.should == 180
    end
    
    it "should add the full amount if the cap is higher than the amount to add" do
      @account.amount = 40
      @account.stub!(:has_cap?).and_return(true)
      @account.stub!(:amount_till_cap).and_return(110)
      AccountHistory.should_receive(:create!)
      @account.distribute_as_overflow!(80, @income).should == 0
      @account.amount.should == 120
    end
    
    it "should not add any if the amount is already at the cap" do
      @account.amount = 140
      @account.stub!(:has_cap?).and_return(true)
      @account.stub!(:amount_till_cap).and_return(-60)
      AccountHistory.should_not_receive(:create!)
      @account.distribute_as_overflow!(85, @income).should == 85
      @account.amount.should == 140
    end
  end
  
  describe "#has_reached_cap?" do
    it "should return true if a cap is present and the amount is equal to the cap" do
      account = stub_model(Account, :has_cap? => true, :amount => 59, :cap => 59)
      account.has_reached_cap?.should == true
    end
    
    it "should return true if a cap is present and the amount is greater than the cap" do
      account = stub_model(Account, :has_cap? => true, :amount => 459.72, :cap => 385.91)
      account.has_reached_cap?.should == true
    end
    
    it "should return false if a cap is not present" do
      account = stub_model(Account, :has_cap? => false)
      account.has_reached_cap?.should == false
    end
    
    it "should return false if a cap is present and the amount is less than the cap" do
      account = stub_model(Account, :has_cap => true, :cap => 350)
      account.has_reached_cap?.should == false
    end
  end #/has_reached_cap?
  
  describe "#distribute_use_amount" do
    it "should gather information about all applicable 'minimum' amounts" do
      @account = stub_model(Account)
      
      @account.should_receive(:amount_to_use).with(750)
      @account.should_receive(:amount_till_cap)
      @account.should_receive(:amount_till_add_per_month)
      
      @account.distribute_use_amount(1000, 750)
    end
    
    it "should return the correct value for the amount to use" do
      @account = stub_model(Account, :amount_to_use => 300, :amount_till_cap => 125, :amount_till_add_per_month => nil, :amount => 100)
      
      @account.distribute_use_amount(1000, 750, 145).should == 125
    end
  end #/distribute_use_amount
  
  describe "#should_distribute?" do
    it "should return true if enabled with no prerequisites" do
      account = stub_model(Account, :enabled => true, :has_prerequisite? => false)
      
      account.should_distribute?.should == true
    end
    
    it "should return true if enabled with a capped prerequisite" do
      prereq = stub_model(Account, :amount => 59, :cap => 59)
      account = stub_model(Account, :enabled => true, :has_prerequisite? => true, :prerequisite => prereq)
      
      account.should_distribute?.should == true
    end
    
    it "should return false if enabled with a non-capped prerequisite" do
      prereq = stub_model(Account, :amount => 59, :cap => 100)
      account = stub_model(Account, :enabled => true, :has_prerequisite? => true, :prerequisite => prereq)
      
      account.should_distribute?.should == false
    end
    
    it "should return false if disabled" do
      account = stub_model(Account, :enabled => false)
      
      account.should_distribute?.should == false
    end
  end#/should_distribute?
  
  describe "#amount_till_cap" do
    before(:each) do
      @account = Account.new(@valid_params)
      @account.amount = 100
    end
    
    context "has cap" do
      before(:each) do
        @account.stub!(:has_cap?).and_return(true)
      end
      
      it "should return the amount left until the cap is reached" do
        @account.amount_till_cap.should == 104.75
      end
    end
    
    context "doesn't have cap" do
      before(:each) do
        @account.stub!(:has_cap?).and_return(false)
      end
      
      it "should return nil" do
        @account.amount_till_cap.should be_nil
      end
    end
  end #/amount_till_cap
  
  describe "#amount_to_use" do
    before(:each) do
      @account = stub_model(Account)
    end
    
    it "should calculate the correct value when add per month is a percent" do
      @account.should_receive(:add_per_month_as_percent).and_return(true)
      @account.stub!(:add_per_month).and_return(38.72)
      
      @account.amount_to_use(1000).should == 387.2
    end
    
    it "should return the add per month amount if it is not a percent" do
      @account.should_receive(:add_per_month_as_percent).and_return(false)
      @account.stub!(:add_per_month).and_return(451.85)
      
      @account.amount_to_use(352).should == 451.85
    end
  end #/amount_to_use
  
  describe "#amount_till_add_per_month" do
    before(:each) do
      @account = stub_model(Account)
    end
    
    context "Add per month as percent = false" do
      before(:each) do
        @account.stub!(:add_per_month_as_percent).and_return(false)
        @account.stub!(:add_per_month).and_return(790)
        @month_account_histories = [stub_model(AccountHistory, :amount => 384.72), stub_model(AccountHistory, :amount => 100.0), stub_model(AccountHistory, :amount => nil)]
        AccountHistory.stub!(:find).and_return(@month_account_histories)
      end
      
      it "should return the correct amount left to be added for the month" do
        @account.amount_till_add_per_month.should == 305.28
      end
    end
    
    context "Add per month as percent = true" do
      before(:each) do
        @account.stub!(:add_per_month_as_percent).and_return(true)
        @account.stub!(:add_per_month).and_return(41)
      end
      
      it "should return nil" do
        @account.amount_till_add_per_month.should be_nil
      end
    end
  end #/amount_till_add_per_month
  
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
  
  describe "#does_overflow?" do
    it "should return true if the account has an overflow_into set on it" do
      overflow_into = mock_model(Account)
      account = stub_model(Account, :overflow_into => overflow_into)
      account.does_overflow?.should == true
    end
    
    it "should return false if the account doesn't have overflow_into set on it" do
      overflow_into = nil
      account = stub_model(Account, :overflow_into => overflow_into)
      account.does_overflow?.should == false
    end
  end #/does_overflow?
  
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
  
  describe "#does_overflow =" do
    context "false" do
      it "should set the overflow_into_id to nil" do
        account = stub_model(Account)
        account.overflow_into_id = stub_model(Account).id
        account.does_overflow = "0"
        account.overflow_into_id.should be_nil
      end
    end
  end #/ does_overflow =
  
  describe "#initialize" do
    before(:each) do
      @account = stub_model(Account)
    end
    
    it "should set all of the params on the model" do
      expected_params = {"name" => "actname", "priority" => 7, "add_per_month" => 452, "add_per_month_as_percent" => false, "cap" => 204.75, "prerequisite_id" => nil, "overflow_into_id" => nil, "enabled" => true}
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
    
    context "does_overflow = false" do
      before(:each) do
        @valid_params["does_overflow"] = "0"
      end
      
      it "should remove the overflow_into account" do
        overflow_into = stub_model(Account)
        @valid_params["overflow_into_id"] = overflow_into.id
        account = Account.new(@valid_params)
        account.overflow_into.should == nil
        account.overflow_into_id.should == nil
      end
    end
    
    context "does_overflow = true" do
      before(:each) do
        @valid_params["does_overflow"] = "1"
      end
      
      it "should save the overflow_into to the object" do
        overflow_into = stub_model(Account)
        @valid_params["overflow_into_id"] = overflow_into.id
        account = Account.new(@valid_params)
        account.overflow_into_id.should == overflow_into.id
      end
    end
  end #/initialize
  
  describe "#validation" do
    def setUser(account)
      @user = mock_model(User)
      account.user = @user
    end
    
    context "User" do
      it "should be required" do
        account = Account.new(@valid_params)
        
        valid = account.valid?
        account.errors.full_messages.should == ["User can't be blank"]
        valid.should be_false
      end
    end
    
    context "Name" do
      it "should be required" do
        @valid_params["name"] = nil
        account = Account.new(@valid_params)
        setUser(account)
        valid = account.valid?
        account.errors.full_messages.should == ["Name can't be blank"]
        valid.should be_false
      end
    end #/Name
    
    context "Priority" do
      it "should be required" do
        @valid_params["priority"] = nil
        account = Account.new(@valid_params)
        setUser(account)
        valid = account.valid?
        account.errors.full_messages.should == ["Priority can't be blank"]
        valid.should be_false
      end
    end #/Priority
    
    context "Add Per Month" do
      it "should be required" do
        @valid_params["add_per_month"] = nil
        account = Account.new(@valid_params)
        setUser(account)
        valid = account.valid?
        account.errors.full_messages.should include("Add per month can't be blank")
        valid.should be_false
      end
      
      it "should ignore non-numerical data" do
        @valid_params["add_per_month"] = "Bob"
        account = Account.new(@valid_params)
        setUser(account)
        valid = account.valid?
        account.add_per_month.should == 0
      end
      
      it "should allow two digits following a decimal point" do
        @valid_params["add_per_month"] = "374.82"
        account = Account.new(@valid_params)
        setUser(account)
        valid = account.valid?
        account.errors.full_messages.should == []
        valid.should be_true
      end
      
      it "should allow more than two digits following a decimal point" do
        @valid_params["add_per_month"] = "874.238293"
        account = Account.new(@valid_params)
        setUser(account)
        valid = account.valid?
        account.errors.full_messages.should == []
        valid.should be_true
      end
      
      it "should allow negative numbers" do
        @valid_params["add_per_month"] = "-104.72"
        account = Account.new(@valid_params)
        setUser(account)
        valid = account.valid?
        account.errors.full_messages.should == []
        valid.should be_true
      end
      
      context "As Percent" do
        it "should be less than 100%" do
          @valid_params["add_per_month_as_percent"] = "1"
          @valid_params["add_per_month"] = "100.05"
          account = Account.new(@valid_params)
          setUser(account)
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
        setUser(account)
        valid = account.valid?
        account.cap.should == 0
        account.errors.full_messages.should == []
        valid.should be_true
      end
      
      it "should not be required if 'Has a Cap' is sent as false" do
        @valid_params["has_cap"] = "0"
        @valid_params["cap"] = nil
        account = Account.new(@valid_params)
        setUser(account)
        valid = account.valid?
        account.errors.full_messages.should == []
        valid.should be_true
      end
      
      it "should require numericality" do
        @valid_params["has_cap"] = "1"
        @valid_params["cap"] = "Bubbles"
        account = Account.new(@valid_params)
        setUser(account)
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
        setUser(account)
        valid = account.valid?
        account.errors.full_messages.should == ["Prerequisite is required if 'Has Prerequisite' is selected"]
        valid.should be_false
      end
      
      it "should not be required if 'Has Prerequisite' is sent as true" do
        @valid_params["has_prerequisite"] = "0"
        @valid_params["prerequisite"] = nil
        account = Account.new(@valid_params)
        setUser(account)
        valid = account.valid?
        account.errors.full_messages.should == []
        valid.should be_true
      end
    end
  end #/validation
end
