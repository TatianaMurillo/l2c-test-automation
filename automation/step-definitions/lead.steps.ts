import { When, Then } from '@cucumber/cucumber';
import { L2CWorld } from '../src/support/world';
import { LeadPage, LeadInput } from '../src/pages/lead/LeadPage';

When(
  'I create a Lead with last name {string}, company {string} and no email or phone',
  async function (this: L2CWorld, lastName: string, company: string) {
    const leadPage = new LeadPage(this.page);
    const input: LeadInput = { lastName, company };
    await leadPage.createLead(input);
    this.setData('leadPage', leadPage);
  }
);

When(
  'I create a Lead with last name {string}, company {string} and email {string}',
  async function (this: L2CWorld, lastName: string, company: string, email: string) {
    const leadPage = new LeadPage(this.page);
    const input: LeadInput = { lastName, company, email };
    await leadPage.createLead(input);
    this.setData('leadPage', leadPage);
  }
);

When(
  'I create a Lead with last name {string}, company {string} and phone {string}',
  async function (this: L2CWorld, lastName: string, company: string, phone: string) {
    const leadPage = new LeadPage(this.page);
    const input: LeadInput = { lastName, company, phone };
    await leadPage.createLead(input);
    this.setData('leadPage', leadPage);
  }
);

Then('the Lead should not be saved', async function (this: L2CWorld) {
  const leadPage = this.getData<LeadPage>('leadPage');
  await leadPage.expectValidationError('');
});

Then('the Lead should be saved successfully', async function (this: L2CWorld) {
  const leadPage = this.getData<LeadPage>('leadPage');
  await leadPage.expectNoValidationError();
  await leadPage.expectRecordSavedToast();
});

Then('I should see a validation error containing {string}', async function (this: L2CWorld, message: string) {
  const leadPage = this.getData<LeadPage>('leadPage');
  await leadPage.expectValidationError(message);
});
