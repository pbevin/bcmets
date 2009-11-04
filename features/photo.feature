Feature: Photo Management
  As a regular on bcmets
  In order to help people recognize me
  I want to provide a photo

  Background:
    Given a user: "Pam" exists with password: "xyzzy"
    And that user is logged in

  Scenario: Uploading a picture
    When I go to my profile
    And I attach the file at "features/data/wonderwoman.jpg" to "Photo"
    And I press "Submit"
    Then user: "Pam" should have an attached photo
