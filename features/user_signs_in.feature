Feature: User signs in

  As a user
  I want sign in and go to my user page
  So that I can see all the things I can do
  
  Scenario: User signs in
    Given a user exists with login "james" and password "password"
    
    When I go to the home page
    And I follow "Sign In"
    
    Then I should be on the sign-in page
    
    When I fill in "Login" with "james"
    And I fill in "Password" with "password"
    And I press "Sign In"
    
    Then I should be on the user page for "james"
    And I should see a link labelled "Installed Applications"
    And I should see a link labelled "Applications Installed by Friends"
