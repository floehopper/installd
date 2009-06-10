Feature: View user's installed applications

  As a visitor
  I want to view a user's installed applications
  So that I can find interesting applications to install
  
  Scenario: Visitor views a user's installed applications
    Given a user exists with login "james"
    And user with login "james" has the following applications installed:
      |name|
      |Tweetie|
      |Things|
    
    When I go to the user page for "james"
    
    Then I should see an application with name "Tweetie"
    And I should see an application with name "Things"
  
