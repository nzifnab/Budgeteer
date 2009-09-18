Given /^I have created some accounts$/ do
  @accounts = []
  @accounts << Account.create!( :name => 'name1', :priority => 1, :add_per_month => 15, :add_per_month_as_percent => true, :amount => 83, :enabled => true, :user_id => @user.id )
  @accounts << Account.create!( :name => 'name2', :priority => 1, :add_per_month => 5, :add_per_month_as_percent => true, :enabled => true, :user_id => @user.id )
  @accounts << Account.create!( :name => 'name3', :priority => 1, :add_per_month => 25, :add_per_month_as_percent => false, :enabled => true, :user_id => @user.id )
  @accounts << Account.create!( :name => 'name4', :priority => 3, :add_per_month => 200, :add_per_month_as_percent => false, :amount => 142, :cap => 300, :enabled => true, :user_id => @user.id )
  #disabled
  @accounts << Account.create!( :name => 'name5', :priority => 3, :add_per_month => 8, :add_per_month_as_percent => true, :amount => 50, :enabled => false, :user_id => @user.id )
  @accounts << Account.create!( :name => 'name6', :priority => 4, :add_per_month => 18, :add_per_month_as_percent => true, :amount => 395, :cap => 425, :enabled => true, :user_id => @user.id )
  #prerequisite = 'name4'
  @accounts << Account.create!( :name => 'name7', :priority => 2, :add_per_month => 25, :add_per_month_as_percent => true, :prerequisite => @accounts[3], :cap => 300, :enabled => true, :user_id => @user.id )
  @accounts << Account.create!( :name => 'name8', :priority => 5, :add_per_month => 150, :add_per_month_as_percent => false, :amount => 50, :cap => 200, :enabled => true, :user_id => @user.id )
  @accounts << Account.create!( :name => 'name9', :priority => 5, :add_per_month => 25, :add_per_month_as_percent => true, :amount => 10, :cap => 600, :enabled => true, :user_id => @user.id )
  #prerequisite = 'name9'
  @accounts << Account.create!( :name => 'name10', :priority => 5, :add_per_month => 30, :add_per_month_as_percent => true, :prerequisite => @accounts[8], :enabled => true, :user_id => @user.id )
  #disabled
  @accounts << Account.create!( :name => 'name11', :priority => 8, :add_per_month => 80, :add_per_month_as_percent => false, :prerequisite => @accounts[5], :cap => 100, :enabled => false, :user_id => @user.id )
  @accounts << Account.create!( :name => 'name12', :priority => 8, :add_per_month => 80, :add_per_month_as_percent => true, :amount => -300, :cap => 0, :enabled => true, :user_id => @user.id )
  @accounts << Account.create!( :name => 'name13', :priority => 10, :add_per_month => 100, :add_per_month_as_percent => true, :amount => 50, :enabled => true, :user_id => @user.id )
  #different user
  @accounts << Account.create!( :name => 'name14', :priority => 4, :add_per_month => 50, :add_per_month_as_percent => true, :amount => 25, :enabled => true, :user => User.create!(:username => 'otherguy', :password => 'hispass'))
  #prerequisite = 'name8'
  @accounts << Account.create!( :name => 'name15', :priority => 5, :add_per_month => 100, :add_per_month_as_percent => false, :prerequisite => @accounts[7], :enabled => true, :user_id => @user.id )
  @accounts << Account.create!( :name => 'name16', :priority => 6, :add_per_month => 150, :add_per_month_as_percent => false, :amount => 300, :cap => 300, :enabled => true, :user_id => @user.id )
  #prerequisite = 'name16'
  @accounts << Account.create!( :name => 'name17', :priority => 7, :add_per_month => 30, :add_per_month_as_percent => true, :prerequisite => @accounts[15], :enabled => true, :user_id => @user.id )
  @accounts << Account.create!( :name => 'name18', :priority => 9, :add_per_month => 10, :add_per_month_as_percent => true, :enabled => true, :user_id => @user.id )
  #overflows_into = 'name18'
  @accounts << Account.create!( :name => 'name19', :priority => 9, :add_per_month => 50, :add_per_month_as_percent => false, :amount => 45, :cap => 55, :overflow_into => @accounts[17], :enabled => true, :user_id => @user.id)
end

When /^I send an income amount$/ do
  @income_amount = 1400
  @income_description = "I'm making monlies ^.^"
  fill_in( "income_amount", :with => @income_amount )
  fill_in( "income_description", :with => @income_description )
  click_button("Submit Income")
end

Then /^my funds should be distributed correctly$/ do
  @new_accounts = []
  @samounts = {
    "name1" => 293.0,
    "name2" => 70.0,
    "name3" => 25.0,
    "name4" => 300.0,
    "name5" => 50.0,
    "name6" => 425.0,
    "name7" => 42.0,
    "name8" => 200.0,
    "name9" => 226.25,
    "name10" => 0,
    "name11" => 0,
    "name12" => -76.7, #->55.825
    "name13" => 50.2425, #45.2425, :0.2425(50.2425), ->0
    "name14" => 25.0,
    "name15" => 100.0,
    "name16" => 300.0,
    "name17" => 119.625,
    "name18" => 45.5825, #50.5825,   :5.5825, ->50.2425 (first pass), :40(45.5825), ->0.2425 (overflow pass)
    "name19" => 55, # :10(55), ->40.2425 (overflow 40 to #18)
  }
  
  @accounts.each do |account|
    @new_accounts << Account.find(account)
    amount = @new_accounts.last.amount
    amount.should == @samounts[account.name]
  end
end

Then /^I should see how my funds were distributed$/ do
  pending
  @accounts.each do |account|
    changed = @samounts[account.name] - account.amount
    if changed != 0
      response.should contain("Change:#{changed}")
    end
  end
end

Then /^The income form should retain its data$/ do
  @income_amount = -200
  @income_description = "negative INCOME...?"
  field_with_id("income_amount").value.to_f.should == @income_amount
  field_with_id("income_description").value.should == @income_description
end

Then /^each account should not have an updated amount$/ do
  @accounts.each do |account|
    Account.find(account.id).amount.should == account.amount
  end
end