@ignore
Feature: User views applications installed by their friends

  As a user
  I want to view applications installed by all my friends
  So that I can find interesting applications to install
  
  Scenario: User views applications installed by their friends
    Given an active user exists with login "hannah"
    And user with login "hannah" has the following applications installed:
      |name    |item_id|icon_url                               |
      |Tweetie |1      |http://a1.phobos.apple.com/eu/r1000/008/Purple/74/fd/94/mzl.myulxqmo.png |
      |Things  |2      |http://a1.phobos.apple.com/eu/r1000/008/Purple/74/fd/94/mzl.myulxqmo.png  |
    
    And an active user exists with login "sarah"
    And user with login "sarah" has the following applications installed:
      |name    |item_id|icon_url                               |
      |LinkedIn|3      |http://a1.phobos.apple.com/eu/r1000/052/Purple/1c/9d/7c/mzl.gdiludim.png|
      |Shazam  |4      |http://a1.phobos.apple.com/eu/r1000/004/Purple/79/79/7e/mzl.jyfoaxsc.png  |
    
    And an active user exists with login "james" and password "password"
    And user with login "james" is connected to user with login "hannah"
    And user with login "james" is connected to user with login "sarah"
    And I am signed in with login "james" and password "password"
    
    When I go to the user network page for "james"
    
    Then I should see an application with name "Tweetie"
    And I should see an application with name "Things"
    And I should see an application with name "LinkedIn"
    And I should see an application with name "Shazam"
