import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthService {
  static const String baseUrl = 'http://localhost:3000'; // 替换为你的实际后端地址
  static const String tokenKey = 'auth_token';
  static const String userKey = 'current_user';

  // 单例模式
  static final AuthService _instance = AuthService._internal();

  factory AuthService() {
    return _instance;
  }

  AuthService._internal();

  // 登录
  Future<User> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final String token = data['token'];
      final User user = User.fromJson(data['user']);

      // 保存令牌和用户信息
      await _saveToken(token);
      await _saveUser(user);

      return user;
    } else {
      throw Exception('登录失败: ${response.body}');
    }
  }

  // 注册
  Future<User> register(String username, String password, String name) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
        'name': name,
      }),
    );

    if (response.statusCode == 201) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final String token = data['token'];
      final User user = User.fromJson(data['user']);

      // 保存令牌和用户信息
      await _saveToken(token);
      await _saveUser(user);

      return user;
    } else {
      throw Exception('注册失败: ${response.body}');
    }
  }

  // 注销
  Future<void> logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(tokenKey);
    await prefs.remove(userKey);
  }

  // 检查用户是否已登录
  Future<bool> isLoggedIn() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString(tokenKey);
    return token != null;
  }

  // 获取当前用户
  Future<User?> getCurrentUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userJson = prefs.getString(userKey);

    if (userJson != null) {
      return User.fromJson(jsonDecode(userJson));
    }

    return null;
  }

  // 获取认证令牌
  Future<String?> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }

  // 更新用户信息
  Future<User> updateProfile(String userId, Map<String, dynamic> data) async {
    final String? token = await getToken();

    final response = await http.put(
      Uri.parse('$baseUrl/users/$userId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      final User updatedUser = User.fromJson(jsonDecode(response.body));
      await _saveUser(updatedUser);
      return updatedUser;
    } else {
      throw Exception('更新用户信息失败: ${response.body}');
    }
  }

  // 保存令牌到本地存储
  Future<void> _saveToken(String token) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, token);
  }

  // 保存用户信息到本地存储
  Future<void> _saveUser(User user) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(userKey, jsonEncode(user.toJson()));
  }
}
