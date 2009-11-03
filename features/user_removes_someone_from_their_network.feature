Feature: User removes someone from their network

  As a User
  I want to remove another user from my network
  So that I can ignore the applications installed by this user
  
  Scenario: User removes a user from their network
    Given an active user exists with login "james" and password "password"
    And I am signed in with login "james" and password "password"
    And an active user exists with login "hannah"
    And I go to the user page for "hannah"
    And I follow "Add this user to my network"
    And I press "Yes"
    
    When I go to the user page for "hannah"
    And I follow "Remove this user from my network"
    
    Then I should see "Do you want to remove hannah from your network?"
    
    When I press "Yes"
    
    Then I should see "hannah has been removed from your network"
    
  Scenario: User cannot remove a user who is not in their network
    Given an active user exists with login "james" and password "password"
    And I am signed in with login "james" and password "password"
    And an active user exists with login "hannah"
    
    When I go to the user page for "hannah"
    
    Then I should not see a link labelled "Remove this user from my network"
    And I should see a link labelled "Add this user to my network"
  
  Scenario: User cannot remove themselves from network
    Given an active user exists with login "james" and password "password"
    And I am signed in with login "james" and password "password"
    
    When I go to the user page for "james"
    
    Then I should not see a link labelled "Remove this user from my network"
  
  Scenario: Visitor cannot remove a user from network
    Given an active user exists with login "james"
    
    When I go to the user page for "james"
    
    Then I should not see "Add this user to my network"
