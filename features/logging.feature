Feature: Admin interface
  As the site admin
  In order to figure out problems
  I want an easy way to view logs

  Scenario: Log message on activation
    When I sign up as "test@example.com"
    Then an event log should not exist with email: "test@example.com"
    When I activate user "test@example.com"
    Then an event log should exist with email: "test@example.com", reason: "signup"

