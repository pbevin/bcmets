Feature: Blogroll Links
  As the site administrator
  In order to update links in the template more easily
  I want to edit them via the web site

  Background:
    Given there are no links
    When I login as administrator

  Scenario: Add a link
    When I go to Show Links
    And I follow "New link"
    And I fill in "Title" with "Link 123"
    And I fill in "Url" with "http://www.example.com/"
    And I fill in "Position" with "666"
    And I press "Create"
    Then a link should exist with title: "Link 123", url: "http://www.example.com/", position: "666"

