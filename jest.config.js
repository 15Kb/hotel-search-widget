module.exports = {
  testEnvironment: 'jsdom',
  setupFilesAfterEnv: ['<rootDir>/front/js/setupTests.js'],
  moduleNameMapper: {
    '\\.(css|scss|sass)$': 'identity-obj-proxy',
  },
  transform: {
    '^.+\\.(js|jsx)$': 'babel-jest',
  },
  transformIgnorePatterns: [
    'node_modules/(?!(@testing-library)/)',
  ],
  testMatch: [
    '<rootDir>/front/js/**/*.test.js',
    '<rootDir>/front/js/**/*.spec.js',
  ],
  collectCoverageFrom: [
    'front/js/**/*.{js,jsx}',
    '!front/js/app.js',
    '!front/js/setupTests.js',
  ],
};

