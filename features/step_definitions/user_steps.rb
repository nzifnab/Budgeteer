Given /^my username is "([^\"]*)" and password is "([^\"]*)"$/ do |username, password|
	@username = username
	@password = password
	@user = User.create!(:username => @username, :password => @password)
end

When /^I fill in my valid credentials$/ do
	fill_in("user[username]", :with => @username)
	fill_in("user[password]", :with => @password)
end

When /^I use an invalid (.*)$/ do |invalid_field|
	fill_in("user[username]", :with => @username)
	fill_in("user[password]", :with => @password)
  	fill_in(invalid_field, :with => "BadData")
end

Then /^I should be logged in$/ do
	session[:user_id].should == @user.id
end

Then /^I should not be logged in$/ do
  	session[:user_id].should be_blank
end