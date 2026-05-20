import 'package:equatable/equatable.dart';

enum RendezVousStatus { scheduled, confirmed, started, completed, cancelled }

class RendezVousEntity extends Equatable {
  const RendezVousEntity({
    required this.id,
    required this.dateTime,
    required this.location,
    required this.conseillerName,
    required this.status,
    this.conseillerPhone,
    this.conseillerEmail,
    this.officeAddress,
    this.notes,
  });

  final String id;
  final DateTime dateTime;
  final String location;
  final String conseillerName;
  final RendezVousStatus status;
  final String? conseillerPhone;
  final String? conseillerEmail;
  final String? officeAddress;
  final String? notes;

  bool get isUpcoming => dateTime.isAfter(DateTime.now());

  @override
  List<Object?> get props => [id, dateTime, status];
}
