@contact
Feature: Contact validation rules
  As a Sales user
  I want the Contact form to enforce data quality rules
  So that communications and contract signatories have valid contact details

  # TEMPLATE MODULE - replace with the real Contact validation rules.

  Background:
    Given I am logged into Salesforce as a Sales user

  @validation-rule @wip
  Scenario: A Contact cannot be saved without a related Account
    When I create a Contact with last name "Doe" and no related account
    Then the Contact should not be saved
    And I should see a validation error containing "Account is required"
