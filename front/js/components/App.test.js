import React from 'react';
import { render, screen } from '@testing-library/react';
import axios from 'axios';
import App from './App';

jest.mock('axios');

describe('App', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    // Mock cities API
    axios.get.mockResolvedValue({
      data: {
        cities: ['Hollywood', 'Miami'],
      },
    });
  });

  it('renders without crashing', () => {
    render(<App />);
    expect(screen.getByText('Find Your Perfect Hotel')).toBeInTheDocument();
  });
});

