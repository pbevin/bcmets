Feature: Login via API

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
