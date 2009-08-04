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

Given /^I have created (\d+) enabled accounts, and (\d+) disabled ones$/ do |enabled, disabled|
  @enabled_accounts = []
  enabled.to_i.times do |i|
    @enabled_accounts << Account.create!(:name => "actname#{i}", :priority => "#{i}", :add_per_month => "#{7+(i*9)}", :add_per_month_as_percent => "0",  :cap => "#{200+(i*31)}", :enabled => "1", :user_id => @user.id, :amount => 345.15)
  end
  
  @disabled_accounts = []
  disabled.to_i.times do |i|
    @disabled_accounts << Account.create!(:name => "actname#{i+enabled.to_i}", :priority => "#{i}", :add_per_month => "#{4+(i*5)}", :add_per_month_as_percent => "0", :cap => "#{100+(i*50)}", :enabled => "0", :user_id => @user.id, :amount => 249.85)
  end
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


Then /^I should see all of my accounts listed$/ do
  @enabled_accounts.each do |account|
    response.should contain(account.name)
    response.should contain("Added per month: $#{account.add_per_month}")
    response.should contain("Cap: $#{account.cap}")
    response.should contain("Amount: $#{account.amount}")
  end
  
  @disabled_accounts.each do |account|
    response.should contain(account.name)
    response.should contain("Added per month: $#{account.add_per_month}")
    response.should contain("Cap: $#{account.cap}")
    response.should contain("Amount: $#{account.amount}")
  end
end

Then /^I should see that account in my accounts list$/ do
    response.should contain(@account_name)
end

Then /^I should see the rendered template for "([^\"]*)"$/ do |path_name|
  template = (path_to(path_name) + ".html.erb")[1..-1]
  response.should render_template template
end

Then /^I should see an error indicating "([^\"]*)" "([^\"]*)"$/ do |field_name,error_message|
  response.should contain( field_name + " " + error_message )
end