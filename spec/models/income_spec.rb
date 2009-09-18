require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Income do
  before(:each) do
    @income = stub_model( Income, :amount => 1400, :description => "Payday!", :user => stub_model(User) )
    @accounts = [
      stub_model(Account, :priority => 4, :distribute! => 900, :has_reached_cap? => false), 
      stub_model(Account, :priority => 5, :distribute! => 400, :has_reached_cap? => false), 
      stub_model(Account, :priority => 5, :distribute! => 150, :has_reached_cap? => false)
    ]
    AccountHistory.stub!(:create!)
    Account.stub!(:find).and_return( @accounts )
  end

  describe "#distribute_income" do
    it "should collect account objects" do
      Account.should_receive(:find).with(:all, :conditions => anything(), :order => anything()).and_return( @accounts )
      @income.distribute_income
    end
    
    it "should call the !distribute method for each account" do
      @accounts[0].should_receive(:distribute!).with(1400, @income, 1400).and_return(900)
      @accounts[1].should_receive(:distribute!).with(900, @income, 900).and_return(400)
      @accounts[2].should_receive(:distribute!).with(400, @income, 900).and_return(150)
      @income.distribute_income.should == 150
    end
    
    it "should check if an overflow account exists if the cap has been reached" do
      @accounts[0].stub!(:amount).and_return(50)
      @accounts[0].stub!(:has_reached_cap?).and_return(true)
      @accounts[0].stub!(:cap).and_return(50)
      
      @accounts[0].should_receive(:does_overflow?)
      @accounts[1].should_not_receive(:does_overflow?)
      @accounts[2].should_not_receive(:does_overflow?)
      @income.distribute_income
    end
    
    it "should overflow into the overflow account if the cap has been reached and an overflow account exists" do
      overflow_account = stub_model(Account)
      @accounts[0].should_not_receive(:distribute_use_amount)
      @accounts[0].should_receive(:distribute!).with(1400, @income, 1400).and_return(900)
      
      overflow_account = stub_model(Account)
      @accounts[1].stub!(:amount).and_return(70)
      @accounts[1].stub!(:has_reached_cap?).and_return(true)
      @accounts[1].stub!(:cap).and_return(65)
      @accounts[1].stub!(:does_overflow?).and_return(true)
      @accounts[1].should_receive(:distribute_use_amount).with(900, 900, nil, true).and_return(400)
      overflow_account.should_receive(:distribute_as_overflow!).with(400, @income).and_return(280)
      @accounts[1].stub!(:overflow_into).and_return(overflow_account)
      @accounts[1].should_not_receive(:distribute!)
      
      @accounts[2].should_not_receive(:distribute_use_amount)
      @accounts[2].should_receive(:distribute!).with(780, @income, 900).and_return(130)
      
      @income.distribute_income.should == 130
    end
  end
end
