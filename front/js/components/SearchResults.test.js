import React from 'react';
import { render, screen } from '@testing-library/react';
import SearchResults from './SearchResults';

describe('SearchResults', () => {
  const mockHotels = [
    {
      id: 1,
      name: 'Luxury Beach Villa',
      location: 'Hollywood, Florida',
      price: '$450 per night',
      image: 'https://example.com/villa.jpg',
      rating: 4.8,
      description: 'Beautiful oceanfront villa with stunning views',
      bedrooms: 4,
      bathrooms: 3,
      guests: 8,
    },
    {
      id: 2,
      name: 'Downtown Apartment',
      location: 'Miami, Florida',
      price: '$200 per night',
      image: null,
      rating: 4.2,
      description: 'Cozy apartment in the heart of Miami',
      bedrooms: 2,
      bathrooms: 1,
      guests: 4,
    },
  ];

  it('renders "no results" message when results array is empty', () => {
    render(<SearchResults results={[]} />);
    expect(screen.getByText(/no hotels found/i)).toBeInTheDocument();
  });

  it('renders "no results" message when results is null', () => {
    render(<SearchResults results={null} />);
    expect(screen.getByText(/no hotels found/i)).toBeInTheDocument();
  });

  it('renders hotel count when results are present', () => {
    render(<SearchResults results={mockHotels} />);
    expect(screen.getByText(/found 2 hotels/i)).toBeInTheDocument();
  });

  it('renders singular hotel text when only one result', () => {
    render(<SearchResults results={[mockHotels[0]]} />);
    expect(screen.getByText(/found 1 hotel/i)).toBeInTheDocument();
  });

  it('renders all hotel cards', () => {
    render(<SearchResults results={mockHotels} />);
    expect(screen.getByText('Luxury Beach Villa')).toBeInTheDocument();
    expect(screen.getByText('Downtown Apartment')).toBeInTheDocument();
  });

  it('renders hotel details correctly', () => {
    render(<SearchResults results={mockHotels} />);

    // Check first hotel details
    expect(screen.getByText('Luxury Beach Villa')).toBeInTheDocument();
    expect(screen.getByText('📍 Hollywood, Florida')).toBeInTheDocument();
    expect(screen.getByText('$450 per night')).toBeInTheDocument();
    expect(screen.getByText('⭐ 4.8')).toBeInTheDocument();
    expect(screen.getByText(/beautiful oceanfront villa/i)).toBeInTheDocument();
  });

  it('renders amenities correctly', () => {
    render(<SearchResults results={mockHotels} />);

    expect(screen.getByText('🛏️ 4 bed')).toBeInTheDocument();
    expect(screen.getByText('🚿 3 bath')).toBeInTheDocument();
    expect(screen.getByText('👥 8 guests')).toBeInTheDocument();
  });

  it('renders hotel image when available', () => {
    render(<SearchResults results={mockHotels} />);

    const images = screen.getAllByRole('img');
    const villaImage = images.find((img) => img.alt === 'Luxury Beach Villa');
    expect(villaImage).toHaveAttribute('src', 'https://example.com/villa.jpg');
  });

  it('does not render image div when image is null', () => {
    render(<SearchResults results={[mockHotels[1]]} />);

    const images = screen.queryAllByRole('img');
    expect(images.length).toBe(0);
  });

  it('does not render location when not provided', () => {
    const hotelWithoutLocation = {
      ...mockHotels[0],
      location: null,
    };
    render(<SearchResults results={[hotelWithoutLocation]} />);

    expect(screen.queryByText(/📍/)).not.toBeInTheDocument();
  });

  it('does not render rating when not provided', () => {
    const hotelWithoutRating = {
      ...mockHotels[0],
      rating: null,
    };
    render(<SearchResults results={[hotelWithoutRating]} />);

    expect(screen.queryByText(/⭐/)).not.toBeInTheDocument();
  });

  it('does not render description when not provided', () => {
    const hotelWithoutDescription = {
      ...mockHotels[0],
      description: null,
    };
    render(<SearchResults results={[hotelWithoutDescription]} />);

    expect(screen.queryByText(/beautiful oceanfront villa/i)).not.toBeInTheDocument();
  });

  it('renders hotel cards with proper CSS classes', () => {
    const { container } = render(<SearchResults results={mockHotels} />);

    const hotelCards = container.querySelectorAll('.hotel-card');
    expect(hotelCards.length).toBe(2);

    const hotelContent = container.querySelectorAll('.hotel-content');
    expect(hotelContent.length).toBe(2);
  });

  it('handles hotels with missing amenities', () => {
    const hotelWithoutAmenities = {
      id: 3,
      name: 'Simple Room',
      price: '$100',
      bedrooms: null,
      bathrooms: null,
      guests: null,
    };
    render(<SearchResults results={[hotelWithoutAmenities]} />);

    expect(screen.queryByText(/🛏️/)).not.toBeInTheDocument();
    expect(screen.queryByText(/🚿/)).not.toBeInTheDocument();
    expect(screen.queryByText(/👥/)).not.toBeInTheDocument();
  });
});

