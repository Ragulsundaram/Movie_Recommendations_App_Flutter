import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/tmdb/movie_model.dart';
import 'dart:math'; 

class TMDBService {
  static const String _baseUrl = 'https://api.themoviedb.org/3';
  static const String _bearerToken = 'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI0ZTA3MDZjZjllYzNlOWUyNmRjY2UzZTMzNGUyZDg2MSIsIm5iZiI6MTcwNDk2MzE5MS4yMjgsInN1YiI6IjY1OWZhYzc3M2NkMTJjMDEyN2YwNWJjZiIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.5vVD5biFWXJL3gTUvi29xVcttmHsnJTwyCO0suFqqtM';

  final _client = http.Client();
  final _headers = {
    'Authorization': 'Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI0ZTA3MDZjZjllYzNlOWUyNmRjY2UzZTMzNGUyZDg2MSIsIm5iZiI6MTcwNDk2MzE5MS4yMjgsInN1YiI6IjY1OWZhYzc3M2NkMTJjMDEyN2YwNWJjZiIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.5vVD5biFWXJL3gTUvi29xVcttmHsnJTwyCO0suFqqtM',
    'accept': 'application/json',
  };

  Future<List<Movie>> getPopularMovies(int page) async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/movie/popular?page=$page'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;
        return results.map((json) => Movie.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load popular movies: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error while loading popular movies: $e');
    }
  }

  Future<Map<String, dynamic>> getMovieDetails(int movieId) async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/movie/$movieId?append_to_response=credits'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load movie details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error while loading movie details: $e');
    }
  }

  Future<Map<String, dynamic>> getMovieKeywords(int movieId) async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/movie/$movieId/keywords'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load movie keywords: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error while loading movie keywords: $e');
    }
  }

  Future<List<Movie>> getRecommendedMovies() async {
    try {
      // Get movies from multiple pages for better variety
      final List<Movie> allMovies = [];
      final Random random = Random();
      final pages = [1, 2, 3]; // Get from first 3 pages
      
      for (final page in pages) {
        final response = await _client.get(
          Uri.parse('$_baseUrl/movie/popular?page=$page'),
          headers: _headers,
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final results = data['results'] as List;
          allMovies.addAll(results.map((json) => Movie.fromJson(json)).toList());
        }
      }

      // Shuffle the movies for randomness
      allMovies.shuffle(random);
      return allMovies;
    } catch (e) {
      throw Exception('Network error while loading recommended movies: $e');
    }
  }
}