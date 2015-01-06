Feature: Unsubscribe from bcmets
  As a user who is doing OK now
  In order to get on with my life
  I want to unsubscribe from bcmets

  Scenario: Unsubscribe from user edit page:
    Given a user exists with password: "xyzzy"
    And that user is logged in
    When I go to my profile
    And I press "Unsubscribe from bcmets"
    Then I should be on the front page
    And I should see "Your account has been deleted"
    And that user should have been deleted

