import 'package:flutter_test/flutter_test.dart';
import 'package:sime_v2/features/auth/domain/entities/user_entity.dart';

void main() {
  group('UserEntity', () {
    const user = UserEntity(
      id: 'u001',
      firstName: 'Mamadou',
      lastName: 'Aidara',
      phone: '+221770000000',
      role: UserRole.demandeur,
    );

    test('fullName concatenates first and last name', () {
      expect(user.fullName, 'Mamadou Aidara');
    });

    test('initials returns uppercase first letters', () {
      expect(user.initials, 'MA');
    });

    test('initials handles single-char names', () {
      const u = UserEntity(id: 'u2', firstName: 'A', lastName: 'B', phone: '0', role: UserRole.conseiller);
      expect(u.initials, 'AB');
    });
  });
}
