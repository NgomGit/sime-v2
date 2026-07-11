// features/profile/data/datasources/applicant_local_data_source.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sime_v2/features/profile/data/models/applicant_model.dart';

abstract class ApplicantLocalDataSource {
  Future<ApplicantModel?> getLastApplicant();
  Future<void> cacheApplicant(ApplicantModel applicant);
  Future<void> saveOfflineUpdate(int id, Map<String, dynamic> updatedFields);
  Future<Map<int, Map<String, dynamic>>> getPendingUpdates();
  Future<void> clearPendingUpdate(int id);
}

class ApplicantLocalDataSourceImpl implements ApplicantLocalDataSource {
  static const String _profileBoxName = 'applicant_box';
  static const String _syncBoxName = 'applicant_sync_box';

  @override
  Future<ApplicantModel?> getLastApplicant() async {
    final box = await Hive.openBox(_profileBoxName);
    final data = box.get('me');
    if (data != null) {
      return ApplicantModel.fromJson(Map<String, dynamic>.from(data));
    }
    return null;
  }

  @override
  Future<void> cacheApplicant(ApplicantModel applicant) async {
    final box = await Hive.openBox(_profileBoxName);
    await box.put('me', applicant.toJson());
  }

  @override
  Future<void> saveOfflineUpdate(int id, Map<String, dynamic> updatedFields) async {
    final box = await Hive.openBox(_syncBoxName);
    
    // Fusionner avec d'éventuelles modifications locales non encore synchronisées
    final existingUpdate = box.get(id);
    if (existingUpdate != null) {
      final merged = Map<String, dynamic>.from(existingUpdate as Map)..addAll(updatedFields);
      await box.put(id, merged);
    } else {
      await box.put(id, updatedFields);
    }

    // Mettre à jour immédiatement le cache local principal pour une UX instantanée
    final mainBox = await Hive.openBox(_profileBoxName);
    final currentLocal = mainBox.get('me');
    if (currentLocal != null) {
      final updatedMain = Map<String, dynamic>.from(currentLocal as Map)..addAll(updatedFields);
      await mainBox.put('me', updatedMain);
    }
  }

  @override
  Future<Map<int, Map<String, dynamic>>> getPendingUpdates() async {
    final box = await Hive.openBox(_syncBoxName);
    final Map<int, Map<String, dynamic>> pending = {};
    for (var key in box.keys) {
      pending[key as int] = Map<String, dynamic>.from(box.get(key));
    }
    return pending;
  }

  @override
  Future<void> clearPendingUpdate(int id) async {
    final box = await Hive.openBox(_syncBoxName);
    await box.delete(id);
  }
}

// features/profile/data/providers/profile_providers.dart

final applicantLocalDataSourceProvider = Provider<ApplicantLocalDataSource>(
  (ref) => ApplicantLocalDataSourceImpl(),
);

