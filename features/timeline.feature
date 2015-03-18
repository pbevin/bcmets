@javascript
Feature: Article Timeline
  Scenario: Visit Timeline with articles
    Given 10 recent articles
    When I view the timeline
    Then I should see 10 articles
