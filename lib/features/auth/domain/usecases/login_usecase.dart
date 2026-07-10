// features/auth/domain/usecases/login_usecase.dart

import 'package:sime_v2/features/auth/data/models/auth_response_model.dart';
import 'package:sime_v2/features/auth/domain/repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository _repository;

  LoginUseCase(this._repository);

  Future<AuthResponseModel> call(String username, String password) async {
    return await _repository.login(username, password);
  }
}