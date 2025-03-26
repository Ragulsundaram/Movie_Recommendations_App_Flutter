import 'package:flutter/material.dart';
import '../../models/tmdb/movie_model.dart';
import '../../services/taste_profile_service.dart';
import '../wizard/movie_card_widget.dart';
import '../movie_details/movie_details_screen.dart';  // Add this import if missing

class WatchedMoviesScreen extends StatefulWidget {
  final String userId;

  const WatchedMoviesScreen({super.key, required this.userId});

  @override
  State<WatchedMoviesScreen> createState() => _WatchedMoviesScreenState();
}

class _WatchedMoviesScreenState extends State<WatchedMoviesScreen> {
  final _tasteProfileService = TasteProfileService();
  List<Movie> _watchedMovies = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWatchedMovies();
  }

  Future<void> _loadWatchedMovies() async {
    try {
      final movies = await _tasteProfileService.getWatchedMovies(widget.userId);
      setState(() {
        _watchedMovies = movies;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading watched movies: $e')),
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
          'Watched Movies',
          style: TextStyle(color: Color(0xFF9AE19D)),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF9AE19D),
              ),
            )
          : _watchedMovies.isEmpty
              ? const Center(
                  child: Text(
                    'No watched movies yet',
                    style: TextStyle(
                      color: Color(0xFF9AE19D),
                      fontSize: 18,
                    ),
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
                  itemCount: _watchedMovies.length,
                  itemBuilder: (context, index) {
                    final movie = _watchedMovies[index];
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
                              isFromWatchedList: true,
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