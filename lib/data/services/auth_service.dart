import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthService {
  static const String baseUrl =
      'http://localhost:3000'; // Replace with your actual backend address

  AuthService._internal();
  static final AuthService _instance = AuthService._internal();
  // Singleton pattern
  factory AuthService() => _instance;

  String? _token;
  User? _currentUser;

  // Login
  Future<User?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _token = data['token'];
        _currentUser = User.fromJson(data['user']);

        // Save token and user info
        await _saveToken(_token!);
        await _saveUser(_currentUser!);

        return _currentUser;
      } else {
        throw Exception('Login failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  // Register
  Future<User?> register(String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'email': email, 'password': password}),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        _token = data['token'];
        _currentUser = User.fromJson(data['user']);

        // Save token and user info
        await _saveToken(_token!);
        await _saveUser(_currentUser!);

        return _currentUser;
      } else {
        throw Exception('Registration failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  // Logout
  Future<void> logout() async {
    _token = null;
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('current_user');
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    if (_token != null) return true;

    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');

    return _token != null;
  }

  // Get current user
  Future<User?> getCurrentUser() async {
    if (_currentUser != null) return _currentUser;

    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('current_user');

    if (userJson != null) {
      _currentUser = User.fromJson(jsonDecode(userJson));
    }

    return _currentUser;
  }

  // Get auth token
  Future<String?> getToken() async {
    if (_token != null) return _token;

    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');

    return _token;
  }

  // Update user info
  Future<User?> updateUser(Map<String, dynamic> updates) async {
    if (_token == null) return null;

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/auth/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode(updates),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _currentUser = User.fromJson(data);
        await _saveUser(_currentUser!);
        return _currentUser;
      } else {
        throw Exception('User update failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('User update failed: $e');
    }
  }

  // Save token to local storage
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  // Save user info to local storage
  Future<void> _saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_user', jsonEncode(user.toJson()));
  }
}
