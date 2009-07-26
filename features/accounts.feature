Feature:  Accounts

	As a User
	I want to be able to manipulate financial accounts on my profile
	So that I can track monthly expenditures
	
	Scenario: Not logged in should disallow access
		Given I am not logged in
		When I go to the New Account page
		Then I should be on the login page
		
	
	Scenario: Add account to user with all valid data
		Given I am logged in as BudgetTest
		And I am on the New Account page
		When I fill in the form for account "New Account 1" with valid data
		And I press "Add Account"
		Then I should be on the Account index page
		And I should see that account in my accounts list
		
	Scenario Outline: Add account with invalid fields
		Given I am logged in as BudgetTest
		And I am on the New Account page
		When I fill in the form for account "<account_name>" with valid data
		And I submit the data "<value1>" for the "<field_type1>" field, "<field_name1>"
		And I submit the data "<value2>" for the "<field_type2>" field, "<field_name2>"
		And I press "Add Account"
		Then I should see an error indicating "<field_name>" "<error>"
		And I should see the rendered template for "the new account page"
		
	Scenarios: missing required fields
		| account_name | value1 | field_type1 | field_name1     | value2 | field_type2 | field_name2 | field_name | error |
		| account1     |        | fill_in     | Name            | | | | Name | can't be blank |
		| account2     |        | select      | Priority        | | | | Priority | can't be blank |
		| account3     |        | fill_in     | Add Per Month   | | | | Add per month | can't be blank |
		
	Scenarios: submitting bad data
		| account_name | value1 | field_type1 | field_name1         | value2 | field_type2 | field_name2              | field_name | error                                      |
		| account4     | Bob    | fill_in     | Add Per Month       | | | | Add per month | is not a number |
		| account5     | 130    | fill_in     | Add Per Month       |        | check       | Add Per Month As Percent | Add per month | cannot be greater than 100% |
		| account7     |        | check       | Has Prerequisite    |        | select      | Prerequisite             | Prerequisite | is required if 'Has Prerequisite' is selected |
		| account8     |        | check       | Has Cap             | Bob    | fill_in     | Cap                      | Cap | is not a number                                 |