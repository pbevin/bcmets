Feature: Admin security
  As the administrator
  In order to reduce headaches
  I want to keep non-admins out of the admin interface

  Background:
    Given I am not logged in

  Scenario: Admin page
    When I go to path /admin
    Then I should be on Login
    When I login as administrator
    Then I should be on path /admin

  Scenario: User list
    When I go to path /users
    Then I should be on Login

  Scenario: Link editing
    When I go to path /links
    Then I should be on Login
