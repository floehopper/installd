Feature: User activates account

  As a user
  I want to activate my account
  So that I can sign in and start using the website
  
  Scenario: User activates account
    Given I go to the home page
    And I follow "Sign Up"
    And I fill in "Email" with "james@example.com"
    And I press "Sign Up"
    
    And an active user exists with login "floehopper" and password "password"
    And I go to the home page
    And I follow "Sign In"
    And I fill in "Login" with "floehopper"
    And I fill in "Password" with "password"
    And I press "Sign In"
    
    And I go to the users page
    And I press "Invite"
    And I follow "Sign Out"
    
    When "james@example.com" opens the email with subject "installd.com invitation"
    And I follow "Activate" in the email
    
    Then I should be on the the activation page
    
    When I fill in "Login" with "james"
    And I fill in "Password" with "password"
    And I press "Activate"
    
    Then I should be on the downloads page
    And I should see "Activation successful"
