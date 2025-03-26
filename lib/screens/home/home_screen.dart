import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../services/tmdb_service.dart';
import '../../models/tmdb/movie_model.dart';
import '../watched/watched_movies_screen.dart';
import '../../services/taste_profile_service.dart';
import '../movie_details/movie_details_screen.dart';
import '../wizard/movie_card_widget.dart';  // Add this import
import '../../services/auth_service.dart';
import '../login_screen.dart';
import 'dart:math';  // Add this import

class HomeScreen extends StatefulWidget {
  final String userId;

  const HomeScreen({super.key, required this.userId});  // Remove _authService from here

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _tmdbService = TMDBService();
  final _tasteProfileService = TasteProfileService();
  final _authService = AuthService();  // Move it here
  final _movies = <Movie>[];
  bool _isLoading = true;
  Set<int> _watchedMovieIds = {};
  final _random = Random();  // Add this line

  @override
  void initState() {
    super.initState();
    _loadWatchedMoviesAndRecommendations(); // Add this line
  }

  Future<void> _loadWatchedMoviesAndRecommendations() async {
    setState(() => _isLoading = true);
    
    try {
      // First load watched movies to get their IDs
      final watchedMovies = await _tasteProfileService.getWatchedMovies(widget.userId);
      _watchedMovieIds = watchedMovies.map((m) => m.id).toSet();

      // Get recommended movies with random pages
      final List<Movie> allRecommendations = [];
      final totalPages = 20; // TMDB typically has 20 pages of popular movies
      final selectedPages = List.generate(3, (_) => _random.nextInt(totalPages) + 1);
      
      for (final page in selectedPages) {
        final recommendations = await _tmdbService.getPopularMovies(page);
        allRecommendations.addAll(recommendations);
      }
      
      // Shuffle recommendations before calculating scores
      allRecommendations.shuffle(_random);
      
      // Take only a subset of movies to calculate scores for better performance
      final moviesToProcess = allRecommendations
          .where((movie) => !_watchedMovieIds.contains(movie.id))
          .take(20) // Process only 20 movies at a time
          .toList();
      
      // Calculate match scores for selected movies
      final moviesWithScores = await Future.wait(
        moviesToProcess.map((movie) async {
          final details = await _tmdbService.getMovieDetails(movie.id);
          final score = await _tasteProfileService.calculateMatchScore(
            widget.userId,
            details,
          );
          return MapEntry(movie, score);
        })
      );

      // Sort movies by match score (highest first)
      moviesWithScores.sort((a, b) => b.value.compareTo(a.value));
      
      if (mounted) {
        setState(() {
          _movies.clear();
          _movies.addAll(moviesWithScores.map((entry) => entry.key));
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading recommendations: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C302E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF474A48),
        title: const Text(
          'Your Movie Recommendations',
          style: TextStyle(color: Color(0xFF9AE19D)),
        ),
        actions: [
          // Add Refresh button
          IconButton(
            icon: const Icon(Iconsax.refresh, color: Color(0xFF9AE19D)),
            onPressed: () {
              setState(() {
                _movies.clear();
                _isLoading = true;
              });
              _loadWatchedMoviesAndRecommendations();
            },
          ),
          // Add Watched Movies button
          IconButton(
            icon: const Icon(Iconsax.video_play, color: Color(0xFF9AE19D)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WatchedMoviesScreen(userId: widget.userId),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Iconsax.setting_2, color: Color(0xFF9AE19D)),
            onPressed: () {
              // TODO: Implement settings
            },
          ),
          IconButton(  // Add logout button
            icon: const Icon(Iconsax.logout, color: Color(0xFF9AE19D)),
            onPressed: () async {
              await _authService.logout();
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF9AE19D),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2/3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: _movies.length,
              itemBuilder: (context, index) {
                final movie = _movies[index];
                return MovieCard(
                  movie: movie,
                  isSelected: false,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MovieDetailsScreen(
                          movie: movie,
                          userId: widget.userId,
                          isFromWatchedList: false,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}