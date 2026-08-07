@address
Feature: Address format validation rules
  As a Sales Operations user
  I want Account Billing Address fields to enforce format rules
  So that shipping, tax and CPQ calculations are based on valid postal data

  # Salesforce has no standalone Address object in standard Sales Cloud.
  # This module tests the Account's Billing Address compound field instead
  # (see salesforce-metadata-reference/.../Account_Billing_Postal_Code_Format).
  # Replicate the same pattern for Shipping Address / Contact address fields
  # if your org needs those covered too.

  Background:
    Given I am logged into Salesforce as a Sales user

  @smoke @validation-rule @wip
  Scenario: An Account cannot be saved with an invalid US billing postal code
    When I create an Account with billing country "United States" and billing postal code "ABC"
    Then the Account should not be saved
    And I should see a validation error containing "Invalid postal code format"

  @validation-rule @wip
  Scenario: An Account is saved successfully with a valid US billing postal code
    When I create an Account with billing country "United States" and billing postal code "12345"
    Then the Account should be saved successfully
