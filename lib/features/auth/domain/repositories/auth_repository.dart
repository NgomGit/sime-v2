// features/auth/domain/repositories/auth_repository.dart
import 'package:sime_v2/features/auth/data/models/auth_response_model.dart';
import 'package:sime_v2/features/auth/domain/entities/registration_entity.dart';


abstract class AuthRepository {
  Future<void> registerFullDemandeur(RegistrationEntity entity);
  Future<AuthResponseModel> login(String username, String password);
  // Future<Either<Failure, UserProfileEntity>> updateUserAccount(Map<String, dynamic> payload);

}