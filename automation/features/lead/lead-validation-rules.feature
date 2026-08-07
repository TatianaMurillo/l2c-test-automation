@lead
Feature: Lead validation rules
  As a Sales user
  I want the Lead form to enforce data quality rules
  So that downstream Lead-to-Cash records (Account, Contact, Opportunity) start from clean data

  Background:
    Given I am logged into Salesforce as a Sales user

  @smoke @validation-rule
  Scenario: A Lead cannot be saved without an Email or a Phone number
    When I create a Lead with last name "Doe", company "Acme Corp" and no email or phone
    Then the Lead should not be saved
    And I should see a validation error containing "Email or Phone is required"

  @validation-rule
  Scenario: A Lead is saved successfully when an Email is provided
    When I create a Lead with last name "Doe", company "Acme Corp" and email "doe@example-test.com"
    Then the Lead should be saved successfully

  @validation-rule
  Scenario: A Lead is saved successfully when a Phone number is provided
    When I create a Lead with last name "Doe", company "Acme Corp" and phone "5551234567"
    Then the Lead should be saved successfully
