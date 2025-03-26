import 'dart:convert';
import 'dart:developer' as dev;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthService {
  static const String _userKey = 'users';
  static const String _currentUserKey = 'current_user';  // Add this line
  
  // Add this method to clear storage
  Future<void> clearStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    dev.log('Storage cleared');
  }

  Future<void> signUp(User user) async {
    final prefs = await SharedPreferences.getInstance();
    final users = await getUsers();
    
    dev.log('Attempting to sign up user: ${user.email}');
    dev.log('Current users in storage: ${users.map((u) => u.email).toList()}');
    
    // Check if user already exists
    if (users.any((u) => u.email.trim().toLowerCase() == user.email.trim().toLowerCase())) {
      dev.log('User already exists with email: ${user.email}');
      throw Exception('User already exists');
    }
    
    users.add(user);
    final jsonData = jsonEncode(users.map((u) => u.toJson()).toList());
    dev.log('Saving users data: $jsonData'); // Add this log
    await prefs.setString(_userKey, jsonData);
    dev.log('Successfully signed up user: ${user.email}');
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    // Only remove the current user session, not all data
    await prefs.remove(_currentUserKey);
  }

  Future<User> login(String email, String password) async {
    final users = await getUsers();
    
    dev.log('Attempting to login user: $email');
    dev.log('Available users: ${users.map((u) => u.email).toList()}');
    
    try {
      final user = users.firstWhere(
        (u) => u.email.trim().toLowerCase() == email.trim().toLowerCase() && 
               u.password == password,
        orElse: () => throw Exception('Invalid credentials'),
      );
      
      // Store current user session
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_currentUserKey, jsonEncode(user.toJson()));
      
      dev.log('Login successful for user: ${user.email}');
      return user;
    } catch (e) {
      dev.log('Login failed for user: $email. Error: $e');
      rethrow;
    }
  }

  Future<List<User>> getUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString(_userKey);
    
    if (usersJson == null) {
      dev.log('No users found in storage');
      return [];
    }
    
    final usersList = jsonDecode(usersJson) as List;
    final users = usersList.map((u) => User.fromJson(u)).toList();
    dev.log('Retrieved ${users.length} users from storage');
    return users;
  }
}