import 'package:flutter_test/flutter_test.dart';
import 'package:sime_v2/features/offres/domain/entities/offre_entity.dart';
import 'package:sime_v2/features/offres/presentation/providers/offres_provider.dart';

void main() {
  group('OffresFilter', () {
    test('default filter has no type and empty query', () {
      const filter = OffresFilter();
      expect(filter.type, isNull);
      expect(filter.query, isEmpty);
    });

    test('type filter stores selected type', () {
      const filter = OffresFilter(type: OffreType.formation);
      expect(filter.type, OffreType.formation);
    });

    test('query filter stores search string', () {
      const filter = OffresFilter(query: 'développeur');
      expect(filter.query, 'développeur');
    });
  });
}
