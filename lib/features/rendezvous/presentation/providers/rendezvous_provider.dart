import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/rendezvous_entity.dart';

final rendezvousListProvider = FutureProvider<List<RendezVousEntity>>((ref) async {
  await Future.delayed(const Duration(milliseconds: 600));
  return [
    RendezVousEntity(
      id: 'rv001',
      dateTime: DateTime(2026, 5, 18, 10, 30),
      location: 'Bureau Dakar Plateau',
      conseillerName: 'M. Diallo',
      status: RendezVousStatus.confirmed,
      officeAddress: 'Rue Carnot, Plateau',
    ),
    RendezVousEntity(
      id: 'rv002',
      dateTime: DateTime(2026, 5, 14, 9, 0),
      location: 'En ligne · Zoom',
      conseillerName: 'Mme Fall-Kane',
      status: RendezVousStatus.completed,
    ),
  ];
});

final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime(2026, 5, 18));
