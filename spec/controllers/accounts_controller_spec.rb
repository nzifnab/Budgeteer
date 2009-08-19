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
	      @user = login_as_user
      end
      
      it "should send the accounts associated to the user to the view" do
        accounts = [stub_model(Account, :user => @user), stub_model(Account, :user => @user), stub_model(Account, :user => @user)]
        Account.should_receive(:find_all_by_user_id).with(@user.id, :order => "enabled DESC, priority ASC, amount DESC, name ASC" ).and_return(accounts)
        get :index
        assigns[:accounts].should == accounts
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
      
      it "should set the user id to the account" do
        @account.should_receive(:user_id=).with(@login_user.id)
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
          response.should redirect_to(:action => 'index', :account_id => @account.id)
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
          response.should render_template('accounts/new.html.haml')
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
  
  describe "GET 'edit'" do
    before(:each) do
  	  @account = stub_model(Account)
    end
    
    describe "an anonymous user" do
  	  before(:each) do
  	  	logout_user
  	  end
  	  
      it "should redirect to the login page" do
      	get :edit, :id => @account.id
      	response.should redirect_to(login_users_path)
  	  end
  	  
  	  it "should not execute the #edit action" do
  	    controller.should_not_receive(:edit)
  	    get :edit, :id => @account.id
	    end
  	end
  	
  	describe "an authenticated user" do
  	  before(:each) do
  	    @login_user = login_as_user
  	    Account.stub!(:new)
  	    Account.stub!(:priority_options)
  	    Account.stub!(:find_all_by_user_id)
  	    Account.stub!(:find).and_return(@account)
	    end
	    
	    context "edits an account that belongs to them" do
	      before(:each) do
  	      @account.stub!(:user).and_return(@login_user)
        end
        
  	    it "should receive the #edit action" do
  	      controller.should_receive(:edit)
  	      get :edit, :id => @account.id
        end
  	    
  	    it "should send the account object to the view" do
  	      Account.should_receive(:find).with(@account.id.to_s).and_return(@account)
  	      get :edit, :id => @account.id
  	      assigns[:account].should == @account
        end
        
        it "should send a list of priorities to the view" do
          priority_options = [1, 3, 5, 8, 10]
          Account.should_receive(:priority_options).and_return(priority_options)
          get :edit, :id => @account.id
          assigns[:priority_options].should == priority_options
        end
        
        it "should send a list of accounts as prerequisites" do
          accounts = [mock_model(Account), mock_model(Account), mock_model(Account)]
          Account.should_receive(:find_all_by_user_id).with(@login_user.id).and_return(accounts)
          get :edit, :id => @account.id
          assigns[:accounts].should == accounts
        end
      end
      
      context "tries to visit the edit page for an account that does not belong to them" do
        before(:each) do
			    fake_user = stub_model(User)
			    @account.stub!(:user).and_return fake_user
        end
        
        it "should redirect to the account index page" do
          get :edit, :id => @account.id
          response.should redirect_to(accounts_path)
          flash[:warning].should == "Account does not exist"
        end
      end
	  end
  end

	describe "PUT 'update'" do
		before(:each) do
			@account = stub_model(Account)
			Account.stub!(:find).and_return(@account)
			@valid_params = 
					{"name" => "actname", "priority" => "7", "add_per_month" => "452", "add_per_month_as_percent" => "0", "has_cap" => "1", "cap" => "204.75", "has_prerequisite" => "0", "prerequisite_id" => "", "enabled" => "1"
					}
		end

		describe "an anonymous user" do
			before(:each) do
				logout_user
			end

			it "should redirect to the login page" do
				put :update, :id => @account.id
				response.should redirect_to(login_users_path)
			end
			
			it "should not execute the #update action" do
				controller.should_not_receive(:update)
				put :update, :id => @account.id
			end
		end

		describe "an authenticated user" do
			before(:each) do
				@login_user = login_as_user
			end

			it "should find the account by it's id" do
				Account.should_receive(:find).with(@account.id.to_s).and_return(@account)
				put :update, :id => @account.id
			end

			context "edits an account that belongs to them" do
			  before(:each) do
			    @account.stub!(:user).and_return @login_user
		    end
		    
				it "should update the attributes with the passed parameters" do
					@account.should_receive(:update_attributes).with(@valid_params)

					put :update, { :id => @account.id, :account => @valid_params }
				end

				context "- update successful" do
				  before( :each ) do
				    @account.stub!(:update_attributes).and_return true
			    end
			    
					it "should redirect to the index page" do
					  put :update, { :id => @account.id, :account => @valid_params }
						response.should redirect_to(:action => 'index', :account_id => @account.id)
					end
					
					it "should flash a notice to the user about a successful update" do
					  put :update, { :id => @account.id, :account => @valid_params }
					  flash[:notice].should == "Editing account was successful."
				  end
				  
  				it "should send the edited account to the view" do
  				  put :update, { :id => @account.id, :account => @valid_params }
  				  assigns[:account].should == @account
  			  end
				end
				
				context "- update unsucessful" do
				  before( :each ) do
				    @account.stub!(:update_attributes).and_return false
			    end
			    
				  it "should render the edit page" do
				    put :update, { :id => @account.id, :account => @valid_params }
				    response.should render_template('accounts/edit.html')
			    end
			    
			    it "should flash an error to the user" do
			      put :update, { :id => @account.id, :account => @valid_params }
			      flash[:warning].should == "An error has ocurred when updating the account."
		      end
				  
  				it "should send the edited account to the view" do
  				  put :update, { :id => @account.id, :account => @valid_params }
  				  assigns[:account].should == @account
  			  end
			  end
			end
			
			context "tries to edit an account that does not belong to them" do
			  before(:each) do
			    fake_user = stub_model(User)
			    @account.stub!(:user).and_return fake_user
		    end
		    
			  it "should redirect to the account index page" do
			    @account.should_not_receive(:update_attributes)
			    put :update, { :id => @account.id, :account => @valid_params }
			    response.should redirect_to(accounts_path)
			    flash[:warning].should == "Account does not exist"
		    end
		  end
		end
	end
	
	describe "PUT #changefunds" do
	  before(:each) do
			@account = stub_model(Account)
			Account.stub!(:find).and_return(@account)
		end
		
		describe "an anonymous user" do
		  before(:each) do
		    logout_user
	    end
	    
	    it "should redirect to the login page" do
				put :changefunds, :id => @account.id
				response.should redirect_to(login_users_path)
			end
			
			it "should not execute the #update action" do
				controller.should_not_receive(:update)
				put :changefunds, :id => @account.id
			end
	  end
	  
	  describe "an authenticated user" do
	    before(:each) do
				@login_user = login_as_user
				@account = stub_model(Account, :amount => 572.84)
				@account_history = stub_model(AccountHistory).as_new_record
				@account.stub!(:save)
				@account_history.stub!(:save)
				@account_history.stub!(:account=)
				Account.stub!(:find).and_return(@account)
				AccountHistory.stub!(:new).and_return(@account_history)
				@params = {"id" => @account.id, "account_history" => {"amount" => "72.49", "description" => "The monkies stole it all"}}
			end
			
		  it "should get the account object" do
		    Account.should_receive(:find).with(@account.id.to_s).and_return(@account)
		    put :changefunds, @params
	    end
	    
      it "should add the account to the histories" do
        @account_history.should_receive(:account=).with(@account)
        put :changefunds, @params
      end
      
      it "should render the index action" do
        put :changefunds, @params
        response.should render_template('accounts/index')
      end
	    
	    context "submits the withdraw command" do
	      before(:each) do
	        @params["commit"] = "Withdraw"
        end
        
        
        it "should create a new account history object" do
          received_params = @params["account_history"].clone
          received_params["amount"] = (received_params["amount"].to_f * (-1)).to_s
          AccountHistory.should_receive(:new).with(received_params).and_return(@account_history)
          put :changefunds, @params
        end
        
        it "should add the account to the histories" do
          @account_history.should_receive(:account=).with(@account)
          put :changefunds, @params
        end
        
        it "should save the account histories object" do
          @account_history.should_receive(:save)
          put :changefunds, @params
        end
        
        context "- account histories save (success)" do
          before(:each) do
            @account_history.stub!(:save).and_return(true)
          end
          
          it "should reduce the amount on the account" do
            @account.should_receive(:amount=).with(@account.amount - @params["account_history"]["amount"].to_f)
            put :changefunds, @params
          end
          
          it "should save the account object" do
            @account.should_receive(:save)
            put :changefunds, @params
          end
          
          context "- account save (success)" do
            before(:each) do
              @account.stub!(:save).and_return(true)
            end
            
            it "should send the account object to the view" do
              put :changefunds, @params
              assigns[:account].should == @account
            end
            
            it "should flash a success message" do
              put :changefunds, @params
              flash[:notice].should == "Withdraw successful"
            end
          end
        end
        
        context "- account histories save (no success)" do
          before(:each) do
            @account_history.stub!(:save).and_return(false)
          end
          
          it "should not reduce the amount on the account" do
            @account.should_not_receive(:amount=)
            put :changefunds, @params
          end
          
          it "should send a nil account object to the view" do
            put :changefunds, @params
            assigns[:account].should be_nil
          end
          
          it "should flash an error message to the user" do
            put :changefunds, @params
            flash[:warning].should == "Error occurred"
          end
          
          it "should send the account history object to the view" do
            put :changefunds, @params
            assigns[:account_history].should == @account_history
          end
        end
      end
      
      context "submits the deposit command" do
	      before(:each) do
	        @params["commit"] = "Deposit"
        end
        
        
        it "should create a new account history object" do
          AccountHistory.should_receive(:new).with(@params["account_history"]).and_return(@account_history)
          put :changefunds, @params
        end
        
        
        it "should save the account histories object" do
          @account_history.should_receive(:save)
          put :changefunds, @params
        end
        
        context "- account histories save (success)" do
          before(:each) do
            @account_history.stub!(:save).and_return(true)
          end
          
          it "should increase the amount on the account" do
            @account.should_receive(:amount=).with(@account.amount + @params["account_history"]["amount"].to_f)
            put :changefunds, @params
          end
          
          it "should save the account object" do
            @account.should_receive(:save)
            put :changefunds, @params
          end
          
          context "- account save (success)" do
            before(:each) do
              @account.stub!(:save).and_return(true)
            end
            
            it "should send the account object to the view" do
              put :changefunds, @params
              assigns[:account].should == @account
            end
            
            it "should flash a success message" do
              put :changefunds, @params
              flash[:notice].should == "Deposit successful"
            end
          end
        end
        
        context "- account histories save (no success)" do
          before(:each) do
            @account_history.stub!(:save).and_return(false)
          end
          
          it "should not reduce the amount on the account" do
            @account.should_not_receive(:amount=)
            put :changefunds, @params
          end
          
          it "should send a nil account object to the view" do
            put :changefunds, @params
            assigns[:account].should be_nil
          end
          
          it "should flash an error message to the user" do
            put :changefunds, @params
            flash[:warning].should == "Error occurred"
          end
          
          it "should send the account history object to the view" do
            put :changefunds, @params
            assigns[:account_history].should == @account_history
          end
        end
      end
    end
  end
end
