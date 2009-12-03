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
    Given an article exists with received_at: "2009-11-05", subject: "xyzzy"
    When I go to the front page
    And I follow "November 2009"
    And I follow "xyzzy"
    Then I should be on that article
    
  Scenario: Author profile
    Given an article exists with received_at: "2009-11-05", subject: "xyzzy", email: "test@example.com"
    When I go to the front page
    And I follow "November 2009"
    And I follow "test@example.com"
    And I follow "xyzzy"
    Then I should be on that article
    
  Scenario: Bookmarked URLs
    Given an article exists with legacy_id: "2007-07/0223"
    When I go to path /archive/2007-07/0223.html
    Then I should be on that article
    
  Scenario: Failure to find a bookmarked URL
    When I go to path /archive/2007-07/9999.html
    Then I should be on the front page
    And I should see "We couldn't find your bookmark"

  Scenario: Alternate URLs for archive-by-month
    Given an article exists with received_at: "2009-11-05", subject: "xyzzy"
    When I go to path "/archive/2009-11"
    Then I should see "xyzzy"
    When I go to path "/archive/2009/11"
    Then I should see "xyzzy"
