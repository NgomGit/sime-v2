import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure([this.message = '']);
  final String message;

  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Erreur serveur. Veuillez réessayer.']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Pas de connexion internet.']);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Identifiants incorrects.']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Erreur de cache local.']);
}

class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Données invalides.']);
}
