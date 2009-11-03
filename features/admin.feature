Feature: Admin interface
  As the site admin
  In order to help people more easily
  I want an easy interface.

  Background:
    When I login as administrator

  Scenario: List users
    Given the following users exist
      | name  | email             | created_at | email_delivery |
      | Anita | anita@example.com | 2009-08-11 | all            |
      | Zoe   | zoe@example.com   | 2009-09-03 | digest         |
    When I go to View Users
    Then I should see users table
      | User                            |     Joined | Delivery |
      | Zoe <zoe@example.com>           | 2009-09-03 | digest   |
      | Anita <anita@example.com>       | 2009-08-11 | all      |
      | Pete Bevin <pete@petebevin.com> | 1969-12-30 | none     |

  Scenario: Change delivery mode
    Given a user exists with email_delivery: "all"
    When I go to Edit User for that user
    And I choose "user_email_delivery_none"
    And I press "Submit"
    Then a user should exist with email_delivery: "none"

  Scenario: Change email address
    Given a user exists with email: "test@example.com"
    When I go to Edit User for that user
    And I fill in "Email" with "new.email@example.com"
    And I press "Submit"
    Then a user should exist with email: "new.email@example.com"

  Scenario: Not changing the password by default
    Given a user exists with email: "test@example.com", password: "secr3t"
    And that user is active
    When I go to Edit User for that user
    And I press "Submit"
    And I go to Login
    And I fill in "Email" with "test@example.com"
    And I fill in "Password" with "secr3t"
    And I press "Login"
    Then I should see "Logged in successfully"

  Scenario: Changing the password
    Given a user exists with email: "test@example.com", password: "secr3t"
    And that user is active
    When I go to Edit User for that user
    And I fill in "Password" with "123456"
    And I press "Submit"
    And I go to Login
    And I fill in "Email" with "test@example.com"
    And I fill in "Password" with "123456"
    And I press "Login"
    Then I should see "Logged in successfully"

  Scenario: Activating a user
    Given a user exists
    And that user is not active
    When I go to Edit User for that user
    Then I should see "User is not active"
    When I check "Activate User"
    And I press "Submit"
    Then that user should be active

  Scenario: Subscribe a user
    When I go to View Users
    And I follow "Add User"
    And I fill in "Name" with "Mary Williams2"
    And I fill in "Email" with "mary@example.com"
    And I press "Submit"
    Then I should see "User added"

  Scenario: Subscribe a user and activate
    When I go to View Users
    And I follow "Add User"
    And I fill in "Name" with "Mary Williams"
    And I fill in "Email" with "mary@example.com"
    And I check "Active"
    And I fill in "Password" with "secr3t"
    And I fill in "Password Confirmation" with "secr3t"
    And I choose "user_email_delivery_full"
    And I press "Submit"
    Then I should see "User added"
    And a user should exist with email: "mary@example.com"
    And that user should be active

