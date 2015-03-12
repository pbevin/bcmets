Feature: Editing user account

  Background:
    Given a user exists with password: "xyzzy"
    And that user is logged in

  Scenario: User changes email address
    Given my email address is "test@example.com"
    When I go to my profile
    And I follow "Change email address"
    And I change my email address to "test2@example.com"
    And I press "Change my email address"
    Then my email address should be "test2@example.com"
