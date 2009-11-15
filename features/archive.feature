Feature: Browsing the archive
  As a cancer patient
  In order to get better treatment
  I want to read articles

  Scenario: Front page viewing
    When I go to the front page
    Then I should see "November 2009"
  
  Scenario: Drilling down into a month
    Given an article exists with received_at: "2009-11-05", subject: "Taxol Side Effects"
    When I go to the front page
    And I follow "November 2009"
    Then I should see "Taxol Side Effects"

  Scenario: Drilling down into an article
    Given an article exists with received_at: "2009-11-05", subject: "xyzzy", body: "ubiquitous gazelles"
    When I go to the front page
    And I follow "November 2009"
    And I follow "xyzzy"
    Then I should see "xyzzy" within "h1"
    Then I should see "ubiquitous gazelles"
    
  Scenario: Author profile
    Given an article exists with received_at: "2009-11-05", subject: "xyzzy", email: "test@example.com", body: "squeamish ossifrage"
    When I go to the front page
    And I follow "November 2009"
    And I follow "test@example.com"
    And I follow "xyzzy"
    Then I should see "squeamish ossifrage"