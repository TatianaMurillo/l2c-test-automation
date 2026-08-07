@quote
Feature: Quote validation rules
  As a Sales user
  I want the Quote form to enforce data quality and approval rules
  So that only complete, approved quotes can move forward to Order

  # TEMPLATE MODULE - replace with the real Quote validation rules
  # (e.g. from Salesforce CPQ / Revenue Cloud if in use).

  Background:
    Given I am logged into Salesforce as a Sales user

  @validation-rule @wip
  Scenario: A Quote cannot be marked Approved without at least one line item
    When I set a Quote to status "Approved" with no quote line items
    Then the Quote should not be saved
    And I should see a validation error containing "At least one line item is required to approve a quote"
