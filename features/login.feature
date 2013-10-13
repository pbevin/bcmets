@admin
Feature: Becoming a user
  In order to get support
  As a breast cancer patient
  I want to register with the web site

  Scenario: Sign up
    Given there is no user called "Mary Jones"
    And I am not logged in
    When I go to the front page
    And I follow "Join bcmets"
    And I fill in "Name" with "Mary Jones"
    And I fill in "Email" with "mary@example.com"
    And I press "Sign up"
    Then I should see a notice "Registration successful."
    And a user should exist with name: "Mary Jones", email_delivery: "none"
    And I should not be logged in

  Scenario: Activate account
    Given that I have a confirmation email for "mary@example.com"
    When I click on the activation link
    And I enter my password "secret" with confirmation "secret"
    And I choose "user_email_delivery_full"
    And I press "Sign me up!"
    Then I should see "Thank you for registering!"
    And a user should exist with email: "mary@example.com", email_delivery: "full"
    And I should be logged in

  Scenario: Login with valid account
    Given user "mary@example.com" with password "secret"
    When I go to Login
    And I fill in "Email" with "mary@example.com"
    And I fill in "Password" with "secret"
    And I press "Login"
    Then I should be logged in
    And I should see "Logged in as"
    But I should not see "Join bcmets"

  Scenario: Log out
    Given user "mary@example.com" with password "secret"
    When I go to Login
    And I fill in "Email" with "mary@example.com"
    And I fill in "Password" with "secret"
    And I press "Login"
    And I go to the front page
    And I follow "Logout"
    Then I should not be logged in
    And I should not see "Logged in as"
    But I should see "Join bcmets"

  Scenario: Forgot Password
    Given user "mary@example.com" with password "forgotten"
    When I go to Login
    And I follow "Forgot your password?"
    And I fill in "email" with "mary@example.com"
    And I press "Help!"
    Then I should see "Instructions sent to mary@example.com"

  Scenario: Change Password
    Given a user: "Pam" exists with password: "xyzzy", email: "pam@example.com"
    And that user is logged in
    When I go to my profile
    And I follow "Change password"
    And I change my old password "xyzzy" to "clever" with confirmation "clever"
    Then I should see "Password changed."
    And user: "Pam" should have password: "clever"

  Scenario: Change password, confirmation doesn't match
    Given a user: "Pam" exists with password: "xyzzy", email: "pam@example.com"
    And that user is logged in
    When I go to my profile
    And I follow "Change password"
    And I change my old password "xyzzy" to "clever" with confirmation "does-not-match"
    Then I should see "doesn't match"

  Scenario: Login with AJAX
    Given user "mary@example.com" with password "secret"
    When I send HTTP POST to "/login.json" with the following parameters:
      | user_session[email]    | mary@example.com |
      | user_session[password] | secret           |
    Then the response should be "200 OK" with the following JSON:
    """
    { "succeeded": true }
    """

  Scenario: Failed login with AJAX
    Given user "mary@example.com" with password "secret"
    When I send HTTP POST to "/login.json" with the following parameters:
      | user_session[email]    | mary@example.com |
      | user_session[password] | wrong            |
    Then the response should be "422 Unprocessable Entity" with the following JSON:
    """
    { "succeeded": false,
      "errors": { "password": ["is not valid"] }
    }
    """
