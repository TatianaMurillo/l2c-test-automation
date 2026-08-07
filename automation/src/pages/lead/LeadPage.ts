import { Page } from '@playwright/test';
import { BasePage } from '../BasePage';

export interface LeadInput {
  lastName: string;
  company: string;
  email?: string;
  phone?: string;
  leadSource?: string;
  status?: string;
}

/**
 * Page object for the standard Lead record form.
 * Field labels below match Salesforce standard field labels; rename them
 * here (not in feature files or step definitions) if your org uses
 * custom labels or a different page layout.
 */
export class LeadPage extends BasePage {
  constructor(page: Page) {
    super(page);
  }

  async openNewLeadForm(): Promise<void> {
    await this.page.goto('/lightning/o/Lead/new');
    await this.waitForLightningToSettle();
  }

  async fillForm(input: LeadInput): Promise<void> {
    await this.fillFieldByLabel('Last Name', input.lastName);
    await this.fillFieldByLabel('Company', input.company);

    if (input.email) {
      await this.fillFieldByLabel('Email', input.email);
    }
    if (input.phone) {
      await this.fillFieldByLabel('Phone', input.phone);
    }
    if (input.leadSource) {
      await this.selectPicklistByLabel('Lead Source', input.leadSource);
    }
    if (input.status) {
      await this.selectPicklistByLabel('Lead Status', input.status);
    }
  }

  async createLead(input: LeadInput): Promise<void> {
    await this.openNewLeadForm();
    await this.fillForm(input);
    await this.clickSave();
  }
}
