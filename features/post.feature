Feature: Posting Articles
  As a patient
  In order to get better treatment
  I want to ask a question

  Scenario: Post from front page
    When I go to the front page
    And I follow "Post a new message"
    And I fill in "Name" with "My Name"
    And I fill in "Email" with "me@example.com"
    And I fill in "Subject" with "What is Taxol?"
    And I fill in "article_qt" with "blah blah"
    And I press "Post"
    Then I should see "Message sent"
    And an article should exist with subject: "What is Taxol?"
    And I should be on the front page  # debatable

  Scenario: Missing Fields
    When I go to the front page
    And I follow "Post a new message"
    And I fill in "Email" with "me@example.com"
    And I press "Post"
    Then I should see "There were problems"
    And the "Email" field should contain "me@example.com"
    And an article should not exist with email: "me@example.com"

  Scenario: Reply to an article
    Given an article: "parent" exists with msgid: "xyzzy"
    When I go to that article
    And I follow "Reply to this message"
    And I fill in "Name" with "Reply Name"
    And I fill in "Email" with "test@example.com"
    And I fill in "article_qt" with "blah blah"
    And I fill in "Reply To:" with "Sender only"
    And I press "Post"
    Then I should see "Message sent"
    And an article should exist with email: "test@example.com", parent_msgid: "xyzzy"
    And I should be on article: "parent"
    
  Scenario: Reply to an article (invalid fields)
    Given an article exists
    When I go to that article
    And I follow "Reply to this message"
    And I fill in "Email" with "invalid"
    And I press "Post"
    Then I should see "There were problems"
    And an article should not exist with email: "invalid"

  Scenario: Spam prevention
    When I go to path /post
    And I fill in "Name" with "A. Spammer"
    And I fill in "Email" with "test@example.com"
    And I fill in "Subject" with "Make Money Fast"
    And I fill in "article_body" with "..."
    And I press "Post"
    Then I should see "Message sent"
    But an article should not exist
