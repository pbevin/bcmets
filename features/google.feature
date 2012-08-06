Feature: Search engine micro-management
  As a patient
  In order to retain some privacy
  I want my name not to appear in a Google search

  Scenario: Archive by-month page
    When I go to the "2009/10" archive page
    Then Google should be disabled

  Scenario: Archive date order monthly page
    Given there is an article posted on "2009-10-29"
    When I go to the "2009/10" archive page
    And I follow "View in date order"
    Then Google should be disabled

  Scenario: Front page
    When I go to the front page
    Then Google should be enabled

  Scenario: Article
    Given there is an article posted on "2009-10-31" with subject "xyzzy"
    When I go to the "2009/10" archive page
    And I follow "xyzzy"
    Then Google should be disabled
