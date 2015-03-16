@javascript
Feature: Logging donations
  As a site administrator
  In order to acknowledge donations
  I want to log them in the database

  Background:
    Given there are no donations
    When I login as administrator

  Scenario: Entering a donation
    When I go to Donations
    And I follow "New Donation"
    And I fill in "Amount" with "82"
    And I fill in "Email" with "donor@example.com"
    And I press "Submit"
    Then I should see "Successfully created donation"
    And I should see "$82 this month"
    And I should see "$82 this year"

  Scenario: Wrong fields
    When I go to Donations
    And I follow "New Donation"
    And I fill in "Amount" with "donor@example.com"
    And I fill in "Email" with "25"
    And I press "Submit"
    Then I should see "Amount is not a number"
    And I should see "$0 this month"
