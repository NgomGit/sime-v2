
enum SubscriptionStatus {
  inValidation,
  validated,
  rejected,
  suspended,
  closed;
 
  static SubscriptionStatus fromString(String s) => switch (s) {
        'IN_VALIDATION' => SubscriptionStatus.inValidation,
        'VALIDATED'     => SubscriptionStatus.validated,
        'REJECTED'      => SubscriptionStatus.rejected,
        'SUSPENDED'     => SubscriptionStatus.suspended,
        'CLOSED'        => SubscriptionStatus.closed,
        _               => SubscriptionStatus.inValidation,
      };
 
  String get label => switch (this) {
        SubscriptionStatus.inValidation => 'En validation',
        SubscriptionStatus.validated    => 'Validée',
        SubscriptionStatus.rejected     => 'Rejetée',
        SubscriptionStatus.suspended    => 'Suspendue',
        SubscriptionStatus.closed       => 'Clôturée',
      };
}
 
class SubscriptionEntity {
  const SubscriptionEntity({
    required this.id,
    required this.reference,
    required this.status,
    this.typeServiceId,
    this.typeServiceLabel,
    this.serviceId,
    this.serviceName,
  });
 
  final int id;
  final String reference;
  final SubscriptionStatus status;
  final int? typeServiceId;
  final String? typeServiceLabel;
  final int? serviceId;
  final String? serviceName;
}
 