 import '../../domain/entities/user_entity.dart';

class AuthResponseModel {
  final String token;
  final String type;
  final UserModel user;

  AuthResponseModel({
    required this.token,
    required this.type,
    required this.user,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      token: json['token'] ?? '',
      type: json['type'] ?? 'Bearer',
      user: UserModel.fromJson(json['user'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'type': type,
      'user': user.toJson(),
    };
  } 
}

class UserModel {
  final int id;
  final String firstName;
  final String lastName;
  final String username;
  final String email;
  final String phone;
  final int? applicantId;
  final String? dossierReference;

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.email,
    required this.phone,
    this.applicantId,
    this.dossierReference,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final applicantJson = json['applicant'] as Map<String, dynamic>?;
    
    return UserModel(
      id: json['id'] ?? 0,
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      applicantId: json['applicantId'],
      dossierReference: applicantJson?['reference'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'username': username,
      'email': email,
      'phone': phone,
      'applicantId': applicantId,
      'dossierReference': dossierReference,
    };
  } 

  // Mapper direct vers ton entité de domaine existante
  UserEntity toEntity() {
    return UserEntity(
      id: id.toString(),
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      role: UserRole.demandeur, // Mappé sur la base de la logique métier DEMANDEUR
      dossierNumber: dossierReference ?? '',
    );
  }
}