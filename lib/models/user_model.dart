class User {
  final String fullName;
  final String email;
  final String password;

  User({
    required this.fullName,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
    'fullName': fullName,
    'email': email,
    'password': password,
  };

  factory User.fromJson(Map<String, dynamic> json) => User(
    fullName: json['fullName'] as String,
    email: json['email'] as String,
    password: json['password'] as String,
  );
}