enum RdvStatus {
  pending,
  confirmed,
  cancelled,
  done;
 
  static RdvStatus fromString(String s) => switch (s) {
        'PENDING'   => RdvStatus.pending,
        'CONFIRMED' => RdvStatus.confirmed,
        'CANCELLED' => RdvStatus.cancelled,
        'DONE'      => RdvStatus.done,
        _           => RdvStatus.pending,
      };
 
  String get label => switch (this) {
        RdvStatus.pending   => 'En attente',
        RdvStatus.confirmed => 'Confirmé',
        RdvStatus.cancelled => 'Annulé',
        RdvStatus.done      => 'Terminé',
      };
}
 
class RdvEntity {
  const RdvEntity({
    required this.id,
    required this.startAt,
    required this.status,
    this.endAt,
    this.agentId,
    this.tokenRdv,
    this.applicantObservation,
  });
 
  final int id;
  final DateTime startAt;
  final RdvStatus status;
  final DateTime? endAt;
  final int? agentId;
  final String? tokenRdv;
  final String? applicantObservation;
 
  bool get isUpcoming =>
      startAt.isAfter(DateTime.now()) && status != RdvStatus.cancelled;
}
 