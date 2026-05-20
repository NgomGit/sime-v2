import '../entities/user_profile_entity.dart';

abstract class UserProfileRepository {
  Future<UserProfileEntity> getUserProfile();
  Future<void> updateProfile(UserProfileEntity profile);
  Future<void> logout();
}