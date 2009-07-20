require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe UsersController do
	before(:each) do
		@username = "my_name"
		@password = "my_password"
		@user = User.create!(:username => @username, :password => @password)
	end
		
	describe "#enter" do
		
		it "should validate the user's credentials" do
			User.should_receive(:authenticate).with(@username, @password)
			post :enter, :user => {"username" => @username, "password" => @password}
		end
		
		context "Valid Credentials" do
			before(:each) do
				User.stub!(:authenticate).and_return(true)
			end
			
			it "should set the user's id in the session" do
				post :enter, :user => {:username => @username, :password => @password}
				session.should have_key("user_id")
				session[:user_id].should == @user.id
			end
			
			it "should redirect to the account index page" do
				post :enter, :user => {:username => @username, :password => @password}
				response.should redirect_to(accounts_path)
			end
			
			it "should flash a message to the user indicating a successful login" do
				post :enter, :user => {:username => @username, :password => @password}
				flash[:notice].should =~ /Login Successful/
			end
		end
		
		context "Invalid Credentials" do
			before(:each) do
				User.stub!(:authenticate).and_return(false)
			end
			
			it "should force the session's user_id to be nil" do
				session[:user_id] = 45
				post :enter, :user => {:username => "BadUser", :password => @password}
				session[:user_id].should be_blank
			end
			
			it "should redirect to the login page" do
				post :enter, :user => {:username => "BadUser", :password => @password}
				response.should redirect_to(login_users_path)
			end
			
			it "should flash a warning indicating invalid credentials" do
				post :enter, :user => {:username => "BadUser", :password => @password}
				flash[:warning].should =~ /Invalid Username or Password/
			end
		end
	end
	
	describe "#current_user" do
	  it "should give me a valid user if I am logged in" do
	    session[:user_id] = @user.id
	    user = controller.current_user
	    user.should == @user
    end
	  
	  it "should return false if I am not logged in" do
	    controller.current_user.should be_false
    end
  end
end
