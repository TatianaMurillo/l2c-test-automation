@isTest
private class OrderValidationRulesTest {
    // Assumes an "Activated" Status picklist value exists on Order in this
    // org (see Order_Contract_Required_For_Activation's description). Adjust
    // the literal below if your org's Status values differ.
    private static final String ACTIVATED_STATUS = 'Activated';
    private static final String DRAFT_STATUS = 'Draft';

    @isTest
    static void activatingOrderWithoutContractThrowsValidationError() {
        Order ord = createDraftOrder();
        addOrderLineItem(ord);
        ord.Status = ACTIVATED_STATUS;

        Test.startTest();
        try {
            update ord;
            System.assert(false, 'Expected a DmlException from the validation rule but none was thrown.');
        } catch (DmlException dmlEx) {
            System.assert(
                dmlEx.getMessage().contains('Contract is required to activate an order'),
                'Unexpected error message: ' + dmlEx.getMessage()
            );
        }
        Test.stopTest();
    }

    @isTest
    static void activatingOrderWithContractSucceeds() {
        Order ord = createDraftOrder();
        addOrderLineItem(ord);

        Contract ctr = new Contract(AccountId = ord.AccountId, StartDate = Date.today());
        insert ctr;
        ctr.Status = ACTIVATED_STATUS;
        update ctr;

        ord.ContractId = ctr.Id;
        ord.Status = ACTIVATED_STATUS;

        Test.startTest();
        update ord;
        Test.stopTest();

        Order updated = [SELECT Status FROM Order WHERE Id = :ord.Id];
        System.assertEquals(ACTIVATED_STATUS, updated.Status);
    }

    @isTest
    static void draftOrderWithoutContractSucceeds() {
        Test.startTest();
        Order ord = createDraftOrder();
        Test.stopTest();

        System.assertNotEquals(null, ord.Id, 'Draft Order without a Contract should still be insertable.');
    }

    // --- test data helpers ---

    private static Order createDraftOrder() {
        Account acc = new Account(Name = 'Acme Corp', BillingCountryCode = 'US');
        insert acc;

        Order ord = new Order(
            AccountId = acc.Id,
            Status = DRAFT_STATUS,
            EffectiveDate = Date.today(),
            Pricebook2Id = Test.getStandardPricebookId()
        );
        insert ord;
        return ord;
    }

    private static void addOrderLineItem(Order ord) {
        // Salesforce won't activate an Order with zero products, independent
        // of our own Order_Contract_Required_For_Activation rule - tests that
        // activate an Order need at least one OrderItem or that system check
        // fires first and masks whatever this test is actually targeting.
        Product2 prod = new Product2(Name = 'Test Product', IsActive = true);
        insert prod;

        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = prod.Id,
            UnitPrice = 100,
            IsActive = true
        );
        insert pbe;

        insert new OrderItem(
            OrderId = ord.Id,
            PricebookEntryId = pbe.Id,
            Quantity = 1,
            UnitPrice = 100
        );
    }
}
