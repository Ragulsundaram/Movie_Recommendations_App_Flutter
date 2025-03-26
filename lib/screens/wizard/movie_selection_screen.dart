import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/tmdb/movie_model.dart';
import '../../services/tmdb_service.dart';
import '../../services/taste_profile_service.dart';  // Add this import
import '../home/home_screen.dart';  // Add this import
import 'movie_card_widget.dart';

class MovieSelectionScreen extends StatefulWidget {
  final String userId;

  const MovieSelectionScreen({super.key, required this.userId});

  @override
  State<MovieSelectionScreen> createState() => _MovieSelectionScreenState();
}

class _MovieSelectionScreenState extends State<MovieSelectionScreen> {
  final _tmdbService = TMDBService();
  final _tasteProfileService = TasteProfileService();  // Add this line
  final _selectedMovies = <Movie>{};
  final _movies = <Movie>[];
  bool _isLoading = false;
  int _currentPage = 1;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadMovies();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 500) {
      _loadMovies();
    }
  }

  Future<void> _loadMovies() async {
    if (_isLoading) return;
    
    setState(() => _isLoading = true);
    
    try {
      final newMovies = await _tmdbService.getPopularMovies(_currentPage);
      setState(() {
        _movies.addAll(newMovies);
        _currentPage++;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading movies: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C302E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF474A48),
        title: const Text(
          'Select Your Favorite Movies',
          style: TextStyle(color: Color(0xFF9AE19D)),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Pick 10 movies you love (${_selectedMovies.length}/10)',
              style: const TextStyle(
                color: Color(0xFF9AE19D),
                fontSize: 18,
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2/3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: _movies.length + (_isLoading ? 2 : 0),
              itemBuilder: (context, index) {
                if (index >= _movies.length) {
                  return Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C302E),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF537A5A)),
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF9AE19D),
                      ),
                    ),
                  );
                }

                final movie = _movies[index];
                final isSelected = _selectedMovies.contains(movie);

                return MovieCard(
                  movie: movie,
                  isSelected: isSelected,
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedMovies.remove(movie);
                      } else if (_selectedMovies.length < 10) {
                        _selectedMovies.add(movie);
                      }
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: _selectedMovies.length == 10
          ? FloatingActionButton.extended(
              onPressed: () async {
                setState(() => _isLoading = true);
                try {
                  await _tasteProfileService.createProfile(
                    widget.userId,
                    _selectedMovies.toList(),
                  );
                  if (mounted) {
                    // Show success message
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Profile created successfully!'),
                        backgroundColor: Color(0xFF537A5A),
                      ),
                    );
                    // Navigate to home screen
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomeScreen(userId: widget.userId),
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error creating profile: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } finally {
                  if (mounted) {
                    setState(() => _isLoading = false);
                  }
                }
              },
              backgroundColor: const Color(0xFF537A5A),
              label: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Color(0xFF9AE19D),
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Continue',
                      style: TextStyle(color: Color(0xFF9AE19D)),
                    ),
            )
          : null,
    );
  }
}