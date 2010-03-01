Feature: Matching users to articles
  As a bcmets member
  In order to connect better with other members
  I want to have my user ID identified with my articles
  
  Background:
    Given there are no articles
    And a user exists with email: "me@myself.com"
  
  Scenario: Posting when logged in
    Given I am logged in as "me@myself.com"
    When I post an article
    Then there should be an article with user "me@myself.com"
    
  Scenario: Posting when not logged in
    Given I am not logged in
    When I post an article with email "me@myself.com"
    Then there should be an article with user "me@myself.com"
    
  Scenario: Posting via email
    When an article arrives with email "me@myself.com"
    Then there should be an article with user "me@myself.com"
