Feature Incomes

  As a user
  I want to have my income automatically routed into spending accounts
  So that I know what I have available to spend on various merchandise
  
  Scenario: Add income instance
    Given I am logged in as BudgetTest
    And I have created some accounts
    And I am on the Account index page
    When I send an income amount
    Then my funds should be distributed correctly
    And I should see how my funds were distributed
    
  Scenario: Income - disallow negative
    Given I am logged in as BudgetTest
    And I have created some accounts
    And I am on the Account index page
    When I fill in "income_amount" with "-200"
    And I fill in "description" with "negative INCOME...?"
    And I press "Submit Income"
    Then I should see "Amount must be greater than 0"
    And The income form should retain its data
    And each account should not have an updated amount