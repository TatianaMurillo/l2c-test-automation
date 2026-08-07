# L2C Test Automation

Modular TypeScript + Playwright + Cucumber framework for testing Salesforce
Lead-to-Cash validation rules and critical journeys, triggered from a Gearset
CI/CD pipeline after each deployment.

Covers: **Lead, Account, Contact, Address, Opportunity, Quote, Order, Contract.**

## Project status

| Module | Validation rule (Phase 1) | Feature file | Step definitions | Page object | Status |
|---|---|---|---|---|---|
| Lead | ✅ | ✅ | ✅ | ✅ | Reference implementation |
| Account | ✅ | ✅ (template) | ❌ | ❌ | `@wip` |
| Contact | ✅ | ✅ (template) | ❌ | ❌ | `@wip` |
| Address | ✅ (on Account) | ✅ (template) | ❌ | ❌ | `@wip` |
| Opportunity | ✅ | ✅ (template) | ❌ | ❌ | `@wip` |
| Quote | ✅ | ✅ (template) | ❌ | ❌ | `@wip` |
| Order | ✅ | ✅ (template) | ❌ | ❌ | `@wip` |
| Contract | ✅ | ✅ (template) | ❌ | ❌ | `@wip` |

Phase 1 (`salesforce-deployment/` + `apex-tests/`) now has a validation rule +
Apex test for every object. Lead is the only module fully wired end to end
(feature → step definitions → page object) for Phase 2 - it's the pattern to
copy for every other module once you're ready to automate them.

## Repo layout at a glance

Three concerns, kept in separate folders:

- `salesforce-deployment/` - declarative Salesforce metadata (validation
  rules, fields).
- `apex-tests/` - paired Apex `@isTest` classes.
- `automation/` - the TypeScript + Playwright + Cucumber UI/E2E framework
  (Phase 2). Its own `package.json`; all `npm` commands run from inside it.

`salesforce-deployment/` and `apex-tests/` are declared as `packageDirectories`
in a single `sfdx-project.json` **at the repo root** - Gearset's Compare and
deploy (and the `sf` CLI) only recognize one `sfdx-project.json` per repo, and
it must be at the root, so the two folders deploy together as one SFDX
project even though they're physically separate.

## Why this shape (3-phase plan)

1. **Phase 1 - build the org.** L2C objects and their validation rules,
   version-controlled as SFDX metadata in `salesforce-deployment/`, each
   paired with an Apex test class in `apex-tests/` (the fast, cheap layer of
   the testing strategy).
2. **Phase 2 - automate.** `automation/`. UI/E2E coverage of critical
   journeys and the user-facing side of validation rules (the slower,
   higher-value layer, reserved for `@smoke` paths, not every single rule).
3. **Phase 3 - integrate with Gearset.** Gearset triggers Phase 1's Apex
   tests natively ("Automated unit testing"), and triggers this repo's suite
   through an outgoing webhook after each successful deployment. Full
   walkthrough in `docs/gearset-integration.md`.

See the chat conversation for the comparison between this approach and
Gearset's native no-code Automated Testing product - both are documented as
options in `docs/gearset-integration.md`.

## Project structure

```
l2c-test-automation/
├── automation/                    # Phase 2: TypeScript + Playwright + Cucumber
│   ├── features/                  # Gherkin, one folder per L2C object
│   │   ├── lead/
│   │   ├── account/                # ...and so on for each object
│   ├── step-definitions/          # One file per object, mirrors features/
│   ├── src/
│   │   ├── config/env.ts          # Typed, validated environment config
│   │   ├── pages/                 # Page Object Model, one folder per object
│   │   │   ├── BasePage.ts        # Shared Lightning waits/assertions
│   │   │   └── lead/LeadPage.ts
│   │   ├── support/                # Cucumber World + hooks (session, screenshots)
│   │   └── utils/testDataFactory.ts # Unique test data generation
│   └── package.json
├── apex-tests/                    # Phase 1: paired Apex @isTest classes
├── salesforce-deployment/         # Phase 1: validation rules + fields
├── sfdx-project.json              # packageDirectories -> both folders above (must stay at repo root)
├── docs/gearset-integration.md    # Phase 3: webhook wiring
└── .github/workflows/             # Runs when Gearset's webhook fires (must stay at repo root)
```

## Running locally

```bash
cd automation
npm install
npm run install:browsers      # downloads the Chromium build Playwright needs
cp .env.example .env          # fill in a dedicated QA automation user
npm test                      # runs every implemented (non-@wip) scenario
npm run test:lead             # just the Lead module
npm run test:smoke            # only @smoke-tagged critical-path scenarios
```

## Adding a new object module (e.g. Account)

1. Un-tag `@wip` in `automation/features/account/account-validation-rules.feature`
   and replace the placeholder scenario with the org's real validation rules.
2. Create `automation/src/pages/account/AccountPage.ts` extending `BasePage`,
   following `automation/src/pages/lead/LeadPage.ts`.
3. Create `automation/step-definitions/account.steps.ts`, following `lead.steps.ts`.
4. Add the paired Apex test class under
   `apex-tests/force-app/main/default/classes/`.
5. Run `npx cucumber-js --tags @account` from inside `automation/` before opening a PR.

## Conventions

- One module = one object. No cross-object step definitions except in
  `common.steps.ts` (session/navigation only) - keeps modules independent so
  teams can own a module each without merge conflicts.
- Page objects never contain assertions beyond simple state checks; test
  intent lives in step definitions, not page objects.
- All error-message assertions use `toContainText`, not exact match, so
  minor copy changes to a validation rule's message don't break unrelated
  tests.
- Every scenario creates its own uniquely-named data (`testDataFactory.ts`)
  instead of relying on fixture records, so the suite is safe to run in
  parallel and repeatedly against the same sandbox.
