// features/auth/data/models/login_dto.dart
class LoginModel {
  static Map<String, dynamic> toJson(String username, String password) {
    return {
      "username": username,
      "password": password,
    };
  }
}