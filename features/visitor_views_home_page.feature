Feature: Visitor views home page

  As a visitor
  I want to view the home page
  So that I can see apps that other people are installing
  
  Scenario: Visitor views the home page and sees installed apps
    Given an active user exists with login "hannah"
    And user with login "hannah" has the following applications installed:
      |name    |item_id|icon_url                               |
      |Tweetie |1      |http://a1.phobos.apple.com/eu/r1000/008/Purple/74/fd/94/mzl.myulxqmo.png |
      |Things  |2      |http://a1.phobos.apple.com/eu/r1000/049/Purple/c5/fb/95/mzl.rieakmfj.png  |
    
    And an active user exists with login "sarah"
    And user with login "sarah" has the following applications installed:
      |name    |item_id|icon_url                               |
      |LinkedIn|3      |http://a1.phobos.apple.com/eu/r1000/052/Purple/1c/9d/7c/mzl.gdiludim.png|
      |Shazam  |4      |http://a1.phobos.apple.com/eu/r1000/004/Purple/79/79/7e/mzl.jyfoaxsc.png  |
    
    When I go to the home page
    
    Then I should see an application with name "Tweetie"
    And I should see an application with name "Things"
    And I should see an application with name "LinkedIn"
    And I should see an application with name "Shazam"

