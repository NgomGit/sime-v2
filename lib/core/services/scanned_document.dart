// core/services/scanned_document.dart

class ScannedDocument {
  const ScannedDocument({
    this.firstName,
    this.lastName,
    this.dateOfBirth,
    this.placeOfBirth,
    this.nationalId,
    this.sex,
    this.nationality,
    this.expiryDate,
    this.deliveryDate, // ← nouveau
    this.documentType,
  });

  final String? firstName;
  final String? lastName;
  final DateTime? dateOfBirth;
  final String? nationalId;
  final String? sex;
  final String? nationality;
  final DateTime? expiryDate;
  final DateTime? deliveryDate; // ← nouveau
  final DocumentType? documentType;
  final String? placeOfBirth;

  bool get isEmpty =>
      firstName == null &&
      lastName == null &&
      dateOfBirth == null &&
      nationalId == null &&
      placeOfBirth == null;

  @override
  String toString() =>
      'ScannedDocument(firstName: $firstName, lastName: $lastName, '
      'dob: $dateOfBirth, id: $nationalId, sex: $sex, '
      'delivery: $deliveryDate, expiry: $expiryDate, placeOfBirth: $placeOfBirth)';
}

enum DocumentType { nationalId, passport }
