Feature:  Login

	As a user
	I want to be able to login
	So that I can use the budget application
	
	Scenario: Login
		Given my username is "BudgetTest" and password is "abcd"
		When I go to the login page
		And I fill in my valid credentials
		And I press "Login"
		Then I should be logged in
		And I should be on the Account index page
		
	Scenario: Login Failure - Bad Username
		Given my username is "BudgetTest" and password is "abcd"
		When I go to the login page
		And I use an invalid username
		And I press "Login"
		Then I should not be logged in
		And I should be on the login page
		And I should see "Invalid Username or Password"
		
	Scenario: Login Failure - Bad Password
		Given my username is "BudgetTest" and password is "abcd"
		When I go to the login page
		And I use an invalid password
		And I press "Login"
		Then I should not be logged in
		And I should be on the login page
		And I should see "Invalid Username or Password"