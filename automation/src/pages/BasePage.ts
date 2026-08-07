import { Page, Locator, expect } from '@playwright/test';

/**
 * Shared behaviour for every Salesforce Lightning page object.
 * Object-specific page objects (LeadPage, AccountPage, ...) extend this
 * class instead of duplicating Lightning-specific waits and selectors.
 */
export abstract class BasePage {
  protected readonly page: Page;

  constructor(page: Page) {
    this.page = page;
  }

  /** Waits for the Lightning spinner to disappear after navigation or save. */
  async waitForLightningToSettle(): Promise<void> {
    const spinner = this.page.locator('.slds-spinner_container');
    await spinner
      .waitFor({ state: 'hidden', timeout: 15_000 })
      .catch(() => {
        /* spinner may never have appeared - that's fine */
      });
  }

  /** Fills a Lightning input field identified by its form label. */
  async fillFieldByLabel(label: string, value: string): Promise<void> {
    const field = this.page.getByLabel(label, { exact: true });
    await field.fill(value);
  }

  /** Selects a value in a Lightning combobox (picklist) identified by its label. */
  async selectPicklistByLabel(label: string, optionText: string): Promise<void> {
    const combobox = this.page.getByLabel(label, { exact: true });
    await combobox.click();
    await this.page.getByRole('option', { name: optionText, exact: true }).click();
  }

  /** Clicks the standard Lightning record form "Save" button. */
  async clickSave(): Promise<void> {
    await this.page.getByRole('button', { name: 'Save', exact: true }).click();
    await this.waitForLightningToSettle();
  }

  /**
   * Returns the error banner Salesforce shows at the top of a record form
   * when a validation rule blocks a save.
   */
  errorBanner(): Locator {
    return this.page.locator('.slds-notify_alert, .forceFormPageError');
  }

  async expectValidationError(expectedMessageFragment: string): Promise<void> {
    const banner = this.errorBanner();
    await expect(banner).toBeVisible({ timeout: 10_000 });
    await expect(banner).toContainText(expectedMessageFragment);
  }

  async expectNoValidationError(): Promise<void> {
    await expect(this.errorBanner()).toHaveCount(0);
  }

  async expectRecordSavedToast(): Promise<void> {
    await expect(this.page.getByText(/was (created|saved)/i)).toBeVisible({ timeout: 10_000 });
  }
}
