// import 'package:dartz/dartz.dart';

// import '../../../../core/error/failures.dart';
// import '../../../../core/network/network_info.dart';
// import '../../../../core/storage/hive_cache.dart';
// import '../../../../core/storage/secure_storage.dart';
// import '../../../../core/utils/offline_first_mixin.dart';


// class AuthRepositoryImpl with OfflineFirstMixin implements AuthRepository {
//   const AuthRepositoryImpl({
//     required this.remote,
//     required this.networkInfo,
//     required this.cache,
//     required this.secureStorage,
//   });

//   final AuthRemoteDataSource remote;
//   final SecureStorage secureStorage;

//   @override
//   final NetworkInfo networkInfo;

//   @override
//   final HiveCache cache;

//   @override
//   Future<Either<Failure, AuthSessionEntity>> login({
//     required String username,
//     required String password,
//   }) async =>
//       remoteOnly(() async {
//         final session = await remote.login(username, password);
//         await secureStorage.saveAccessToken(session.accessToken);
//         await secureStorage.saveCredentials(username, password);
//         return session;
//       });

//   @override
//   Future<Either<Failure, String>> register({
//     required String username,
//     required String email,
//     required String password,
//   }) =>
//       remoteOnly(() => remote.register(username, email, password));

//   @override
//   Future<Either<Failure, UserEntity>> getMe() => offlineFirst(
//         cacheKey: HiveCacheKeys.applicantMe,
//         remoteCall: () => remote.getMe(),
//         fromCache: (json) =>
//             UserModel.fromJson(json as Map<String, dynamic>),
//         toJson: (user) => (user as UserModel).toJson(),
//       );

//   @override
//   Future<Either<Failure, UserEntity>> updateMe({
//     String? firstName,
//     String? lastName,
//     String? phone,
//     String? email,
//   }) async {
//     final result = await remoteOnly<UserEntity>(
//       () => remote.updateMe({
//         if (firstName != null) 'firstName': firstName,
//         if (lastName != null) 'lastName': lastName,
//         if (phone != null) 'phone': phone,
//         if (email != null) 'email': email,
//       }),
//     );
//     // Invalider le cache profil après mise à jour
//     if (result.isRight()) await invalidate(HiveCacheKeys.applicantMe);
//     return result;
//   }

//   @override
//   Future<Either<Failure, String>> changePassword({
//     required String oldPassword,
//     required String newPassword,
//   }) =>
//       remoteOnly(() => remote.changePassword(oldPassword, newPassword));

//   @override
//   Future<Either<Failure, String>> forgotPassword({required String email}) =>
//       remoteOnly(() => remote.forgotPassword(email));

//   @override
//   Future<void> logout() async {
//     await secureStorage.clearAll();
//     await cache.clearAll();
//   }

//   @override
//   Future<bool> isAuthenticated() async {
//     final token = await secureStorage.getAccessToken();
//     return token != null;
//   }
// }