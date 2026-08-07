@isTest
private class AccountValidationRulesTest {
    // Covers Account_Billing_Country_Required and Account_Billing_Postal_Code_Format
    // (the latter is the "Address" module - see the validation rule's description).

    @isTest
    static void savingAccountWithoutBillingCountryThrowsValidationError() {
        Account acc = new Account(Name = 'Acme Corp');

        Test.startTest();
        try {
            insert acc;
            System.assert(false, 'Expected a DmlException from the validation rule but none was thrown.');
        } catch (DmlException dmlEx) {
            System.assert(
                dmlEx.getMessage().contains('Billing Country is required'),
                'Unexpected error message: ' + dmlEx.getMessage()
            );
        }
        Test.stopTest();
    }

    @isTest
    static void savingAccountWithBillingCountrySucceeds() {
        Account acc = new Account(Name = 'Acme Corp', BillingCountryCode = 'US');

        Test.startTest();
        insert acc;
        Test.stopTest();

        System.assertNotEquals(null, acc.Id, 'Account should have been inserted successfully.');
    }

    @isTest
    static void savingAccountWithInvalidUsPostalCodeThrowsValidationError() {
        Account acc = new Account(
            Name = 'Acme Corp',
            BillingCountryCode = 'US',
            BillingPostalCode = 'ABC'
        );

        Test.startTest();
        try {
            insert acc;
            System.assert(false, 'Expected a DmlException from the validation rule but none was thrown.');
        } catch (DmlException dmlEx) {
            System.assert(
                dmlEx.getMessage().contains('Invalid postal code format'),
                'Unexpected error message: ' + dmlEx.getMessage()
            );
        }
        Test.stopTest();
    }

    @isTest
    static void savingAccountWithValidUsPostalCodeSucceeds() {
        Account acc = new Account(
            Name = 'Acme Corp',
            BillingCountryCode = 'US',
            BillingPostalCode = '12345'
        );

        Test.startTest();
        insert acc;
        Test.stopTest();

        System.assertNotEquals(null, acc.Id, 'Account should have been inserted successfully.');
    }
}
