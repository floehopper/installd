Feature: User adds another user as a friend

  As a User
  I want to add another user to my network
  So that I can see what applications my friends have installed
  
  Scenario: User adds a user to their network
    Given an active user exists with login "james" and password "password"
    And I am signed in with login "james" and password "password"
    And an active user exists with login "hannah"
    
    When I go to the user page for "hannah"
    And I follow "Add this user to my network"
    
    Then I should see "Do you want to add hannah to your network?"
    
    When I press "Yes"
    
    Then I should see "hannah has been added to your network"
  
  Scenario: User cannot add an existing connection to network
    Given an active user exists with login "james" and password "password"
    And I am signed in with login "james" and password "password"
    And an active user exists with login "hannah"
    And user with login "james" is connected to user with login "hannah"
    
    When I go to the user page for "hannah"
    
    Then I should see a link labelled "Remove this user from my network"
    And I should not see a link labelled "Add this user to my network"
  
  Scenario: User cannot add themselves to network
    Given an active user exists with login "james" and password "password"
    And I am signed in with login "james" and password "password"
    
    When I go to the user page for "james"
    
    Then I should not see a link labelled "Add to my network"
    
  Scenario: Visitor cannot add a user to network
    Given an active user exists with login "james"
    
    When I go to the user page for "james"
    
    Then I should not see "Add to my network"
