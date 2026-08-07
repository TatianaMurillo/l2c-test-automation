@isTest
private class OpportunityValidationRulesTest {

    @isTest
    static void closingOpportunityAsWonWithZeroAmountThrowsValidationError() {
        Account acc = new Account(Name = 'Acme Corp', BillingCountryCode = 'US');
        insert acc;

        Opportunity opp = new Opportunity(
            Name = 'Acme Corp - New Business',
            AccountId = acc.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30)
        );
        insert opp;

        opp.StageName = 'Closed Won';
        opp.Amount = 0;

        Test.startTest();
        try {
            update opp;
            System.assert(false, 'Expected a DmlException from the validation rule but none was thrown.');
        } catch (DmlException dmlEx) {
            System.assert(
                dmlEx.getMessage().contains('Amount must be greater than zero'),
                'Unexpected error message: ' + dmlEx.getMessage()
            );
        }
        Test.stopTest();
    }

    @isTest
    static void closingOpportunityAsWonWithPositiveAmountSucceeds() {
        Account acc = new Account(Name = 'Acme Corp', BillingCountryCode = 'US');
        insert acc;

        Opportunity opp = new Opportunity(
            Name = 'Acme Corp - New Business',
            AccountId = acc.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30)
        );
        insert opp;

        opp.StageName = 'Closed Won';
        opp.Amount = 1500;

        Test.startTest();
        update opp;
        Test.stopTest();

        Opportunity updated = [SELECT StageName, Amount FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals('Closed Won', updated.StageName);
    }

    @isTest
    static void openOpportunityWithoutAmountSucceeds() {
        Account acc = new Account(Name = 'Acme Corp', BillingCountryCode = 'US');
        insert acc;

        Opportunity opp = new Opportunity(
            Name = 'Acme Corp - New Business',
            AccountId = acc.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30)
        );

        Test.startTest();
        insert opp;
        Test.stopTest();

        System.assertNotEquals(null, opp.Id, 'Open Opportunity without an Amount should still be insertable.');
    }
}
