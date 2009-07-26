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

When /^I submit the data "([^\"]*)" for the "([^\"]*)" field, "([^\"]*)"$/ do |value,field_type,field_name|
  case field_type
  when 'fill_in'
    fill_in(field_name, :with => value)
  when 'select'
    select(value, :from => field_name)
  when 'check'
    check(field_name)
  when 'uncheck'
    uncheck(field_name)
  end
end

Then /^I should see that account in my accounts list$/ do
  pending
  response.should contain(@account_name)
end

Then /^I should see the rendered template for "([^\"]*)"$/ do |path_name|
  template = (path_to(path_name) + ".html.erb")[1..-1]
  response.should render_template template
end

Then /^I should see an error indicating "([^\"]*)" "([^\"]*)"$/ do |field_name,error_message|
  response.should contain( field_name + " " + error_message )
end