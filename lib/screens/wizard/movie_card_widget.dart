import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/tmdb/movie_model.dart';

class MovieCard extends StatelessWidget {
  final Movie movie;
  final bool isSelected;
  final VoidCallback onTap;

  const MovieCard({
    super.key,
    required this.movie,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF9AE19D) : const Color(0xFF537A5A),
            width: isSelected ? 3 : 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Stack(
            fit: StackFit.expand, // Add this to make stack fill the container
            children: [
              CachedNetworkImage(
                imageUrl: 'https://image.tmdb.org/t/p/w500${movie.posterPath}',
                fit: BoxFit.cover,
                width: double.infinity, // Add this
                height: double.infinity, // Add this
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
                    Icons.error,
                    color: Color(0xFF537A5A),
                  ),
                ),
              ),
              if (isSelected)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFF9AE19D),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Color(0xFF2C302E),
                      size: 20,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}