# Salesforce deployment metadata (Phase 1)

This folder is **not a full org** - it is a reference pattern for Phase 1
(build the org / L2C objects and their validation rules) so Phase 1 and
Phase 2 (automation) stay in sync from day one.

Declarative metadata only (validation rules, fields). The paired Apex test
classes live in a separate, independently deployable folder: `../apex-tests/`.

Quote, Order and Contract are disabled by default in a new org - see
`docs/enable-lead-to-cash-features.md` before deploying those objects' rules.

## Rules included

| Object | Rule(s) | Apex test class |
|---|---|---|
| Lead | Email or Phone required | `LeadValidationRulesTest.cls` |
| Account | Billing Country required; US billing postal code format (covers the "Address" module) | `AccountValidationRulesTest.cls` |
| Contact | Account required | `ContactValidationRulesTest.cls` |
| Opportunity | Amount > 0 required to close as Won | `OpportunityValidationRulesTest.cls` |
| Quote | At least one line item required to approve (needs `Total_Quote_Lines__c` roll-up field) | `QuoteValidationRulesTest.cls` |
| Order | Contract required to activate | `OrderValidationRulesTest.cls` |
| Contract | Start Date required | `ContractValidationRulesTest.cls` |

These are realistic **generic** rules meant to be adjusted to your org's real
business logic - swap the formulas, not the overall pattern (one rule +
one paired Apex test per business constraint).

## How to use this

1. Create a Salesforce DX project in your own repo: `sf project generate --name l2c-org`.
2. For every validation rule you add declaratively in the org (or as metadata),
   retrieve it into `force-app/main/default/objects/<Object>/validationRules/`
   using the same naming convention as `Lead_Email_Or_Phone_Required.validationRule-meta.xml`.
3. Pair every validation rule with an Apex test class under
   `../apex-tests/force-app/main/default/classes/`, following
   `LeadValidationRulesTest.cls`: one `@isTest` method per rule, covering the
   failing case and the passing case(s).
4. Deploy through Gearset as usual - this folder and `../apex-tests/` are each
   self-contained SFDX projects (own `sfdx-project.json`), so a Gearset
   compare & deploy job can point at either independently. Gearset's
   **Automated unit testing** picks up the Apex tests automatically on each
   CI job - no extra configuration needed beyond enabling the feature on the
   pipeline.
5. Only after a rule + its Apex test exist, add (or un-tag `@wip` on) the matching
   Cucumber scenario in `../automation/features/<object>/` and implement its
   step definitions in `../automation/step-definitions/`, mirroring `lead.steps.ts`.

## Why both Apex tests and Playwright/Cucumber

- Apex tests validate the **rule logic** itself: fast, cheap, run on every commit.
- Playwright/Cucumber validates the **end-user experience** of the rule inside a
  real Lead-to-Cash journey (e.g. does the error actually surface on the page,
  does a valid path through Lead -> Account -> Opportunity -> Quote -> Order ->
  Contract still work end to end). Slower, so reserved for `@smoke` critical paths.

See `../docs/gearset-integration.md` for how both layers are wired into the
Gearset pipeline (Phase 3).
