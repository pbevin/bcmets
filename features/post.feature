@javascript
Feature: Posting Articles
  As a patient
  In order to get better treatment
  I want to ask a question

  Background:
    Given a user exists with email: "member@example.com"
    And there are no articles

  Scenario: Post from front page
    When I go to the front page
    And I follow "Post a new message"
    And I fill in "Name" with "My Name"
    And I fill in "Email" with "member@example.com"
    And I fill in "Subject" with "What is Taxol?"
    And I fill in "Message" with "blah blah"
    And I press "Post"
    Then I should see "Message sent"
    And an article should be queued with subject: "What is Taxol?"
    And I should be on the front page  # debatable

  Scenario: Post from front page when article requires moderation
    When I post an article with email "invalid@example.com"
    Then I should see "Message sent"
    And an article should be queued with email: "invalid@example.com", parent_msgid: ""

  Scenario: Missing Fields
    When I go to the front page
    And I follow "Post a new message"
    And I fill in "Email" with "me@example.com"
    Then the "Post" button should be inactive

  Scenario: Reply to an article
    Given a parent article exists with msgid: "<xyzzy@fake>"
    When I go to that article
    And I follow "Reply to this message"
    And I fill in "Name" with "Reply Name"
    And I fill in "Email" with "member@example.com"
    And I fill in "Message" with "blah blah"
    And I select "Sender only" from "Reply To"
    And I press "Post"
    Then I should see "Message sent"
    And an article should be queued with email: "member@example.com", parent_msgid: "<xyzzy@fake>"
    And I should be on the parent article

  Scenario: Reply to an article (invalid fields)
    Given an article exists
    When I go to that article
    And I follow "Reply to this message"
    And I fill in "Email" with "invalid"
    Then the "Post" button should be inactive

  # Scenario: Spam trap: mustn't fill in article_body
  #   When I go to path /post
  #   And I fill in "Name" with "A. Spammer"
  #   And I fill in "Email" with "member@example.com"
  #   And I fill in "Subject" with "Make Money Fast"
  #   And I fill in the fake article body with "Make easy $$$ working from home!@!!"
  #   And I press "Post"
  #   Then I should see "Message sent"
  #   But no article should be queued

  Scenario: Page title for Post page
    When I go to path /post
    Then I should see "Post a Message" within "h1"

  Scenario: Page title for Reply page
    Given an article exists
    When I go to that article
    And I follow "Reply to this message"
    Then I should see "Reply to Message" within "h1"

  Scenario: Back to "this month"
    Given an article exists with msgid: "xyzzy"
    When I go to that article
    And I follow "Reply to this message"
    And I fill in "Name" with "Reply Name"
    And I fill in "Email" with "member@example.com"
    And I fill in "Message" with "blah blah"
    And I fill in "Subject" with "Homefries"
    And I select "List only" from "Reply To"
    And I press "Post"
    Then I should see "Message sent"
    And an article should be queued with subject: "Homefries"
