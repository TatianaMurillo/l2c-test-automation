@account
Feature: Account validation rules
  As a Sales Operations user
  I want the Account form to enforce data quality rules
  So that billing, shipping and CPQ processes downstream have reliable data

  # TEMPLATE MODULE - replace the scenarios below with the real validation
  # rules configured on the Account object once the org exists (Phase 1).
  # Follow the same structure as features/lead/lead-validation-rules.feature.

  Background:
    Given I am logged into Salesforce as a Sales user

  @smoke @validation-rule @wip
  Scenario: An Account cannot be saved without a Billing Country
    When I create an Account with name "Acme Corp" and no billing country
    Then the Account should not be saved
    And I should see a validation error containing "Billing Country is required"
