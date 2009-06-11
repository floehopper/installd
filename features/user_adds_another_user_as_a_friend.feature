Feature: User adds another user as a friend

  As a User
  I want to add another user as a friend
  So that I can see what applications my friends have installed
  
  Scenario: User adds another user as a friend
    Given a user exists with login "james" and password "password"
    And I am signed in with login "james" and password "password"
    And a user exists with login "hannah"
    
    When I go to the user page for "hannah"
    And I follow "Add as friend"
    
    Then I should see "Do you want to add hannah as a friend?"
    
    When I press "Add"
    
    Then I should see "hannah has been added as a friend"
  
  Scenario: User cannot add an existing friend as a friend
    Given a user exists with login "james" and password "password"
    And I am signed in with login "james" and password "password"
    And a user exists with login "hannah"
    And user with login "james" is friends with user with login "hannah"
    
    When I go to the user page for "hannah"
    
    Then I should see "You are friends with this user"
    And I should not see link labelled "Add as Friend"
  
  Scenario: User cannot add themselves as a friend
    Given a user exists with login "james" and password "password"
    And I am signed in with login "james" and password "password"
    
    When I go to the user page for "james"
    
    Then I should not see link labelled "Add as Friend"
    
  Scenario: Visitor cannot add a user as a friend
    Given a user exists with login "james"
    
    When I go to the user page for "james"
    
    Then I should not see "Add as friend"
