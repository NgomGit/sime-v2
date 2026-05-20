import 'package:equatable/equatable.dart';

enum UserRole { demandeur, conseiller, chefAntenne, responsable, admin }

class UserEntity extends Equatable {
  const UserEntity({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.role,
    this.email,
    this.dossierNumber,
    this.avatarUrl,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String phone;
  final UserRole role;
  final String? email;
  final String? dossierNumber;
  final String? avatarUrl;

  String get fullName => '$firstName $lastName';
  String get initials {
    final f = firstName.isNotEmpty ? firstName[0] : '';
    final l = lastName.isNotEmpty ? lastName[0] : '';
    return '$f$l'.toUpperCase();
  }

  @override
  List<Object?> get props => [id, firstName, lastName, phone, role, email];
}
