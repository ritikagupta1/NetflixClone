# Netflix Clone iOS App
An iOS application replicating Netflix's core functionality using modern development practices and MVVM architecture.

## Features
- Browse multiple categories:
  - Trending movies and TV shows
  - Popular movies
  - Upcoming releases
  - Top rated movies
- Search with real-time results
- Download movies for offline viewing
- Infinite scrolling with pagination
- Persistent data storage using CoreData
- URLSession network handling
- Background task management

## Technical Stack
- **UI Framework**: UIKit (Programmatic UI)
- **Architecture**: MVVM
- **Persistence**: CoreData
- **Networking**: URLSession
- **Concurrency**: DispatchGroup, GCD
- **API Integration**: TMDB API
- **Image Caching**: SDWebImage
- **Minimum iOS**: 13.0

## Core Components

### Networking Layer
- Custom URLSession configuration
- Request cancellation support
- Response caching
- Error handling
- Request retry logic

### Data Layer
- CoreData integration
- Efficient data persistence

### View Layer
- Custom UICollectionViewLayout
- Reusable components
- Dynamic cell sizing
- Smooth scrolling optimization

## Getting Started
1. Clone the repository
2. Install dependencies
3. Add TMDB API key in `Configurations.swift`
4. Build and run

## Requirements
- iOS 13.0+
- Xcode 13+
- TMDB API Key

## Performance Features
- SDWebImage for efficient image caching
- Pagination for smooth data loading

## Future Improvements
- Add unit tests

