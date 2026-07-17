// features/rendezvous/domain/repositories/rdv_repository.dart
import 'package:dartz/dartz.dart';
import 'package:sime_v2/core/error/failures.dart';
import 'package:sime_v2/features/rendezvous/domain/entities/rdv_entity.dart';

/// Périmètre actuel : lecture seule (affichage de l'agenda). La prise de RDV
/// (POST /rdv/api/rdvs, /me/auto) et les actions sur un RDV existant
/// (annulation via PATCH) existaient dans une version antérieure de ce
/// fichier mais n'étaient jamais branchées côté UI ni testées avec un
/// payload réel — retirées pour l'instant plutôt que laissées comme code
/// mort trompeur. À réintroduire en suivant le même pattern que
/// `ApplicantRepositoryImpl.updateApplicantProfile` (file d'attente
/// offline via un datasource local + queue Hive) une fois le contrat exact
/// de ces endpoints confirmé.
abstract interface class RdvRepository {
  /// GET /rdv/api/rdvs/me
  Future<Either<Failure, List<RdvEntity>>> getMyRdvs();
}
