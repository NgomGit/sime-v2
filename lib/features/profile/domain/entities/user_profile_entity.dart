import 'package:flutter/foundation.dart';

@immutable
class UserProfileEntity {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String location;
  final String birthDate;
  final String cin;
  final String nationality;
  final String studyLevel;
  final String domain;
  final String experience;
  final String lastDegree;
  final List<String> tags;
  final String? cvUrl;
  final String? avatarUrl;

  const UserProfileEntity({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.location,
    required this.birthDate,
    required this.cin,
    required this.nationality,
    required this.studyLevel,
    required this.domain,
    required this.experience,
    required this.lastDegree,
    required this.tags,
    this.cvUrl,
    this.avatarUrl,
  });

   /// Permet de copier l'instance actuelle en modifiant uniquement certains champs.
  UserProfileEntity copyWith({
    String? fullName,
    String? birthDate,
    String? cin,
    String? nationality,
    String? location,
    String? studyLevel,
    String? domain,
    String? experience,
    String? lastDegree,
  }) {
    return UserProfileEntity(
      id: id,
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phone,
      birthDate: birthDate ?? this.birthDate,
      cin: cin ?? this.cin,
      nationality: nationality ?? this.nationality,
      location: location ?? this.location,
      studyLevel: studyLevel ?? this.studyLevel,
      domain: domain ?? this.domain,
      experience: experience ?? this.experience,
      lastDegree: lastDegree ?? this.lastDegree, tags: tags,
    );
  }

  String get fullName => '$firstName $lastName';
  
  String get initials {
    if (firstName.isEmpty || lastName.isEmpty) return 'MA';
    return '${firstName[0]}${lastName[0]}'.toUpperCase();
  }
}