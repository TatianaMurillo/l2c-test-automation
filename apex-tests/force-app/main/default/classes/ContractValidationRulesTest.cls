@isTest
private class ContractValidationRulesTest {

    @isTest
    static void savingContractWithoutStartDateThrowsValidationError() {
        Account acc = new Account(Name = 'Acme Corp', BillingCountryCode = 'US');
        insert acc;

        Contract ctr = new Contract(AccountId = acc.Id);

        Test.startTest();
        try {
            insert ctr;
            System.assert(false, 'Expected a DmlException from the validation rule but none was thrown.');
        } catch (DmlException dmlEx) {
            System.assert(
                dmlEx.getMessage().contains('Contract Start Date is required'),
                'Unexpected error message: ' + dmlEx.getMessage()
            );
        }
        Test.stopTest();
    }

    @isTest
    static void savingContractWithStartDateSucceeds() {
        Account acc = new Account(Name = 'Acme Corp', BillingCountryCode = 'US');
        insert acc;

        Contract ctr = new Contract(AccountId = acc.Id, StartDate = Date.today());

        Test.startTest();
        insert ctr;
        Test.stopTest();

        System.assertNotEquals(null, ctr.Id, 'Contract should have been inserted successfully.');
    }
}
