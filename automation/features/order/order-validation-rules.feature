@order
Feature: Order validation rules
  As an Order Management user
  I want the Order form to enforce data quality rules
  So that only valid, activatable orders reach fulfillment and billing

  # TEMPLATE MODULE - replace with the real Order validation rules.

  Background:
    Given I am logged into Salesforce as a Sales user

  @validation-rule @wip
  Scenario: An Order cannot be Activated without a Contract
    When I activate an Order with no related contract
    Then the Order should not be saved
    And I should see a validation error containing "Contract is required to activate an order"
