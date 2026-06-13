import '../models/user_model.dart';

abstract class BaseAuthService {
  Future<UserModel?> login(String email, String password);
  Future<UserModel?> register(String name, String email, String password, String role);
  Future<void> logout();
  Future<UserModel?> getCurrentUser();
}
