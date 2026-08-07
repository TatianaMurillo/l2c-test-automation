@opportunity
Feature: Opportunity validation rules
  As a Sales user
  I want the Opportunity form to enforce data quality rules
  So that forecasting and quoting are based on accurate deal data

  # TEMPLATE MODULE - replace with the real Opportunity validation rules.

  Background:
    Given I am logged into Salesforce as a Sales user

  @smoke @validation-rule @wip
  Scenario: An Opportunity cannot be Closed Won with an Amount of zero
    When I set an Opportunity to stage "Closed Won" with amount "0"
    Then the Opportunity should not be saved
    And I should see a validation error containing "Amount must be greater than zero to close a deal as won"
