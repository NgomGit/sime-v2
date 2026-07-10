import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final String? status;

  ApiException({required this.message, this.status});

  factory ApiException.fromDioException(DioException dioException) {
    String userMessage = "Une erreur inattendue est survenue.";
    String? statusResponse = "ERROR";

    final responseData = dioException.response?.data;

    if (responseData != null && responseData is Map<String, dynamic>) {
      statusResponse = responseData['status']?.toString();
      
      // 1. Extraction prioritaire de la première violation (ex: "Ce nom d'utilisateur est déjà utilisé")
      if (responseData.containsKey('violations') && responseData['violations'] is List) {
        final violations = responseData['violations'] as List;
        if (violations.isNotEmpty && violations[0] is Map) {
          final firstViolation = violations[0] as Map<String, dynamic>;
          if (firstViolation.containsKey('message')) {
            return ApiException(
              message: firstViolation['message'].toString(),
              status: statusResponse,
            );
          }
        }
      }

      // 2. Fallback sur le message global si aucune violation précise n'est fournie
      userMessage = responseData['message']?.toString() ?? userMessage;
    } else {
      userMessage = dioException.message ?? userMessage;
    }

    return ApiException(message: userMessage, status: statusResponse);
  }

  @override
  String toString() => message;
}