# Phase 3: wiring this framework into the Gearset pipeline

Gearset does not run arbitrary Node/Playwright code itself. It triggers this
framework the same way it triggers Provar or Testsigma: through an **outgoing
webhook** fired after a successful CI deployment. The actual test run happens
in GitHub Actions (or GitLab/Bitbucket/Azure DevOps - Gearset has an
equivalent guide for each).

## 1. Configure the CI job in Gearset

In the Gearset CI/CD job that deploys to your QA/UAT org:

1. Open the job's **Outgoing webhooks** section.
2. Add a webhook that POSTs to GitHub's `repository_dispatch` API:
   `https://api.github.com/repos/<org>/<repo>/dispatches`
3. Trigger it on **"Deployment succeeded"** only (not on failure - there is
   nothing to regression-test if the deployment itself failed).
4. Set the payload so it matches the `gearset-deployment-succeeded` event
   type declared in `.github/workflows/gearset-webhook-tests.yml`:

   ```json
   {
     "event_type": "gearset-deployment-succeeded",
     "client_payload": {
       "targetOrg": "{{TargetOrgName}}",
       "deploymentId": "{{DeploymentId}}"
     }
   }
   ```

   (`{{TargetOrgName}}` / `{{DeploymentId}}` are Gearset's dynamic webhook
   variables - see "Outgoing webhooks in continuous integration jobs" in the
   Gearset help center for the full variable list.)
5. Add a GitHub PAT with `repo` scope as the webhook's Authorization header
   (`Bearer <token>`), stored as a Gearset secret, not hardcoded.

## 2. Configure secrets on the GitHub side

In the repository holding this framework, add these Actions secrets:

- `SF_LOGIN_URL`, `SF_USERNAME`, `SF_PASSWORD`, `SF_SECURITY_TOKEN` - a
  dedicated read/write **automation user** in the target org, least-privilege,
  never a real person's credentials.
- `GEARSET_RESULTS_WEBHOOK_URL` - lets the workflow report pass/fail back into
  Gearset so results show up next to the deployment, not just in GitHub.

## 3. What actually runs on each deployment

- Only scenarios tagged `@smoke` run automatically post-deployment (fast
  feedback, critical Lead-to-Cash paths only). Full `@validation-rule`
  regression runs on a nightly schedule instead (add a `schedule:` trigger
  to the workflow when there are enough implemented modules to justify it).
- Apex validation-rule unit tests are **not** part of this workflow - they
  run through Gearset's own **Automated unit testing** feature, which is
  faster and gates the deployment itself rather than running after it.

## 4. Rollout order (matches the 3-phase plan)

1. **Phase 1** - build the org: L2C objects + validation rules
   (`../salesforce-deployment/`) + paired Apex tests (`../apex-tests/`).
   Both folders are declared as `packageDirectories` in a single
   `../sfdx-project.json` **at the repo root** - Gearset's Compare and
   deploy (source control mode) only recognizes one `sfdx-project.json` per
   repo, and requires it at the root, so point Gearset's source control
   connection at the repo root, not at either subfolder individually. Both
   deploy together in one job.
2. **Phase 2** - build out this framework module by module (Lead is done;
   Account, Contact, Address, Opportunity, Quote, Order, Contract are
   `@wip` templates - implement them the same way as `lead.steps.ts`).
3. **Phase 3** - only once Phase 2 has at least one `@smoke` scenario per
   critical object, wire up this webhook so Gearset starts triggering it
   automatically. Wiring CI before there is anything meaningful to run just
   adds noise.

## Alternative considered: Gearset's native Automated Testing

Gearset also ships its own no-code, AI-driven UI testing product, built into
Pipelines, that could replace this entire framework for teams that don't want
to maintain Playwright code. It was not chosen as the primary approach here
because this project's goal is a Git-versioned, code-based framework the team
fully owns and can evolve - but it is a valid fallback if maintenance load
becomes too high, and the two can coexist (e.g. native testing for
low-priority modules, this framework for the ones with the most business risk).
