import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:iconsax/iconsax.dart';  // Add this import
import '../../models/tmdb/movie_model.dart';
import '../../services/tmdb_service.dart';
import '../../services/taste_profile_service.dart';

class MovieDetailsScreen extends StatefulWidget {
  final Movie movie;
  final String userId;
  final bool isFromWatchedList;

  const MovieDetailsScreen({
    super.key,
    required this.movie,
    required this.userId,
    this.isFromWatchedList = false,
  });

  @override
  State<MovieDetailsScreen> createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends State<MovieDetailsScreen> {
  final _tmdbService = TMDBService();
  final _tasteProfileService = TasteProfileService();
  Map<String, dynamic>? _movieDetails;
  bool _isLoading = true;
  double _matchScore = 0.0;

  @override
  void initState() {
    super.initState();
    _loadMovieDetails();
  }

  Future<void> _loadMovieDetails() async {
    try {
      final details = await _tmdbService.getMovieDetails(widget.movie.id);
      final matchScore = await _tasteProfileService.calculateMatchScore(
        widget.userId, 
        details
      );
      
      setState(() {
        _movieDetails = details;
        _matchScore = matchScore;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading movie details: $e')),
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
          'Movie Details',
          style: TextStyle(color: Color(0xFF9AE19D)),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF9AE19D)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF9AE19D)))
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      // Backdrop image
                      AspectRatio(
                        aspectRatio: 16/10,
                        child: CachedNetworkImage(
                          imageUrl: 'https://image.tmdb.org/t/p/w1280${widget.movie.backdropPath}',
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(color: Color(0xFF9AE19D)),
                          ),
                          errorWidget: (context, url, error) => const Center(
                            child: Icon(Icons.error, color: Color(0xFF9AE19D)),
                          ),
                        ),
                      ),
                      // Match score overlay
                      Positioned(
                        top: 16,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.44),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFF9AE19D)),
                          ),
                          child: Text(
                            '${_matchScore.toInt()}% Match',
                            style: const TextStyle(
                              color: Color(0xFF9AE19D),
                              fontSize: 12,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                      // Gradient overlay for text readability
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        top: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              stops: const [0.2, 0.5, 0.7, 0.9], // Adjusted stops to start gradient earlier
                              colors: [
                                Colors.transparent,
                                const Color(0xFF2C302E).withOpacity(0.5),
                                const Color(0xFF2C302E).withOpacity(0.8),
                                const Color(0xFF2C302E),
                              ],
                            ),
                          ),
                          padding: const EdgeInsets.only(
                            left: 16.0,
                            right: 16.0,
                            bottom: 16.0,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                widget.movie.title,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Color(0xFF9AE19D),
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _buildInfoText(),
                                style: TextStyle(
                                  color: const Color(0xFF9AE19D).withOpacity(0.7),
                                  fontSize: 12,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Add synopsis section
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Synopsis',
                          style: TextStyle(
                            color: Color(0xFF9AE19D),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _movieDetails?['overview'] ?? 'No synopsis available.',
                          style: TextStyle(
                            color: const Color(0xFF9AE19D).withOpacity(0.9),
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Action Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildActionButton(
                              icon: Iconsax.like_1,
                              label: 'Like',
                              onTap: () {
                                // Like functionality will be added later
                              },
                            ),
                            _buildActionButton(
                              icon: Iconsax.dislike,
                              label: 'Hide',
                              onTap: () {
                                // Hide functionality will be added later
                              },
                            ),
                            _buildActionButton(
                              icon: Iconsax.send_2,
                              label: 'Share',
                              onTap: () {
                                // Share functionality will be added later
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Cast Section continues...
                        const Text(
                          'Cast',
                          style: TextStyle(
                            color: Color(0xFF9AE19D),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 180,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: (_movieDetails?['credits']?['cast'] as List?)?.length ?? 0,
                            itemBuilder: (context, index) {
                              final cast = (_movieDetails?['credits']?['cast'] as List)[index];
                              return Container(
                                width: 120,
                                margin: const EdgeInsets.only(right: 12),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    // Cast Image
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: CachedNetworkImage(
                                        imageUrl: 'https://image.tmdb.org/t/p/w185${cast['profile_path']}',
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) => Container(
                                          color: const Color(0xFF2C302E),
                                          child: const Center(
                                            child: CircularProgressIndicator(
                                              color: Color(0xFF9AE19D),
                                            ),
                                          ),
                                        ),
                                        errorWidget: (context, url, error) => Container(
                                          color: const Color(0xFF2C302E),
                                          child: const Icon(
                                            Icons.person,
                                            color: Color(0xFF537A5A),
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Gradient Overlay
                                    Positioned(
                                      bottom: 0,
                                      left: 0,
                                      right: 0,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.vertical(
                                            bottom: Radius.circular(8),
                                          ),
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Colors.transparent,
                                              const Color(0xFF2C302E).withOpacity(0.8),
                                              const Color(0xFF2C302E),
                                            ],
                                          ),
                                        ),
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              cast['name'] ?? '',
                                              style: const TextStyle(
                                                color: Color(0xFF9AE19D),
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              cast['character'] ?? '',
                                              style: TextStyle(
                                                color: const Color(0xFF9AE19D).withOpacity(0.7),
                                                fontSize: 10,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  // ... rest of the movie details ...
                ],
              ),
            ),
    );
  }

  String _buildInfoText() {
    if (_movieDetails == null) return '';

    final genres = (_movieDetails!['genres'] as List?)?.isNotEmpty == true
        ? (_movieDetails!['genres'] as List).first['name']
        : 'N/A';
    
    final rating = _movieDetails!['adult'] == true ? 'R' : 'PG-13';
    
    final releaseYear = (_movieDetails!['release_date'] as String?)?.split('-').first ?? 'N/A';
    
    final runtime = _movieDetails!['runtime'] as int?;
    final hours = runtime != null ? runtime ~/ 60 : 0;
    final minutes = runtime != null ? runtime % 60 : 0;
    final runtimeText = runtime != null ? '$hours hr ${minutes.toString().padLeft(2, '0')} min' : 'N/A';

    return '$genres • $rating • $releaseYear • $runtimeText';
  }
}

Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(50),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF2C302E),
              border: Border.all(
                color: const Color(0xFF537A5A),
                width: 2,
              ),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF9AE19D),
              size: 28,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF9AE19D),
            fontSize: 12,
          ),
        ),
      ],
    );
  }