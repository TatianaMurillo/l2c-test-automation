import { setWorldConstructor, World, IWorldOptions } from '@cucumber/cucumber';
import { Browser, BrowserContext, Page } from '@playwright/test';

/**
 * Custom Cucumber World shared by every step definition.
 * Holds the Playwright session for the current scenario plus a small
 * typed bag for passing data between steps within the same scenario
 * (e.g. the record ID created in a "Given" step, needed later in a "Then").
 */
export class L2CWorld extends World {
  browser!: Browser;
  context!: BrowserContext;
  page!: Page;

  // Scenario-scoped data, reset by hooks.ts before every scenario.
  scenarioData: Record<string, unknown> = {};

  constructor(options: IWorldOptions) {
    super(options);
  }

  setData<T>(key: string, value: T): void {
    this.scenarioData[key] = value;
  }

  getData<T>(key: string): T {
    if (!(key in this.scenarioData)) {
      throw new Error(`No scenario data stored under key "${key}".`);
    }
    return this.scenarioData[key] as T;
  }
}

setWorldConstructor(L2CWorld);
