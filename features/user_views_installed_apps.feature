Feature: User views their installed applications

  As a user
  I want to view my installed applications
  So that I can check the list is up-to-date
  
  Scenario: User views their installed applications
    Given an active user exists with login "james" and password "password"
    And user with login "james" has the following applications installed:
      |name|item_id|icon_url|
      |Tweetie|1|http://a1.phobos.apple.com/eu/r1000/008/Purple/74/fd/94/mzl.myulxqmo.png|
      |Things |2|http://a1.phobos.apple.com/eu/r1000/049/Purple/c5/fb/95/mzl.rieakmfj.png |
    And I am signed in with login "james" and password "password"
    
    When I go to the user installs page for "james"
    
    Then I should see an application with name "Tweetie"
    And I should see an application with name "Things"
  
