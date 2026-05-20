import 'package:sime_v2/features/profile/data/models/user_profile_entity.dart';
import 'package:sime_v2/features/profile/domain/repositories/user_profile_repository.dart';

import '../../domain/entities/user_profile_entity.dart';


class UserProfileRepositoryImpl implements UserProfileRepository {
  // Ici vous injecteriez votre client Http ou Firebase (Dio, Supabase, etc.)
  
  @override
  Future<UserProfileEntity> getUserProfile() async {
    // Simulation du délai réseau
    await Future.delayed(const Duration(milliseconds: 600));
    
    // Données Mockées basées fidèlement sur votre fichier HTML
    final mockJson = {
      'id': 'usr_01',
      'first_name': 'Mamadou',
      'last_name': 'Aidara',
      'email': 'mamadou.aidara@gmail.com',
      'phone': '+221 77 456 78 90',
      'location': 'Médina, Dakar',
      'birth_date': '15/03/2000',
      'cin': '12345678901234',
      'nationality': '🇸🇳 Sénégalaise',
      'study_level': 'Supérieur (Bac+3)',
      'domain': 'Numérique & IT',
      'experience': '2–4 ans',
      'last_degree': 'Licence Informatique',
      'tags': ['Emploi salarié', 'Numérique', 'Bac+3'],
      'cv_url': 'https://sime.anpej.sn/cv/mamadou_aidara.pdf',
    };
    
    return UserProfileModel.fromJson(mockJson);
  }

  @override
  Future<void> updateProfile(UserProfileEntity profile) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 300));
  }
}