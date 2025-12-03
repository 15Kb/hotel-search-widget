import React from 'react';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import axios from 'axios';
import SearchForm from './SearchForm';

jest.mock('axios');

describe('SearchForm', () => {
  const mockOnSearch = jest.fn();

  beforeEach(() => {
    jest.clearAllMocks();
    // Mock cities API
    axios.get.mockResolvedValue({
      data: {
        cities: ['Hollywood', 'Miami', 'Fort Lauderdale', 'Tampa'],
      },
    });
  });

  it('renders location input and search button', async () => {
    render(<SearchForm onSearch={mockOnSearch} isLoading={false} />);

    await waitFor(() => {
      expect(screen.getByPlaceholderText(/select or enter city/i)).toBeInTheDocument();
    });
    expect(screen.getByRole('button', { name: /search/i })).toBeInTheDocument();
  });

  it('fetches cities on mount', async () => {
    render(<SearchForm onSearch={mockOnSearch} isLoading={false} />);

    await waitFor(() => {
      expect(axios.get).toHaveBeenCalledWith('/api/hotels/cities');
    });
  });





  it('does not submit form when location is empty', () => {
    render(<SearchForm onSearch={mockOnSearch} isLoading={false} />);

    const searchButton = screen.getByRole('button', { name: /search/i });
    fireEvent.click(searchButton);

    expect(mockOnSearch).not.toHaveBeenCalled();
  });

  it('disables search button when loading', () => {
    render(<SearchForm onSearch={mockOnSearch} isLoading />);

    const searchButton = screen.getByRole('button', { name: /searching/i });
    expect(searchButton).toBeDisabled();
  });


});

