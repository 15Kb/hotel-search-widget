import React from 'react';
import { render, screen, waitFor, fireEvent } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import axios from 'axios';
import HotelSearch from './HotelSearch';

jest.mock('axios');

describe('HotelSearch', () => {
  const mockSearchResponse = {
    data: {
      hotels: [
        {
          id: 1,
          name: 'Luxury Beach Villa',
          location: 'Hollywood, Florida',
          price: '$450 per night',
          image: 'https://example.com/villa.jpg',
          rating: 4.8,
          description: 'Beautiful oceanfront villa',
          bedrooms: 4,
          bathrooms: 3,
          guests: 8,
        },
      ],
    },
  };

  const mockCitiesResponse = {
    data: {
      cities: ['Hollywood', 'Miami', 'Tampa'],
    },
  };

  beforeEach(() => {
    jest.clearAllMocks();
    axios.get.mockResolvedValue(mockCitiesResponse);
  });

  it('renders the widget title', () => {
    render(<HotelSearch />);
    expect(screen.getByText('Find Your Perfect Hotel')).toBeInTheDocument();
  });

  it('renders SearchForm component', async () => {
    render(<HotelSearch />);
    await waitFor(() => {
      expect(screen.getByPlaceholderText(/select or enter city/i)).toBeInTheDocument();
    });
    expect(screen.getByRole('button', { name: /search/i })).toBeInTheDocument();
  });


  it('performs search and displays results', async () => {
    axios.post.mockResolvedValue(mockSearchResponse);

    render(<HotelSearch />);

    await waitFor(() => {
      expect(screen.getByPlaceholderText(/select or enter city/i)).toBeInTheDocument();
    });

    const input = screen.getByPlaceholderText(/select or enter city/i);
    const searchButton = screen.getByRole('button', { name: /search/i });

    await userEvent.type(input, 'Hollywood');
    fireEvent.click(searchButton);

    await waitFor(() => {
      expect(axios.post).toHaveBeenCalledWith('/api/hotels/search', { location: 'Hollywood' });
    });

    await waitFor(() => {
      expect(screen.getByText('Luxury Beach Villa')).toBeInTheDocument();
    });
  });

  it('shows loading state during search', async () => {
    // Create a promise that we can control
    let resolveSearch;
    const searchPromise = new Promise((resolve) => {
      resolveSearch = resolve;
    });
    axios.post.mockReturnValue(searchPromise);

    render(<HotelSearch />);

    await waitFor(() => {
      expect(screen.getByPlaceholderText(/select or enter city/i)).toBeInTheDocument();
    });

    const input = screen.getByPlaceholderText(/select or enter city/i);
    const searchButton = screen.getByRole('button', { name: /search/i });

    await userEvent.type(input, 'Hollywood');
    fireEvent.click(searchButton);

    await waitFor(() => {
      expect(screen.getByRole('button', { name: /searching/i })).toBeDisabled();
    });

    // Resolve the search
    resolveSearch(mockSearchResponse);

    await waitFor(() => {
      expect(screen.getByRole('button', { name: /search/i })).not.toBeDisabled();
    });
  });

  it('displays error message when search fails', async () => {
    const errorResponse = {
      response: {
        data: {
          message: 'Failed to connect to API',
        },
      },
    };
    axios.post.mockRejectedValue(errorResponse);

    render(<HotelSearch />);

    await waitFor(() => {
      expect(screen.getByPlaceholderText(/select or enter city/i)).toBeInTheDocument();
    });

    const input = screen.getByPlaceholderText(/select or enter city/i);
    const searchButton = screen.getByRole('button', { name: /search/i });

    await userEvent.type(input, 'Hollywood');
    fireEvent.click(searchButton);

    await waitFor(() => {
      expect(screen.getByText('Failed to connect to API')).toBeInTheDocument();
    });
  });


  it('clears previous results when starting new search', async () => {
    axios.post.mockResolvedValueOnce(mockSearchResponse);

    render(<HotelSearch />);

    await waitFor(() => {
      expect(screen.getByPlaceholderText(/select or enter city/i)).toBeInTheDocument();
    });

    const input = screen.getByPlaceholderText(/select or enter city/i);
    const searchButton = screen.getByRole('button', { name: /search/i });

    // First search
    await userEvent.type(input, 'Hollywood');
    fireEvent.click(searchButton);

    await waitFor(() => {
      expect(screen.getByText('Luxury Beach Villa')).toBeInTheDocument();
    });

    // Second search - should clear results temporarily
    axios.post.mockResolvedValueOnce({ data: { hotels: [] } });
    await userEvent.clear(input);
    await userEvent.type(input, 'Miami');
    fireEvent.click(searchButton);

    await waitFor(() => {
      expect(screen.queryByText('Luxury Beach Villa')).not.toBeInTheDocument();
    });
  });

  it('clears error when starting new search', async () => {
    // First search fails
    axios.post.mockRejectedValueOnce({
      response: { data: { message: 'API Error' } },
    });

    render(<HotelSearch />);

    await waitFor(() => {
      expect(screen.getByPlaceholderText(/select or enter city/i)).toBeInTheDocument();
    });

    const input = screen.getByPlaceholderText(/select or enter city/i);
    const searchButton = screen.getByRole('button', { name: /search/i });

    await userEvent.type(input, 'Hollywood');
    fireEvent.click(searchButton);

    await waitFor(() => {
      expect(screen.getByText('API Error')).toBeInTheDocument();
    });

    // Second search succeeds
    axios.post.mockResolvedValueOnce(mockSearchResponse);
    await userEvent.clear(input);
    await userEvent.type(input, 'Miami');
    fireEvent.click(searchButton);

    await waitFor(() => {
      expect(screen.queryByText('API Error')).not.toBeInTheDocument();
    });
  });

  it('displays multiple hotel results', async () => {
    const multipleHotelsResponse = {
      data: {
        hotels: [
          {
            id: 1,
            name: 'Hotel One',
            price: '$100',
          },
          {
            id: 2,
            name: 'Hotel Two',
            price: '$200',
          },
          {
            id: 3,
            name: 'Hotel Three',
            price: '$300',
          },
        ],
      },
    };
    axios.post.mockResolvedValue(multipleHotelsResponse);

    render(<HotelSearch />);

    await waitFor(() => {
      expect(screen.getByPlaceholderText(/select or enter city/i)).toBeInTheDocument();
    });

    const input = screen.getByPlaceholderText(/select or enter city/i);
    const searchButton = screen.getByRole('button', { name: /search/i });

    await userEvent.type(input, 'Hollywood');
    fireEvent.click(searchButton);

    await waitFor(() => {
      expect(screen.getByText('Hotel One')).toBeInTheDocument();
      expect(screen.getByText('Hotel Two')).toBeInTheDocument();
      expect(screen.getByText('Hotel Three')).toBeInTheDocument();
      expect(screen.getByText(/found 3 hotels/i)).toBeInTheDocument();
    });
  });
});

