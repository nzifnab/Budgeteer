Given /^I am logged in as (.*)$/ do |user_name|
  @username = user_name
  @password = "5678"
  @user = User.create!(:username => @username, :password => @password)
  @field_values = []
  visit login_users_path
  fill_in("username", :with => @username)
  fill_in("password", :with => @password)
  click_button("Login")
end

Given /^I am not logged in$/ do
end

Given /^I have created (\d+) enabled accounts?, and (\d+) disabled ones?$/ do |enabled, disabled|
  @enabled_accounts = []
  @enabled_account_params = []
  enabled.to_i.times do |i|
    params = {:name => "actname#{i}", :priority => "#{i+1}", :add_per_month => "#{7+(i*9)}", :add_per_month_as_percent => "0",  :cap => "#{200+(i*31)}", :enabled => "1", :user_id => @user.id, :amount => "#{345.15+(i*41)}"}
    @enabled_account_params << params
    @enabled_accounts << Account.create!(params)
  end
  
  @disabled_accounts = []
  @disabled_account_params = []
  disabled.to_i.times do |i|
    params = {:name => "actname#{i+enabled.to_i}", :priority => "#{i}", :add_per_month => "#{4+(i*5)}", :add_per_month_as_percent => "0", :cap => "#{100+(i*50)}", :enabled => "0", :user_id => @user.id, :amount => "#{249.85+(i*38)}"}
    @disabled_account_params << params
    @disabled_accounts << Account.create!(params)
  end
end

Given /^I am working with the ([\d]+)(st|nd|rd|th) (enabled|disabled) account$/ do |index, suffix, enabled_or_disabled|
  if enabled_or_disabled == "enabled"
    account_array = @enabled_accounts
  elsif enabled_or_disabled == "disabled"
    account_array = @disabled_accounts
  end
  
  @account = account_array[index.to_i - 1]
end

Given /^I am visiting (.*) for the ([\d]+)(st|nd|rd|th) (enabled|disabled) account$/ do |page_name, index, suffix, enabled_or_disabled|
  if enabled_or_disabled == "enabled"
    account_array = @enabled_accounts
  else
    account_array = @disabled_accounts
  end
  
  @account = account_array[index.to_i - 1]
  @account_name = @account.name
  
  name = page_name + " for " + account_array[index.to_i - 1].name
  visit path_to(name)
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
    @field_values << { field_name => value }
    fill_in(field_name, :with => value)
  when 'select'
    if field_name == "Prerequisite" && value.to_i > 0
      value = @enabled_accounts[value.to_i].name
    end
    @field_values << { field_name => value }
    select(value, :from => field_name)
  when 'check'
    @field_values << { field_name => true }
    check(field_name)
  when 'uncheck'
    @field_values << { field_name => false }
    uncheck(field_name)
  end
end

When /^I am about to submit the data for the account$/ do
  fill_in("Name", :with => @account.name)
  select(@account.priority.to_s, :from => "Priority")
  fill_in("Add Per Month", :with => @account.add_per_month)
  
  if @account.add_per_month_as_percent
    check("Add Per Month As Percent")
  else
    uncheck("Add Per Month As Percent")
  end
  
  if @account.has_cap?
    check("Has Cap")
  else
    uncheck("Has Cap")
  end
  
  if @account.has_prerequisite?
    check("Has Prerequisite")
  else
    uncheck("Has Prerequisite")
  end
  
  if @account.enabled
    check("Enabled")
  else
    uncheck("Enabled")
  end
end

When /^I (withdraw|deposit) "([^\"]*)" with the description "([^\"]*)"$/ do |withdraw_or_deposit, amount, description|
  @amount = amount
  @description = description
  fill_in("account_history_amount_#{@account.id}", :with => @amount)
  fill_in("account_history_description_#{@account.id}", :with => @description)

  if withdraw_or_deposit == "withdraw"
    @new_amount = @account.amount - @amount.to_f
    click_button("withdraw_#{@account.id}")
  elsif withdraw_or_deposit == "deposit"
    @new_amount = @account.amount + @amount.to_f
    click_button("deposit_#{@account.id}")
  end
end

When /^I click on the "([^\"]*)" link for the ([\d]+)(st|nd|rd|th) (enabled|disabled) account$/ do |link_name, index, suffix, enabled_or_disabled|
  if enabled_or_disabled == "enabled"
    account_array = @enabled_accounts
  else
    account_array = @disabled_accounts
  end
  
  @account = account_array[index.to_i - 1]
  @account_name = @account.name
  name = link_name + "_account_" + @account.id.to_s
  click_link(name)
end

def verify_account_values(account)
  response.should contain(account.name)
  response.should contain("Added per month:$#{account.add_per_month}")
  
  if account.has_cap?
    response.should contain("Cap:$#{account.cap}")
  else
    response.should contain("Cap:NONE")
  end
  
  response.should contain("Amount:$#{account.amount}")
  response.should contain("Priority:#{account.priority}")
  
  if account.has_prerequisite?
    response.should contain("Prerequisite:#{account.prerequisite.name}")
  else
    response.should contain("Prerequisite:NONE")
  end
end

Then /^I should see all of my accounts listed$/ do
  @enabled_accounts.each do |account|
    verify_account_values(account)
  end
  
  @disabled_accounts.each do |account|
    verify_account_values(account)
  end
end

Then /^I should see that account in my accounts list$/ do
    response.should contain(@account_name)
end

Then /^I should see the rendered template for "([^\"]*)"$/ do |path_name|
  template = (path_to(path_name) + ".html")[1..-1]
  response.should render_template(template)
end

Then /^I should see an error indicating "([^\"]*)" "([^\"]*)"$/ do |field_name,error_message|
  response.should contain( field_name + " " + error_message )
end

Then /^I should be redirected to (.*)$/ do |page_name|
  page_name += " for " + @account.name
  URI.parse(current_url).path.should == path_to(page_name)
end

Then /^I should see the correct amount on the account$/ do
  response.should contain("Amount:$#{@new_amount}")
  Account.find(@account.id).amount.to_s.should == @new_amount.to_s
end

Then /^the account history form fields should retain their data$/ do
  field_with_id("account_history_amount_#{@account.id}").value.should == "#{@amount}"
  field_with_id("account_history_description_#{@account.id}").value.should == "#{@description}"
end