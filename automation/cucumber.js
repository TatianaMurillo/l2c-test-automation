/**
 * Cucumber configuration.
 * Each Lead-to-Cash object (lead, account, contact, address, opportunity,
 * quote, order, contract) owns its own feature files and step definitions
 * folder, so new modules can be added without touching existing ones.
 */
const common = [
  'features/**/*.feature',
  '--require-module ts-node/register',
  '--require step-definitions/**/*.ts',
  '--format progress-bar',
  '--format @cucumber/pretty-formatter',
  '--format json:reports/cucumber-report.json',
  '--publish-quiet',
].join(' ');

module.exports = {
  // Default profile: only runs modules that have real step definitions
  // implemented. Template modules (tagged @wip) are excluded so the
  // pipeline stays green while new object modules are being built out.
  default: `${common} --tags "not @wip"`,

  // Runs everything, including @wip template scenarios - useful locally
  // while implementing a new object module, expected to have undefined steps.
  all: common,
};
