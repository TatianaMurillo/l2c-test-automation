import { PlaywrightTestConfig } from '@playwright/test';

/**
 * Playwright is used here only as the browser automation engine.
 * Test orchestration, tagging and reporting are handled by Cucumber
 * (see cucumber.js and src/support/world.ts).
 */
const config: PlaywrightTestConfig = {
  use: {
    headless: process.env.HEADLESS !== 'false',
    viewport: { width: 1440, height: 900 },
    ignoreHTTPSErrors: false,
    actionTimeout: 15_000,
    navigationTimeout: 30_000,
    trace: 'retain-on-failure',
    screenshot: 'only-on-failure',
    video: 'retain-on-failure',
  },
  timeout: 60_000,
};

export default config;
