require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe User do
	before(:each) do
		@username = "MyName"
		@password = "5678"
		@password_hash = "674f3c2c1a8a6f90461e8a66fb5550ba"
	end
	
	describe "#password=" do
		it "should save the password_hash as an MD5 digest" do
			user = User.new(:username => @username)
			user.password = @password
			user.password_hash.should == @password_hash
		end
	end
	
	describe "#authenticate" do
		before(:each) do
			@user = User.create!(:username => @username, :password => @password)
		end
		
		it "should return true if a matching username and password are sent" do
			User.authenticate(@username, @password).should be_true
		end
		
		it "should return false if the username is not found" do
			User.authenticate("BadUser", @password).should be_false
		end
		
		it "should return false if the password doesn't match the user's" do
			User.authenticate(@username, "badpass").should be_false
		end
	end
end
