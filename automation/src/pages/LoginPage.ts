import { Page } from '@playwright/test';

export class LoginPage {
  constructor(private readonly page: Page) {}

  async login(loginUrl: string, username: string, password: string): Promise<void> {
    await this.page.goto(loginUrl);
    await this.page.getByLabel('Username').fill(username);
    await this.page.getByLabel('Password').fill(password);
    await this.page.getByRole('button', { name: 'Log In' }).click();

    // Lightning Experience takes a moment to render after login redirect.
    await this.page.waitForURL(/lightning\/(page|o)/, { timeout: 30_000 }).catch(() => {
      // Some orgs land on a different default landing page; not a hard failure here,
      // downstream navigation calls will fail loudly if the session is not valid.
    });
  }
}
