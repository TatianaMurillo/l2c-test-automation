import { Given } from '@cucumber/cucumber';
import { L2CWorld } from '../src/support/world';

// Session is already established in the Before hook (see src/support/hooks.ts),
// so this step is intentionally a no-op assertion point that keeps feature
// files readable as living documentation for non-technical stakeholders.
Given('I am logged into Salesforce as a Sales user', async function (this: L2CWorld) {
  if (!this.page.url() || this.page.url() === 'about:blank') {
    throw new Error('Expected an authenticated Salesforce session to already be active.');
  }
});
