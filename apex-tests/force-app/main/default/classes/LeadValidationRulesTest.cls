@isTest
private class LeadValidationRulesTest {
    // Companion Apex test to the "Email or Phone is required" validation rule.
    // This is the fast, deterministic layer of the hybrid strategy: it runs
    // as part of Gearset's native Automated unit testing on every CI job,
    // independent of the slower Playwright + Cucumber UI suite.

    @isTest
    static void savingLeadWithoutEmailOrPhoneThrowsValidationError() {
        Lead newLead = new Lead(
            LastName = 'Doe',
            Company = 'Acme Corp'
        );

        Test.startTest();
        try {
            insert newLead;
            System.assert(false, 'Expected a DmlException from the validation rule but none was thrown.');
        } catch (DmlException dmlEx) {
            System.assert(
                dmlEx.getMessage().contains('Email or Phone is required'),
                'Unexpected error message: ' + dmlEx.getMessage()
            );
        }
        Test.stopTest();
    }

    @isTest
    static void savingLeadWithEmailSucceeds() {
        Lead newLead = new Lead(
            LastName = 'Doe',
            Company = 'Acme Corp',
            Email = 'doe@example-test.com'
        );

        Test.startTest();
        insert newLead;
        Test.stopTest();

        System.assertNotEquals(null, newLead.Id, 'Lead should have been inserted successfully.');
    }

    @isTest
    static void savingLeadWithPhoneSucceeds() {
        Lead newLead = new Lead(
            LastName = 'Doe',
            Company = 'Acme Corp',
            Phone = '5551234567'
        );

        Test.startTest();
        insert newLead;
        Test.stopTest();

        System.assertNotEquals(null, newLead.Id, 'Lead should have been inserted successfully.');
    }
}
