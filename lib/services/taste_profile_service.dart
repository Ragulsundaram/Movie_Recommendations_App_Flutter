import 'dart:convert';
import 'dart:developer' as dev;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/taste_profile_model.dart';
import '../models/tmdb/movie_model.dart';
import 'tmdb_service.dart';

class TasteProfileService {
  static const String _key = 'taste_profiles';
  final _tmdbService = TMDBService();
  late SharedPreferences _prefs;
  
  // Category weights for final scoring
  static const double _genreWeight = 0.40;
  static const double _actorWeight = 0.25;
  static const double _directorWeight = 0.20;
  static const double _keywordWeight = 0.15;

  TasteProfileService() {
    initialize();
  }

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> createProfile(String userId, List<Movie> selectedMovies) async {
    try {
      await initialize();
      final List<Map<String, dynamic>> movieDetails = [];
      
      // Fetch detailed information including keywords
      for (var movie in selectedMovies) {
        try {
          final details = await _tmdbService.getMovieDetails(movie.id);
          final keywords = await _tmdbService.getMovieKeywords(movie.id);
          if (details != null) {
            details['keywords'] = keywords;
            movieDetails.add(details);
          }
        } catch (e) {
          dev.log('Error fetching movie details: $e', name: 'TasteProfileService');
        }
      }

      // Calculate weighted scores for each category
      final scores = _calculateCategoryScores(movieDetails);
      
      // Create the taste profile without the era parameter
      final profile = TasteProfile(
        userId: userId,
        favoriteGenres: scores.genres.keys.toList(),
        favoriteActors: scores.actors,
        favoriteDirectors: scores.directors,
        favoriteMovies: selectedMovies.map((m) => m.id).toList(),
        averageRating: _calculateAverageRating(movieDetails),
        genreWeights: scores.genres,
        // Remove these two lines that are causing the error
        // era: Map<String, double>.from(scores.era),
        // language: Map<String, double>.from(scores.language),
        //runtime: scores.runtime,
        //keywords: Map<String, double>.from(scores.keywords),
        createdAt: DateTime.now(),
      );

      // Add logging
      dev.log('Created taste profile:', name: 'TasteProfileService');
      dev.log('User ID: $userId', name: 'TasteProfileService');
      dev.log('Favorite Genres: ${profile.favoriteGenres}', name: 'TasteProfileService');
      dev.log('Favorite Actors: ${profile.favoriteActors}', name: 'TasteProfileService');
      dev.log('Favorite Directors: ${profile.favoriteDirectors}', name: 'TasteProfileService');
      dev.log('Average Rating: ${profile.averageRating}', name: 'TasteProfileService');
      dev.log('Genre Weights: ${profile.genreWeights}', name: 'TasteProfileService');

      // Save profile
      final profiles = await _getProfiles();
      profiles[userId] = profile.toJson();
      await _prefs.setString(_key, json.encode(profiles));
    } catch (e) {
      dev.log('Error creating taste profile: $e', name: 'TasteProfileService');
      throw Exception('Failed to create taste profile: $e');
    }
  }

  ProfileScores _calculateCategoryScores(List<Map<String, dynamic>> movieDetails) {
    final genreWeights = <int, double>{};
    final actorScores = <String, double>{};
    final directorScores = <String, double>{};
    final keywordWeights = <String, double>{};
    final eraScores = <String, double>{};
    final languageScores = <String, double>{};
    double totalRuntime = 0;
  
    for (var movie in movieDetails) {
      final movieWeight = 1.0; // Can be modified based on user rating
  
      // Process genres
      _processGenres(movie, movieWeight, genreWeights);
  
      // Process cast
      _processCast(movie, movieWeight, actorScores);
  
      // Process crew
      _processCrew(movie, movieWeight, directorScores);
  
      // Process keywords
      _processKeywords(movie, movieWeight, keywordWeights);
  
      // Process era and language
      _processMetadata(movie, movieWeight, eraScores, languageScores);
  
      totalRuntime += (movie['runtime'] as num?) ?? 0;
    }
  
    return ProfileScores(
      genres: _normalizeScores(genreWeights),
      actors: _getTopItems(actorScores, 10),
      directors: _getTopItems(directorScores, 5),
      keywords: _normalizeScores(keywordWeights),
      era: _normalizeScores(eraScores),
      language: _normalizeScores(languageScores),
      runtime: totalRuntime / movieDetails.length,
    );
  }

  void _processGenres(Map<String, dynamic> movie, double weight, Map<int, double> genreWeights) {
    final genres = (movie['genres'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    for (var genre in genres) {
      final genreId = genre['id'] as int;
      genreWeights[genreId] = (genreWeights[genreId] ?? 0.0) + weight;
    }
  }

  void _processCast(Map<String, dynamic> movie, double weight, Map<String, double> actorScores) {
    final credits = movie['credits'] as Map<String, dynamic>?;
    if (credits == null) return;
    
    final cast = (credits['cast'] as List?)?.take(5).toList() ?? [];
    for (var actor in cast) {
      final name = actor['name'] as String?;
      if (name != null) {
        actorScores[name] = (actorScores[name] ?? 0.0) + weight;
      }
    }
  }

  void _processCrew(Map<String, dynamic> movie, double weight, Map<String, double> directorScores) {
    final credits = movie['credits'] as Map<String, dynamic>?;
    if (credits == null) return;

    final crew = credits['crew'] as List?;
    if (crew == null) return;

    for (var member in crew) {
      if (member['job'] == 'Director' && member['name'] != null) {
        final name = member['name'] as String;
        directorScores[name] = (directorScores[name] ?? 0.0) + weight;
      }
    }
  }

  void _processKeywords(Map<String, dynamic> movie, double weight, Map<String, double> keywordWeights) {
    final keywords = movie['keywords'] as Map<String, dynamic>?;
    if (keywords == null) return;

    final keywordList = (keywords['keywords'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    for (var keyword in keywordList) {
      final name = keyword['name'] as String?;
      if (name != null) {
        keywordWeights[name] = (keywordWeights[name] ?? 0.0) + weight;
      }
    }
  }

  void _processMetadata(
    Map<String, dynamic> movie,
    double weight,
    Map<String, double> eraScores,
    Map<String, double> languageScores,
  ) {
    final releaseDate = movie['release_date'] as String?;
    if (releaseDate != null && releaseDate.length >= 4) {
      final decade = '${releaseDate.substring(0, 3)}0s';
      eraScores[decade] = (eraScores[decade] ?? 0.0) + weight;
    }

    final language = movie['original_language'] as String?;
    if (language != null) {
      languageScores[language] = (languageScores[language] ?? 0.0) + weight;
    }
  }

  Map<K, double> _normalizeScores<K>(Map<K, double> scores) {
    final total = scores.values.fold(0.0, (sum, value) => sum + value);
    if (total == 0.0) return scores;
    
    return scores.map((key, value) => MapEntry(key, value / total));
  }

  List<String> _getTopItems(Map<String, double> scores, int limit) {
    final sortedEntries = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sortedEntries.take(limit).map((e) => e.key).toList();
  }

  double _calculateAverageRating(List<Map<String, dynamic>> movieDetails) {
    if (movieDetails.isEmpty) return 0.0;
    
    final totalRating = movieDetails.fold(0.0, (sum, movie) {
      return sum + ((movie['vote_average'] as num?)?.toDouble() ?? 0.0);
    });
    
    return totalRating / movieDetails.length;
  }

  Future<Map<String, dynamic>> _getProfiles() async {
    final json = _prefs.getString(_key);
    if (json == null) return {};
    return Map<String, dynamic>.from(jsonDecode(json));
  }

  Future<bool> hasProfile(String userId) async {
    try {
      await initialize();
      final profiles = await _getProfiles();
      return profiles.containsKey(userId);
    } catch (e) {
      dev.log('Error checking profile existence: $e', name: 'TasteProfileService');
      return false;
    }
  }

  Future<List<Movie>> getWatchedMovies(String userId) async {
      try {
        await initialize();
        final profiles = await _getProfiles();
        final profile = profiles[userId];
        if (profile == null) return [];
  
        final tasteProfile = TasteProfile.fromJson(profile);
        final movies = <Movie>[];
        
        for (var movieId in tasteProfile.favoriteMovies) {
          try {
            final details = await _tmdbService.getMovieDetails(movieId);
            if (details != null) {
              movies.add(Movie.fromJson(details));
            }
          } catch (e) {
            dev.log('Error fetching movie details: $e', name: 'TasteProfileService');
          }
        }
        
        return movies;
      } catch (e) {
        dev.log('Error getting watched movies: $e', name: 'TasteProfileService');
        return [];
      }
    }

  Future<double> calculateMatchScore(String userId, Map<String, dynamic> movieDetails) async {
    try {
      await initialize();
      final profiles = await _getProfiles();
      final profile = profiles[userId];
      if (profile == null) return 0.0;

      final tasteProfile = TasteProfile.fromJson(profile);
      double score = 0.0;

      // Genre matching (40% weight)
      final movieGenres = (movieDetails['genres'] as List?)?.map((g) => g['id'] as int).toList() ?? [];
      for (var genreId in movieGenres) {
        score += (tasteProfile.genreWeights[genreId] ?? 0.0) * _genreWeight;
      }

      // Cast matching (25% weight)
      final cast = (movieDetails['credits']?['cast'] as List?)?.map((c) => c['name'] as String).toList() ?? [];
      final matchingActors = cast.where((actor) => tasteProfile.favoriteActors.contains(actor)).length;
      if (cast.isNotEmpty) {
        score += (matchingActors / cast.length) * _actorWeight;
      }

      // Director matching (20% weight)
      final directors = (movieDetails['credits']?['crew'] as List?)
          ?.where((c) => c['job'] == 'Director')
          .map((d) => d['name'] as String)
          .toList() ?? [];
      final matchingDirectors = directors.where((director) => 
          tasteProfile.favoriteDirectors.contains(director)).length;
      if (directors.isNotEmpty) {
        score += (matchingDirectors / directors.length) * _directorWeight;
      }

      return score * 100; // Convert to percentage
    } catch (e) {
      return 0.0;
    }
  }
}

// Move this class outside of TasteProfileService
class ProfileScores {
  final Map<int, double> genres;
  final List<String> actors;
  final List<String> directors;
  final Map<String, double> keywords;
  final Map<String, double> era;
  final Map<String, double> language;
  final double runtime;

  ProfileScores({
    required this.genres,
    required this.actors,
    required this.directors,
    required this.keywords,
    required this.era,
    required this.language,
    required this.runtime,
  });
}