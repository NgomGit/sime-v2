import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure({required this.message, this.statusCode});
  final String message;
  final int? statusCode;
  @override
  List<Object?> get props => [message, statusCode];
}

class NetworkFailure extends Failure {
  const NetworkFailure({required super.message}) : super(statusCode: 503);
}

class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.statusCode});
}

class CacheFailure extends Failure {
  const CacheFailure({required super.message}) : super(statusCode: null);
}

class AuthFailure extends Failure {
  const AuthFailure({required super.message}) : super(statusCode: 401);
}

class ValidationFailure extends Failure {
  const ValidationFailure({required super.message, this.fieldErrors = const {}})
      : super(statusCode: 422);
  final Map<String, String> fieldErrors;
  @override
  List<Object?> get props => [message, statusCode, fieldErrors];
}

class NotFoundFailure extends Failure {
  const NotFoundFailure({required super.message}) : super(statusCode: 404);
}
