Feature: User views their installed applications

  As a user
  I want to view my installed applications
  So that I can check the list is up-to-date
  
  Scenario: User views their installed applications
    Given a user exists with login "james" and password "password"
    And user with login "james" has the following applications installed:
      |name|item_id|icon_url|
      |Tweetie|1|http://a1.phobos.apple.com/Tweetie.png|
      |Things |2|http://a1.phobos.apple.com/Things.png |
    
    When I go to the home page
    And I follow "Sign In"
    
    Then I should be on the sign-in page
    
    When I fill in "Login" with "james"
    And I fill in "Password" with "password"
    And I press "Sign In"
    
    Then I should be on the user page for "james"
    And I should see an application with name "Tweetie"
    And I should see an application with name "Things"
  
