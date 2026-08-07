@isTest
private class QuoteValidationRulesTest {
    // Exercises Quote_LineItem_Required_For_Approval, which depends on the
    // Total_Quote_Lines__c roll-up field defined alongside this rule.

    @isTest
    static void approvingQuoteWithNoLineItemsThrowsValidationError() {
        Quote q = createDraftQuote();
        q.Status = 'Approved';

        Test.startTest();
        try {
            update q;
            System.assert(false, 'Expected a DmlException from the validation rule but none was thrown.');
        } catch (DmlException dmlEx) {
            System.assert(
                dmlEx.getMessage().contains('At least one line item is required'),
                'Unexpected error message: ' + dmlEx.getMessage()
            );
        }
        Test.stopTest();
    }

    @isTest
    static void approvingQuoteWithAtLeastOneLineItemSucceeds() {
        Quote q = createDraftQuote();
        addStandardPricedLineItem(q);
        q.Status = 'Approved';

        Test.startTest();
        update q;
        Test.stopTest();

        Quote updated = [SELECT Status FROM Quote WHERE Id = :q.Id];
        System.assertEquals('Approved', updated.Status);
    }

    // --- test data helpers ---

    private static Quote createDraftQuote() {
        Account acc = new Account(Name = 'Acme Corp', BillingCountryCode = 'US');
        insert acc;

        Opportunity opp = new Opportunity(
            Name = 'Acme Corp - New Business',
            AccountId = acc.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30)
        );
        insert opp;

        Quote q = new Quote(
            Name = 'Acme Corp Quote',
            OpportunityId = opp.Id,
            Pricebook2Id = Test.getStandardPricebookId(),
            Status = 'Draft'
        );
        insert q;
        return q;
    }

    private static void addStandardPricedLineItem(Quote q) {
        Product2 product = new Product2(Name = 'Standard License', IsActive = true);
        insert product;

        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = product.Id,
            UnitPrice = 100,
            IsActive = true
        );
        insert pbe;

        QuoteLineItem qli = new QuoteLineItem(
            QuoteId = q.Id,
            PricebookEntryId = pbe.Id,
            Product2Id = product.Id,
            Quantity = 1,
            UnitPrice = 100
        );
        insert qli;
    }
}
