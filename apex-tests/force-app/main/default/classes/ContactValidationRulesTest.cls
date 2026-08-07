@isTest
private class ContactValidationRulesTest {

    @isTest
    static void savingContactWithoutAccountThrowsValidationError() {
        Contact con = new Contact(LastName = 'Doe');

        Test.startTest();
        try {
            insert con;
            System.assert(false, 'Expected a DmlException from the validation rule but none was thrown.');
        } catch (DmlException dmlEx) {
            System.assert(
                dmlEx.getMessage().contains('Account is required'),
                'Unexpected error message: ' + dmlEx.getMessage()
            );
        }
        Test.stopTest();
    }

    @isTest
    static void savingContactWithAccountSucceeds() {
        Account acc = new Account(Name = 'Acme Corp', BillingCountryCode = 'US');
        insert acc;

        Contact con = new Contact(LastName = 'Doe', AccountId = acc.Id);

        Test.startTest();
        insert con;
        Test.stopTest();

        System.assertNotEquals(null, con.Id, 'Contact should have been inserted successfully.');
    }
}
