// features/auth/domain/usecases/register_demandeur_usecase.dart
import 'package:sime_v2/features/auth/domain/entities/registration_entity.dart';
import '../repositories/auth_repository.dart';


class RegisterDemandeurUseCase {
  final AuthRepository _repository;

  RegisterDemandeurUseCase(this._repository);

  Future<void> call(RegistrationEntity entity) async {
    return await _repository.registerFullDemandeur(entity);
  }
}