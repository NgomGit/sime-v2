// features/auth/domain/entities/login_entity.dart

class LoginEntity {
  final String username;
  final String password;
  final bool isLoading;
  final String? errorMessage;
  final bool isSuccess;
  final String? token; // Pour stocker le JWT retourné

  const LoginEntity({
    this.username = '',
    this.password = '',
    this.isLoading = false,
    this.errorMessage,
    this.isSuccess = false,
    this.token,
  });

  LoginEntity copyWith({
    String? username,
    String? password,
    bool? isLoading,
    String? errorMessage,
    bool? isSuccess,
    String? token,
  }) {
    return LoginEntity(
      username: username ?? this.username,
      password: password ?? this.password,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage, // Reset si non spécifié
      isSuccess: isSuccess ?? this.isSuccess,
      token: token ?? this.token,
    );
  }
}