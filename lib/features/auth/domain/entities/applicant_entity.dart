class ApplicantEntity {
  const ApplicantEntity({
    required this.id,
    required this.reference,
    required this.validated,
    this.dateBirth,
    this.placeBirth,
    this.residAddress,
    this.hasAdvisor = false,
    this.contacts = const [],
  });
 
  final int id;
  final String reference;
  final bool validated;
  final String? dateBirth;
  final String? placeBirth;
  final String? residAddress;
  final bool hasAdvisor;
  final List<ContactEntity> contacts;
}
 
class ContactEntity {
  const ContactEntity({required this.type, required this.value});
  final String type;  // PHONE, EMAIL…
  final String value;
}