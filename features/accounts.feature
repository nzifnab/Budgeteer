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
		And I press "Submit"
		Then I should be on the Account index page
		And I should see that account in my accounts list
		
	@error
	Scenario Outline: Add account with invalid fields
		Given I am logged in as BudgetTest
		And I am on the New Account page
		When I fill in the form for account "<account_name>" with valid data
		And I submit the data "<value1>" for the "<field_type1>" field, "<field_name1>"
		And I submit the data "<value2>" for the "<field_type2>" field, "<field_name2>"
		And I press "Submit"
		Then I should see an error indicating "<field_name>" "<error>"
		And I should see the rendered template for "the new account page"
		
	Scenarios: missing required fields
		| account_name | value1 | field_type1 | field_name1     | value2 | field_type2 | field_name2 | field_name | error |
		| account1     |        | fill_in     | Name            | | | | Name | can't be blank |
		| account2     |        | select      | Priority        | | | | Priority | can't be blank |
		| account3     |        | fill_in     | Add Per Month   | | | | Add per month | can't be blank |
		
	Scenarios: submitting bad data
		| account_name | value1 | field_type1 | field_name1         | value2 | field_type2 | field_name2              | field_name | error      |
		| account4     | Bob    | fill_in     | Add Per Month       | | | | Add per month | is not a number |
		| account5     | 130    | fill_in     | Add Per Month       |        | check       | Add Per Month As Percent | Add per month | cannot be greater than 100% |
		| account7     |        | check       | Has Prerequisite    |        | select      | Prerequisite             | Prerequisite | is required if 'Has Prerequisite' is selected |
		| account8     |        | check       | Has Cap             | Bob    | fill_in     | Cap                      | Cap | is not a number   |
		| account9     |        | check       | Does Overflow       |        | select      | Overflows Into           | Overflow into | is required if 'Does Overflow' is selected |
		
		
  Scenario: Accounts display on account index page
    Given I am logged in as BudgetTest
    And I have created 5 enabled accounts, and 3 disabled ones
    When I go to the Account index page
    Then I should see all of my accounts listed
    
  Scenario: Edit button links to edit page
    Given I am logged in as BudgetTest
    And I have created 2 enabled accounts, and 2 disabled ones
    And I am on the Account index page
    When I click on the "edit" link for the 2nd enabled account
    Then I should be redirected to the edit account page
    
  Scenario Outline: Edit account
    Given I am logged in as BudgetTest
    And I have created 4 enabled account, and 0 disabled ones
    And I am visiting the edit account page for the 1st enabled account
    When I am about to submit the data for the account
    And I submit the data "<value1>" for the "<field_type1>" field, "<field_name1>"
    And I submit the data "<value2>" for the "<field_type2>" field, "<field_name2>"
    And I press "Submit"
    Then I should see the rendered template for "the Account main page"
    And I should see "Editing account was successful."
    
  Scenarios: Editing fields
    | value1    | field_type1 | field_name1     | value2 | field_type2 | field_name2              |
    | newname   | fill_in     | Name            ||||
    | 1         | select      | Priority        ||||
    | 28        | fill_in     | Add Per Month   |        | check       | Add Per Month As Percent |
    |           | uncheck     | Has Cap         ||||
    |           | check       | Has Prerequisite | 1     | select      | Prerequisite             |
    |           | uncheck     | enabled         ||||
    
  Scenario: Withdraw from account
    Given I am logged in as BudgetTest
    And I have created 3 enabled account, and 0 disabled ones
    And I am working with the 2nd enabled account
    And I am on the Account index page
    When I withdraw "40.35" with the description "Groceries!"
    Then I should be on the Account index page
    And I should see "Withdraw successful"
    And I should see the correct amount on the account

  Scenario: Withdraw from account - Insufficient funds (allow negative amount)
    Given I am logged in as BudgetTest
    And I have created 1 enabled account, and 0 disabled ones
    And I am working with the 1st enabled account
    And I am on the Account index page
    When I withdraw "800.71" with the description "Prison fees"
    Then I should be on the Account index page
    And I should see "Withdraw successful"
    And I should see the correct amount on the account
    
  Scenario: Deposit into account
    Given I am logged in as BudgetTest
    And I have created 3 enabled account, and 0 disabled ones
    And I am working with the 3rd enabled account
    And I am on the Account index page
    When I deposit "71.48" with the description "Bum on the street o.o"
    Then I should be on the Account index page
    And I should see "Deposit successful"
    And I should see the correct amount on the account
    
  @error
  Scenario: Withdraw from account, bad value
    Given I am logged in as BudgetTest
    And I have created 1 enabled account, and 0 disabled ones
    And I am working with the 1st enabled account
    And I am on the Account index page
    When I withdraw "Forty Numeros Unos" with the description "Spenglish"
    Then I should see the rendered template for "the Account main page"
    And I should see "Error Occurred"
    And the account history form fields should retain their data
    And I should see the correct amount on the account
    
  @error
  Scenario: Deposit to account, bad value
    Given I am logged in as BudgetTest
    And I have created 1 enabled account, and 0 disabled ones
    And I am working with the 1st enabled account
    And I am on the Account index page
    When I deposit "$80 dollars" with the description "Verbatim"
    Then I should see the rendered template for "the Account main page"
    And I should see "Error Occurred"
    And the account history form fields should retain their data
    And I should see the correct amount on the account