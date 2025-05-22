import 'package:flutter/material.dart';
import '../../data/models/user_model.dart';
import '../../data/services/mock_data_service.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoading = false;
  User? _currentUser;
  String? _error;

  bool get isLoading => _isLoading;
  User? get currentUser => _currentUser;
  String? get error => _error;
  bool get isLoggedIn => _currentUser != null;

  AuthProvider() {
    // 模拟自动登录，通常会从本地存储中检查登录状态
    _currentUser = MockDataService.getUsers().first;
  }

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 模拟登录延迟
      await Future.delayed(const Duration(seconds: 1));

      // 在真实应用中，这里应该调用Firebase Auth或其他身份验证服务
      // 但在这个模拟版本中，我们只检查用户名和密码是否不为空
      if (username.isNotEmpty && password.isNotEmpty) {
        _currentUser = MockDataService.getUsers().first;
        _error = null;
        notifyListeners();
        return true;
      } else {
        _error = '请输入用户名和密码';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(String username, String password, String name) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 模拟注册延迟
      await Future.delayed(const Duration(seconds: 1));

      // 在真实应用中，这里应该调用Firebase Auth或其他身份验证服务
      // 但在这个模拟版本中，我们只检查字段是否不为空
      if (username.isNotEmpty && password.isNotEmpty && name.isNotEmpty) {
        // 创建一个新用户
        _currentUser = User(
          id: 'user1',
          name: name,
          avatar: null,
          isOnline: true,
        );
        _error = null;
        notifyListeners();
        return true;
      } else {
        _error = '请填写所有字段';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 模拟注销延迟
      await Future.delayed(const Duration(seconds: 1));

      _currentUser = null;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();

    try {
      // 模拟更新延迟
      await Future.delayed(const Duration(seconds: 1));

      if (_currentUser != null) {
        // 更新用户数据
        _currentUser = User(
          id: _currentUser!.id,
          name: data['name'] ?? _currentUser!.name,
          avatar: data['avatar'] ?? _currentUser!.avatar,
          isOnline: _currentUser!.isOnline,
          lastSeen: _currentUser!.lastSeen,
        );
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
