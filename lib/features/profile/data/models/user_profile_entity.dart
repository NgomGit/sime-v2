import '../../domain/entities/user_profile_entity.dart';

class UserProfileModel extends UserProfileEntity {
  const UserProfileModel({
    required super.id,
    required super.firstName,
    required super.lastName,
    required super.email,
    required super.phone,
    required super.location,
    required super.birthDate,
    required super.cin,
    required super.nationality,
    required super.studyLevel,
    required super.domain,
    required super.experience,
    required super.lastDegree,
    required super.tags,
    super.cvUrl,
    super.avatarUrl,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      location: json['location'] as String,
      birthDate: json['birth_date'] as String,
      cin: json['cin'] as String,
      nationality: json['nationality'] as String,
      studyLevel: json['study_level'] as String,
      domain: json['domain'] as String,
      experience: json['experience'] as String,
      lastDegree: json['last_degree'] as String,
      tags: List<String>.from(json['tags'] ?? []),
      cvUrl: json['cv_url'] as String?,
      avatarUrl: json['avatar_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'location': location,
      'birth_date': birthDate,
      'cin': cin,
      'nationality': nationality,
      'study_level': studyLevel,
      'domain': domain,
      'experience': experience,
      'last_degree': lastDegree,
      'tags': tags,
      'cv_url': cvUrl,
      'avatar_url': avatarUrl,
    };
  }
}