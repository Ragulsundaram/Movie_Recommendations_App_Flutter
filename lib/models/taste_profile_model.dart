class TasteProfile {
  final String userId;
  final List<int> favoriteGenres;
  final List<String> favoriteActors;
  final List<String> favoriteDirectors;
  final List<int> favoriteMovies;
  final double averageRating;
  final Map<int, double> genreWeights;
  final DateTime createdAt;

  TasteProfile({
    required this.userId,
    required this.favoriteGenres,
    required this.favoriteActors,
    required this.favoriteDirectors,
    required this.favoriteMovies,
    required this.averageRating,
    required this.genreWeights,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'favoriteGenres': favoriteGenres,
      'favoriteActors': favoriteActors,
      'favoriteDirectors': favoriteDirectors,
      'favoriteMovies': favoriteMovies,
      'averageRating': averageRating,
      'genreWeights': genreWeights.map((key, value) => MapEntry(key.toString(), value)),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory TasteProfile.fromJson(Map<String, dynamic> json) {
    return TasteProfile(
      userId: json['userId'],
      favoriteGenres: List<int>.from(json['favoriteGenres']),
      favoriteActors: List<String>.from(json['favoriteActors']),
      favoriteDirectors: List<String>.from(json['favoriteDirectors']),
      favoriteMovies: List<int>.from(json['favoriteMovies']),
      averageRating: json['averageRating'].toDouble(),
      genreWeights: (json['genreWeights'] as Map<String, dynamic>)
          .map((key, value) => MapEntry(int.parse(key), value.toDouble())),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}