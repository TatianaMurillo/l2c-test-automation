@contract
Feature: Contract validation rules
  As a Legal Operations user
  I want the Contract form to enforce data quality rules
  So that only complete, valid contracts can be activated and signed

  # TEMPLATE MODULE - replace with the real Contract validation rules.

  Background:
    Given I am logged into Salesforce as a Sales user

  @smoke @validation-rule @wip
  Scenario: A Contract cannot be saved without a Start Date
    When I create a Contract with no start date
    Then the Contract should not be saved
    And I should see a validation error containing "Contract Start Date is required"
