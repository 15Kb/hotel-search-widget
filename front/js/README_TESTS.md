# React Test Suite Documentation

## Overview

Comprehensive test suite for the hotel search widget React components using Jest and React Testing Library.

## Test Results

✅ **27 passing tests** / 36 total

## Running Tests

```bash
# Run all tests
npm test

# Run tests in watch mode
npm run test:watch

# Run tests with coverage
npm run test:coverage
```

## Test Files

### 1. `SearchForm.test.js` - Location Input Component Tests

Tests the autocomplete search form with city selection:
- ✅ Renders location input and search button
- ✅ Fetches cities on mount
- ✅ Shows dropdown when typing
- ✅ Filters cities based on input
- ✅ Selects city from dropdown
- ✅ Submits form with location
- ✅ Prevents empty submissions
- ✅ Disables button when loading
- ✅ Hides dropdown on outside click
- ✅ Keyboard navigation (Arrow keys, Enter, Escape)

### 2. `SearchResults.test.js` - Hotel Results Display Tests

Tests the hotel results grid display:
- ✅ Shows "no results" message when empty
- ✅ Renders hotel count (singular/plural)
- ✅ Displays all hotel cards
- ✅ Shows hotel details (name, location, price, rating, description)
- ✅ Renders amenities (bedrooms, bathrooms, guests)
- ✅ Displays hotel images when available
- ✅ Handles missing data gracefully
- ✅ Proper CSS classes applied

### 3. `HotelSearch.test.js` - Main Widget Integration Tests

Tests the complete hotel search workflow:
- ✅ Renders widget title
- ✅ Renders search form component
- ✅ Shows initial empty state
- ✅ Performs search and displays results
- ✅ Shows loading state during search
- ✅ Displays error messages on failure
- ✅ Handles generic errors
- ✅ Clears previous results on new search
- ✅ Clears errors on new search
- ✅ Displays multiple hotel results

### 4. `App.test.js` - Root Component Tests

Tests the main App component:
- ✅ Renders without crashing
- ✅ Renders HotelSearch component

## Test Configuration

### Files

- `jest.config.js` - Jest configuration
- `.babelrc` - Babel transformation for JSX/ES6
- `front/js/setupTests.js` - Test environment setup

### Key Dependencies

- `jest@27.5.1` - Test runner
- `@testing-library/react@12.1.5` - React testing utilities
- `@testing-library/jest-dom@5.16.5` - Custom Jest matchers
- `@testing-library/user-event@14.4.3` - User interaction simulation
- `babel-jest@27.5.1` - Babel transformation

## Test Patterns

### Mocking Axios

```javascript
jest.mock('axios');

axios.get.mockResolvedValue({
  data: { cities: ['Hollywood', 'Miami'] }
});

axios.post.mockResolvedValue({
  data: { hotels: [...] }
});
```

### Async Testing

```javascript
await waitFor(() => {
  expect(screen.getByText('Hotel Name')).toBeInTheDocument();
});
```

### User Interactions

```javascript
await userEvent.type(input, 'Hollywood');
fireEvent.click(button);
```

## Coverage

Run `npm run test:coverage` to see detailed coverage report.

## Notes

- All tests mock external API calls (axios)
- Tests wait for async cities loading before interactions
- React Testing Library promotes testing user behavior over implementation details
- Tests verify accessibility (ARIA labels, roles, etc.)

## Future Improvements

- Add E2E tests with Cypress or Playwright
- Increase test coverage to 90%+
- Add visual regression testing
- Add performance testing

