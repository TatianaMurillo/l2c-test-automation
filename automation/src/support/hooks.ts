import { Before, After, BeforeAll, AfterAll, Status } from '@cucumber/cucumber';
import { chromium, Browser } from '@playwright/test';
import { env } from '../config/env';
import { L2CWorld } from './world';
import { LoginPage } from '../pages/LoginPage';

let browser: Browser;

BeforeAll(async function () {
  browser = await chromium.launch({ headless: env.playwright.headless });
});

AfterAll(async function () {
  await browser.close();
});

// Every scenario gets an isolated browser context (own cookies/session),
// so tests can run in parallel without leaking Salesforce sessions between them.
Before(async function (this: L2CWorld) {
  this.browser = browser;
  this.context = await browser.newContext();
  this.page = await this.context.newPage();
  this.scenarioData = {};

  const loginPage = new LoginPage(this.page);
  await loginPage.login(env.salesforce.loginUrl, env.salesforce.username, env.salesforce.password);
});

After(async function (this: L2CWorld, { result, pickle }) {
  if (result?.status === Status.FAILED) {
    const screenshot = await this.page.screenshot({ fullPage: true });
    this.attach(screenshot, 'image/png');
    // eslint-disable-next-line no-console
    console.error(`Scenario failed: "${pickle.name}"`);
  }
  await this.context.close();
});
