@ignore
Feature: Visitor registers interest

  As a visitor
  I want to register my interest
  So that I can receive an invitation and create an account
  
  Scenario: Visitor registers interest
    Given no user exists with email "james@example.com"
    
    When I go to the home page
    And I follow "Sign Up"
    
    Then I should be on the registration page
    
    When I fill in "Email" with "james@example.com"
    And I press "Sign Up"
    
    Then I should be on the home page
    And I should see "Registration successful"
    
  Scenario: Visitor registers interest, but email is already taken
    Given a user exists with email "james@example.com"
    
    When I go to the home page
    And I follow "Sign Up"
    
    When I fill in "Email" with "james@example.com"
    And I press "Sign Up"
    
    Then I should see "Email has already been taken"
