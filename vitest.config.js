// vitest.config.js
import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    include: ['**/*.{test,spec}.{js,ts}'],
    globals: true,
    environment: 'node', // Change this if you're using a different environment
  },
});
