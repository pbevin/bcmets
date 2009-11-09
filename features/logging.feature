Feature: Admin interface
  As the site admin
  In order to figure out problems
  I want an easy way to view logs

  Scenario: Log message on activation
    Given a user: "test" exists with email: "test@example.com"
    When I activate user "test@example.com"
    Then an event log should exist with email: "test@example.com", reason: "signup"
    And the event log should be in the user's events

