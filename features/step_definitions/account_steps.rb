Given /^I am logged in as (.*)$/ do |user_name|
  @username = user_name
  @password = "5678"
  @user = User.create!(:username => @username, :password => @password)
  visit login_users_path
  fill_in("username", :with => @username)
  fill_in("password", :with => @password)
  click_button("Login")
end

Given /^I am not logged in$/ do
end

When /^I fill in the form for account "([^\"]*)" with valid data$/ do |account_name|
  @account_name = account_name
  fill_in("Name", :with => @account_name)
  select("3", :from => "Priority")
  fill_in("Add Per Month", :with => 30)
  uncheck("Add Per Month As Percent")
  uncheck("Has Cap")
  uncheck("Has Prerequisite")
  check("Enabled")
end

Then /^I should see that account in my accounts list$/ do
  response.should contain(@account_name)
end