# Movie Recommendation App

A Flutter application that creates personalized movie recommendations based on user preferences and taste profiles.

## Features

- User Authentication
- Movie Selection Wizard
- Taste Profile Generation
- Personalized Movie Recommendations
- Watched Movies Tracking

## App Structure

### Core Components

1. **Authentication System**
   - Login and Signup functionality
   - User data persistence using SharedPreferences

2. **Movie Selection Wizard**
   - Displays popular movies from TMDB
   - Allows users to select 10 favorite movies
   - Infinite scroll implementation
   - Visual feedback for selected movies

3. **Taste Profile System**
   - Analyzes user's movie selections
   - Generates weighted preferences for:
     - Genres (40% weight)
     - Actors (25% weight)
     - Directors (20% weight)
     - Keywords (15% weight)
   - Tracks additional preferences:
     - Era/Decade preferences
     - Language preferences
     - Average runtime preferences

4. **Recommendation Engine**
   - Filters out watched movies
   - Uses taste profile to rank movies
   - Provides personalized recommendations

### Directory Structure
lib/
├── models/
│   ├── taste_profile_model.dart
│   ├── user_model.dart
│   └── tmdb/
│       └── movie_model.dart
├── screens/
│   ├── home/
│   │   └── home_screen.dart
│   ├── watched/
│   │   └── watched_movies_screen.dart
│   ├── wizard/
│   │   ├── movie_selection_screen.dart
│   │   └── movie_card_widget.dart
│   ├── login_screen.dart
│   └── signup_screen.dart
└── services/
├── auth_service.dart
├── taste_profile_service.dart
└── tmdb_service.dart


## Technical Implementation

### Services

1. **TMDBService**
   - Handles API communication with TMDB
   - Fetches movie details, keywords, and credits
   - Manages popular movies pagination

2. **TasteProfileService**
   - Creates and manages user taste profiles
   - Implements weighted scoring system
   - Handles profile persistence using SharedPreferences

3. **AuthService**
   - Manages user authentication
   - Handles user data persistence

### Key Algorithms

1. **Taste Profile Generation**
   ```dart
   // Category weights
   static const double _genreWeight = 0.40;
   static const double _actorWeight = 0.25;
   static const double _directorWeight = 0.20;
   static const double _keywordWeight = 0.15;

   2. ovie Filtering
   - Excludes watched movies from recommendations
   - Uses Set data structure for efficient lookups
### UI Components
1. Color Scheme
backgroundColor: Color(0xFF2C302E)
appBarColor: Color(0xFF474A48)
accentColor: Color(0xFF9AE19D)
Custom Widgets

- MovieCard: Reusable movie display component
- Grid layouts for movie lists
- Loading indicators and error handling
## Dependencies
dependencies:
  flutter:
    sdk: flutter
  iconsax: ^0.0.8
  http: ^1.3.0
  cached_network_image: ^3.4.1
  google_fonts: ^6.1.0
  flutter_svg: ^2.0.9
  shared_preferences: ^2.2.2

  ## Future Improvements
1. Implement real-time recommendations
2. Add movie details page
3. Include user ratings
4. Add social features
5. Implement machine learning for better recommendations
## Contributing
Feel free to submit issues and enhancement requests.