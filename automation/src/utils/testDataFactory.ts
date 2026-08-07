/**
 * Lightweight, dependency-free random test data generator.
 * Keeps every scenario run idempotent (unique names avoid clashing with
 * leftover records from previous runs) without pulling in a full library.
 */
function randomSuffix(): string {
  return `${Date.now()}-${Math.floor(Math.random() * 10_000)}`;
}

export const testData = {
  uniqueLastName(prefix = 'AutoQA'): string {
    return `${prefix}-${randomSuffix()}`;
  },

  uniqueCompanyName(prefix = 'AutoQA Inc'): string {
    return `${prefix} ${randomSuffix()}`;
  },

  uniqueEmail(prefix = 'autoqa'): string {
    return `${prefix}.${randomSuffix()}@example-test.com`;
  },

  randomPhone(): string {
    const digits = () => Math.floor(Math.random() * 10);
    return `555${Array.from({ length: 7 }, digits).join('')}`;
  },
};
