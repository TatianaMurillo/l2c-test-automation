# L2C Test Automation — Project Reference

Living reference for this project: why it exists, the approach chosen, what
has been built so far, and what's still open. Meant to be read by anyone
picking up this codebase, including future-you.

## 1. Purpose

An innovation project to bring automated regression testing into the
Salesforce Lead-to-Cash (L2C) release process, triggered automatically by
Gearset on every deployment — replacing manual regression testing of
validation rules and critical business flows across Lead, Account, Contact,
Address, Opportunity, Quote, Order and Contract.

## 2. The idea

Three-phase plan:

1. **Build the org** — L2C objects and their validation rules, version-controlled
   as Salesforce DX metadata, each rule paired with an Apex unit test.
2. **Automate** — a modular UI/E2E test framework covering critical Lead-to-Cash
   journeys and the user-facing behavior of validation rules.
3. **Integrate with Gearset** — Gearset triggers Phase 1's Apex tests natively,
   and triggers Phase 2's suite via an outgoing webhook after each successful
   deployment.

### Key decision: hybrid testing strategy, not a single tool

Salesforce has no built-in way to test validation rules declaratively. The
standard, Gearset-supported approach is an Apex test class per rule (fast,
deterministic, gates the deployment itself). UI-level testing (Playwright or
Gearset's own tooling) is reserved for a smaller set of critical end-to-end
journeys, not for exhaustively re-testing every rule — it's slower and more
expensive to maintain.

| Layer | Tooling | Covers |
|---|---|---|
| Validation rule logic | Apex test classes, run by Gearset's native **Automated unit testing** | Every rule, positive/negative/bulk cases |
| Critical E2E journeys | Custom framework: **TypeScript + Playwright + Cucumber**, triggered by Gearset via outgoing webhook | Full Lead → Account/Contact → Opportunity → Quote → Order → Contract paths, with real users/permissions |
| No-code alternative (considered, not adopted as primary) | Gearset's native AI-powered **Automated Testing** product | Same UI coverage with less maintenance, but less Git-native control |

The custom framework was chosen over Gearset's native no-code UI testing
because the goal is a fully Git-versioned, team-owned framework — the native
option remains a valid fallback or complement if maintenance load becomes
too high.

## 3. What has been done

All work lives in `l2c-test-automation/` (this repo), split into three
independently deployable/runnable folders: `salesforce-deployment/` (metadata),
`apex-tests/` (Apex unit tests), `automation/` (Playwright/Cucumber suite).

### Phase 1 — `salesforce-deployment/` + `apex-tests/`
Two deployable SFDX projects (each its own `sfdx-project.json` + `force-app/`),
kept separate so declarative metadata and Apex test code can be deployed,
reviewed and owned independently:

- `salesforce-deployment/` — one validation rule (generic, realistic — not
  the org's real business rules yet) per object: Lead, Account (×2, one
  covers the "Address" module since Salesforce has no standalone Address
  object), Contact, Opportunity, Quote (plus a supporting
  `Total_Quote_Lines__c` roll-up field), Order, Contract. Also
  `docs/enable-lead-to-cash-features.md` — Setup steps to enable Quotes,
  Orders and Contracts (off by default in a new org).
- `apex-tests/` — a paired Apex `@isTest` class per rule, covering the
  failing and passing case.

### Phase 2 — automation framework
TypeScript + Playwright + Cucumber, in `automation/`, modular by object
(`features/`, `step-definitions/`, `src/pages/`). **Lead is the fully working
reference implementation** (feature file → step definitions → page object). Account,
Contact, Address, Opportunity, Quote, Order and Contract have Gherkin feature
files already written (tagged `@wip`) but no step definitions or page objects
yet — see `README.md`'s status table.

Also in place: shared Cucumber World/hooks with per-scenario browser
isolation, a `BasePage` with common Lightning waits/assertions, a
dependency-free test data factory, ESLint/TypeScript config, and an HTML
report generator.

### Phase 3 — Gearset integration
`docs/gearset-integration.md` + `.github/workflows/gearset-webhook-tests.yml`:
a GitHub Actions workflow triggered by a Gearset outgoing webhook after a
successful deployment, runs the `@smoke` suite, and reports results back to
Gearset. Documented but **not yet wired up** in the actual Gearset job (see
pending items).

### Supporting decisions made along the way
- Removed a `tsconfig` path-alias setup that wouldn't have resolved at
  runtime without `tsconfig-paths` — switched to plain relative imports to
  keep the prototype dependency-light.
- Confirmed no Salesforce or Gearset MCP connector is available in this
  workspace, and this environment's sandbox has no network route to
  Salesforce or the npm registry — so deployment and `npm install`/`tsc`
  verification must happen on Yuly's machine or in CI, not here.

## 4. What's still pending

**Phase 1**
- [ ] Enable Quotes, Orders, Contracts in the org (`salesforce-deployment/docs/enable-lead-to-cash-features.md`).
- [ ] Deploy `salesforce-deployment/force-app` and `apex-tests/force-app` (via `sf project deploy start`, Gearset compare & deploy, or manual Setup entry).
- [ ] Replace the generic rule formulas with the org's real business rules.
- [ ] Run the Apex tests in the org / confirm Gearset's Automated unit testing picks them up.

**Phase 2**
- [ ] Implement page objects + step definitions for Account, Contact, Address, Opportunity, Quote, Order, Contract, following `automation/src/pages/lead/LeadPage.ts` and `automation/step-definitions/lead.steps.ts`.
- [ ] Un-tag `@wip` on each module's feature file as it's completed.
- [ ] Run `npm install && npm run install:browsers && npm run typecheck` from inside `automation/` (not possible from this workspace — no registry access) to confirm the project builds cleanly.
- [ ] Set up a dedicated least-privilege QA automation Salesforce user for the suite to log in as.

**Phase 3**
- [ ] Push this repo to GitHub over SSH (steps already covered in chat).
- [ ] Add the GitHub Actions secrets (`SF_LOGIN_URL`, `SF_USERNAME`, `SF_PASSWORD`, `SF_SECURITY_TOKEN`, `GEARSET_RESULTS_WEBHOOK_URL`).
- [ ] Configure the actual outgoing webhook on the Gearset CI/CD job (only once Phase 2 has at least one `@smoke` scenario per critical object — wiring it earlier just adds noise).

## 5. Where things live

```
l2c-test-automation/
├── README.md                        # architecture, how to run, how to extend
├── docs/
│   ├── project-reference.md         # this file
│   └── gearset-integration.md       # Phase 3 webhook wiring
├── salesforce-deployment/           # Phase 1 — declarative metadata
│   ├── sfdx-project.json
│   ├── docs/enable-lead-to-cash-features.md
│   └── force-app/main/default/objects/
├── apex-tests/                      # Phase 1 — paired Apex unit tests
│   ├── sfdx-project.json
│   └── force-app/main/default/classes/
├── automation/                      # Phase 2 — features/ · step-definitions/ · src/
└── .github/workflows/               # Phase 3 (must stay at repo root for GitHub Actions)
```
