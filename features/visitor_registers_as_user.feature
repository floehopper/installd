Feature: Visitor registers as user

  As a visitor
  I want to register as a user
  So that I can tell all my friends what applications I have installed
  
  Scenario: Visitor registers as a user
    Given no user exists with login "james"
    
    When I go to the home page
    And I follow "Register"
    
    Then I should be on the registration page
    
    When I fill in "Login" with "james"
    And I fill in "Password" with "password"
    And I fill in "Password Confirmation" with "password"
    And I press "Register"
    
    Then I should be on the user page for "james"
    And I should see "Registration was successful"
    
  Scenario: Visitor registers as a user, but login is already taken
    Given a user exists with login "james"
    
    When I go to the home page
    And I follow "Register"
    
    When I fill in "Login" with "james"
    And I fill in "Password" with "password"
    And I fill in "Password Confirmation" with "password"
    And I press "Register"
    
    And I should see "Login has already been taken"
