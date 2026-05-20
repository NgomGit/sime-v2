import 'package:flutter_test/flutter_test.dart';
import 'package:sime_v2/features/dossier/domain/entities/dossier_entity.dart';

void main() {
  group('DossierEntity', () {
    test('progressRatio returns correct fraction', () {
      const dossier = DossierEntity(
        id: 'd001',
        referenceNumber: 'SN-001',
        serviceType: ServiceType.emploiSalarie,
        status: DossierStatus.enCours,
        currentStep: 3,
        totalSteps: 5,
      );
      expect(dossier.progressRatio, 0.6);
      expect(dossier.progressPercent, 60);
    });

    test('progressPercent rounds correctly', () {
      const dossier = DossierEntity(
        id: 'd002',
        referenceNumber: 'SN-002',
        serviceType: ServiceType.formation,
        status: DossierStatus.enCours,
        currentStep: 1,
        totalSteps: 3,
      );
      expect(dossier.progressPercent, 33);
    });

    test('full completion returns 100%', () {
      const dossier = DossierEntity(
        id: 'd003',
        referenceNumber: 'SN-003',
        serviceType: ServiceType.financement,
        status: DossierStatus.accepte,
        currentStep: 5,
        totalSteps: 5,
      );
      expect(dossier.progressRatio, 1.0);
      expect(dossier.progressPercent, 100);
    });
  });
}
