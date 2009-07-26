require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe AccountsController do
  describe "GET 'new'" do
  	describe "an anonymous user" do
  	  before(:each) do
  	  	logout_user
  	  end
  	  
      it "should redirect to the login page" do
      	get :new
      	response.should redirect_to(login_users_path)
  	  end
  	  
  	  it "should not execute the #new action" do
  	    controller.should_not_receive(:new)
  	    get :new
	    end
  	end
  	
  	describe "an authenticated user" do
  	  before(:each) do
  	    @login_user = login_as_user
  	    Account.stub!(:new)
  	    Account.stub!(:priority_options)
  	    Account.stub!(:find_all_by_user_id)
	    end
	    
	    it "should receive the #new action" do
	      controller.should_receive(:new)
	      get :new
      end
	    
	    it "should send a new account object to the view" do
	      account = mock_model(Account)
	      Account.should_receive(:new).and_return(account)
	      get :new
	      assigns[:account].should == account
      end
      
      it "should send a list of priorities to the view" do
        priority_options = [1, 3, 5, 8, 10]
        Account.should_receive(:priority_options).and_return(priority_options)
        get :new
        assigns[:priority_options].should == priority_options
      end
      
      it "should send a list of accounts as prerequisites" do
        accounts = [mock_model(Account), mock_model(Account), mock_model(Account)]
        Account.should_receive(:find_all_by_user_id).with(@login_user.id).and_return(accounts)
        get :new
        assigns[:accounts].should == accounts
      end
	  end
  end

  describe "GET 'index'" do
  	describe "an anonymous user" do
  	  before(:each) do
  	    logout_user
	    end
	    
	    it "should redirect to the login page" do
	      get :index
	      response.should redirect_to(login_users_path)
      end
      
      it "should not execute the #index action" do
        controller.should_not_receive(:index)
        get :index
      end
	  end
	  
	  describe "an authenticated user" do
	    before(:each) do
	      login_as_user
      end
    end
  end
  
  describe "POST 'create'" do
    describe "an anonymous user" do
      before(:each) do
        logout_user
      end
      
      it "should redirect to the login page" do
	      post :create
	      response.should redirect_to(login_users_path)
      end
      
      it "should not execute the #index action" do
        controller.should_not_receive(:create)
        post :create
      end
    end
    
    describe 'an authenticated user' do
      before(:each) do
        @login_user = login_as_user
        @valid_params = 
          {:account => 
            {"name" => "actname", "priority" => "7", "add_per_month" => "452", "add_per_month_as_percent" => "0", "has_cap" => "1", "cap" => "204.75", "has_prerequisite" => "0", "prerequisite_id" => "", "enabled" => "1"
          }
        }
        @account = stub_model(Account, :save => true)
        Account.stub!(:new).and_return(@account)
      end
      
      it "should create a new account object" do
        Account.should_receive(:new).with(@valid_params[:account])
        post :create, @valid_params
      end
      
      it "should save the new account" do
        @account.should_receive(:save)
        post :create, @valid_params
      end
      
      context "Valid Save" do
        before(:each) do
          @account.stub!(:save).and_return(true)
        end
        
        it "should redirect to the accounts index page" do
          post :create, @valid_params
          response.should redirect_to accounts_path
        end
      end
      
      context "Invalid Save" do
        before(:each) do
          @account.stub!(:save).and_return(false)
          Account.stub!(:find_all_by_user_id)
          Account.stub!(:priority_options)
        end
        
        it "should render the 'new' account page" do
          post :create, @valid_params
          response.should render_template 'accounts/new.html.erb'
        end
        
        it "should send the account object to the view" do
  	      post :create, @valid_params
  	      assigns[:account].should == @account
        end
        
        it "should send a list of priorities to the view" do
          priority_options = [1, 3, 5, 8, 10]
          Account.should_receive(:priority_options).and_return(priority_options)
          post :create, @valid_params
          assigns[:priority_options].should == priority_options
        end
        
        it "should send a list of accounts as prerequisites" do
          accounts = [mock_model(Account), mock_model(Account), mock_model(Account)]
          Account.should_receive(:find_all_by_user_id).with(@login_user.id).and_return(accounts)
          post :create, @valid_params
          assigns[:accounts].should == accounts
        end 
      end
    end
  end
end
