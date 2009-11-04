Feature: User signs in

  As a user
  I want sign in and go to my user page
  So that I can see my applications and those of my friends
  
  Scenario: User signs in
    Given an active user exists with login "james" and password "password"
    And user with login "james" has the following applications installed:
      |name|item_id|icon_url|
      |Tweetie|1|http://a1.phobos.apple.com/eu/r1000/008/Purple/74/fd/94/mzl.myulxqmo.png|
      |Things |2|http://a1.phobos.apple.com/eu/r1000/049/Purple/c5/fb/95/mzl.rieakmfj.png|
    
    When I go to the home page
    And I follow "Sign In"
    
    Then I should be on the sign-in page
    
    When I fill in "Login" with "james"
    And I fill in "Password" with "password"
    And I press "Sign In"
    
    Then I should be on the user page for "james"
    And I should see an application with name "Tweetie"
    And I should see an application with name "Things"
