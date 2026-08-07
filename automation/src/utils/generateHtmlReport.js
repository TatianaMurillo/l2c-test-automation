/**
 * Converts the raw Cucumber JSON output into a browsable HTML report.
 * Run after any test script that writes reports/cucumber-report.json.
 */
const report = require('multiple-cucumber-html-reporter');

report.generate({
  jsonDir: 'reports',
  reportPath: 'reports/html',
  metadata: {
    browser: { name: 'chromium', version: 'latest' },
    device: 'CI runner',
    platform: { name: process.platform },
  },
});
