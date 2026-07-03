// import '../../../../core/network/api_client.dart';
// import '../../../../core/network/api_constants.dart';
// import '../models/auth_models.dart';

// abstract interface class AuthRemoteDataSource {
//   Future<AuthSessionModel> login(String username, String password);
//   Future<String> register(String username, String email, String password);
//   Future<UserModel> getMe();
//   Future<UserModel> updateMe(Map<String, dynamic> body);
//   Future<String> changePassword(String oldPassword, String newPassword);
//   Future<String> forgotPassword(String email);
// }

// class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
//   const AuthRemoteDataSourceImpl(this._client);
//   final ApiClient _client;

//   @override
//   Future<AuthSessionModel> login(String username, String password) async {
//     final response = await _client.dio.post(
//       ApiConstants.login,
//       data: {'username': username, 'password': password},
//     );
//     return AuthSessionModel.fromJson(
//       response.data as Map<String, dynamic>,
//     );
//   }

//   @override
//   Future<String> register(
//     String username,
//     String email,
//     String password,
//   ) async {
//     final response = await _client.dio.post(
//       ApiConstants.register,
//       data: {
//         'username': username,
//         'email': email,
//         'password': password,
//         'role': ['ROLE_APPLICANT'],
//       },
//     );
//     return (response.data as Map<String, dynamic>)['message'] as String;
//   }

//   @override
//   Future<UserModel> getMe() async {
//     final response = await _client.dio.get(ApiConstants.me);
//     return UserModel.fromJson(response.data as Map<String, dynamic>);
//   }

//   @override
//   Future<UserModel> updateMe(Map<String, dynamic> body) async {
//     final response = await _client.dio.put(ApiConstants.me, data: body);
//     return UserModel.fromJson(response.data as Map<String, dynamic>);
//   }

//   @override
//   Future<String> changePassword(
//     String oldPassword,
//     String newPassword,
//   ) async {
//     final response = await _client.dio.put(
//       ApiConstants.changePassword,
//       data: {'oldPassword': oldPassword, 'newPassword': newPassword},
//     );
//     return (response.data as Map<String, dynamic>)['message'] as String;
//   }

//   @override
//   Future<String> forgotPassword(String email) async {
//     final response = await _client.dio.post(
//       ApiConstants.forgotPassword,
//       data: {'email': email},
//     );
//     return (response.data as Map<String, dynamic>)['message'] as String;
//   }
// }