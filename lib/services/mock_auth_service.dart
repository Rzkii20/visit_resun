import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'base_auth_service.dart';

class MockAuthService implements BaseAuthService {
  static const String _keyCurrentUser = 'current_user';
  static const String _keyAllUsers = 'all_users';

  // Seed default admin & user accounts
  Future<void> _seedUsersIfEmpty() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_keyAllUsers)) {
      final defaultUsers = [
        UserModel(
          uid: 'admin_uid_1',
          name: 'Admin Visit Resun',
          email: 'admin@visitresun.com',
          role: 'admin',
          photo: 'https://api.dicebear.com/7.x/adventurer/svg?seed=Admin',
        ),
        UserModel(
          uid: 'user_uid_1',
          name: 'Pengunjung Resun',
          email: 'user@visitresun.com',
          role: 'user',
          photo: 'https://api.dicebear.com/7.x/adventurer/svg?seed=User',
        ),
      ];
      final usersMap = defaultUsers.map((u) => u.toMap()).toList();
      await prefs.setString(_keyAllUsers, json.encode(usersMap));
    }
  }

  @override
  Future<UserModel?> login(String email, String password) async {
    await _seedUsersIfEmpty();
    final prefs = await SharedPreferences.getInstance();
    
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 600));

    final usersStr = prefs.getString(_keyAllUsers);
    if (usersStr != null) {
      final List<dynamic> usersList = json.decode(usersStr);
      for (var uMap in usersList) {
        final map = Map<String, dynamic>.from(uMap);
        if (map['email'] == email) {
          // Accept standard password, or at least 6 chars for testing
          final expectedPw = map['role'] == 'admin' ? 'admin123' : 'user123';
          if (password == expectedPw || password.length >= 6) {
            final user = UserModel.fromMap(map);
            await prefs.setString(_keyCurrentUser, json.encode(user.toMap()));
            return user;
          }
        }
      }
    }
    return null;
  }

  @override
  Future<UserModel?> register(String name, String email, String password, String role) async {
    await _seedUsersIfEmpty();
    final prefs = await SharedPreferences.getInstance();
    
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 600));

    final usersStr = prefs.getString(_keyAllUsers);
    List<dynamic> usersList = usersStr != null ? json.decode(usersStr) : [];
    
    // Check if email already exists
    for (var uMap in usersList) {
      final map = Map<String, dynamic>.from(uMap);
      if (map['email'] == email) {
        throw Exception('Email sudah terdaftar!');
      }
    }

    final newUser = UserModel(
      uid: 'user_uid_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
      role: 'user', // Enforce role as 'user' for safety
      photo: 'https://api.dicebear.com/7.x/adventurer/svg?seed=$name',
    );

    usersList.add(newUser.toMap());
    await prefs.setString(_keyAllUsers, json.encode(usersList));
    await prefs.setString(_keyCurrentUser, json.encode(newUser.toMap()));
    return newUser;
  }

  @override
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyCurrentUser);
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString(_keyCurrentUser);
    if (userStr != null) {
      return UserModel.fromMap(Map<String, dynamic>.from(json.decode(userStr)));
    }
    return null;
  }
}
