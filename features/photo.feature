@javascript
Feature: Photo Management
  As a regular on bcmets
  In order to help people recognize me
  I want to provide a photo

  Background:
    Given a user exists with password: "xyzzy"
    And that user is logged in

  Scenario: Uploading a picture
    Given PENDING: file attachment is broken in PhantomJS 2.0: https://github.com/ariya/phantomjs/issues/12506
    When I go to my profile
    And I attach the file at "features/data/wonderwoman.jpg" to "Photo"
    And I press "Submit"
    Then the user should have an attached photo
