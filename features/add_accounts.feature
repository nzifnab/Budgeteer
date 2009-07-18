Feature:  Add Accounts

	As a User
	I want to be able to add financial accounts to my profile
	So that I can track monthly expenditures
	
	Scenario: Add account to user
		Given I am logged in as BudgetTest
		And I am on the Add Account page
		When I create account "New Account 1"
		Then I should be on the Account index page
		And I should see that account in my accounts list