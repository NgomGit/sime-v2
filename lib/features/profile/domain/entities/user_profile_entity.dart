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

  String get fullName => '$firstName $lastName';
  
  String get initials {
    if (firstName.isEmpty || lastName.isEmpty) return 'MA';
    return '${firstName[0]}${lastName[0]}'.toUpperCase();
  }
}