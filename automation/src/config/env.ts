import * as dotenv from 'dotenv';

dotenv.config();

/**
 * Central, typed access point for all environment configuration.
 * Fails fast at startup if a required variable is missing, instead of
 * surfacing a confusing failure deep inside a test step.
 */
function requireEnv(name: string): string {
  const value = process.env[name];
  if (!value) {
    throw new Error(
      `Missing required environment variable "${name}". ` +
        'Copy .env.example to .env (locally) or set it as a CI secret.'
    );
  }
  return value;
}

export const env = {
  salesforce: {
    loginUrl: requireEnv('SF_LOGIN_URL'),
    username: requireEnv('SF_USERNAME'),
    password: requireEnv('SF_PASSWORD'),
    securityToken: process.env.SF_SECURITY_TOKEN ?? '',
    orgAlias: process.env.SF_ORG_ALIAS ?? 'default',
  },
  playwright: {
    headless: process.env.HEADLESS !== 'false',
  },
} as const;
