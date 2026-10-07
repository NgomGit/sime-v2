// features/besoin/data/models/my_subscription_model.dart
import '../../domain/entities/my_subscription_entity.dart';
import 'besoin_models.dart';

class MySubscriptionModel extends MySubscriptionEntity {
  const MySubscriptionModel({
    required super.id,
    required super.reference,
    required super.statusSub,
    super.subStatusCode,
    super.subStatusName,
    super.typeService,
    super.partnerService,
    super.service,
    super.extReference,
    super.sentToPartner,
    super.hasAdvisor,
    required this.rawJson,
  });

  /// JSON brut conservé pour un aller-retour de cache Hive fidèle.
  final Map<String, dynamic> rawJson;

  factory MySubscriptionModel.fromJson(Map<String, dynamic> json) {
    final subStatus = json['subStatus'] as Map<String, dynamic>?;
    final typeService = json['typeService'] as Map<String, dynamic>?;
    final partnerService = json['partnerService'] as Map<String, dynamic>?;
    final service = json['service'] as Map<String, dynamic>?;

    return MySubscriptionModel(
      id: json['id'] as int? ?? 0,
      reference: json['reference']?.toString() ?? '',
      statusSub: json['statusSub']?.toString() ?? '',
      subStatusCode: subStatus?['code']?.toString(),
      subStatusName: subStatus?['name']?.toString(),
      // On réutilise les modèles du parcours de sélection : ils gèrent déjà la
      // correction du double-encodage UTF-8 des libellés (« MobilitÃ© »…).
      typeService:
          typeService != null ? TypeServiceModel.fromJson(typeService) : null,
      partnerService: partnerService != null
          ? PartnerServiceModel.fromJson(partnerService)
          : null,
      service: service != null ? ServiceOfferModel.fromJson(service) : null,
      extReference: json['extReference']?.toString(),
      sentToPartner: json['sentToPartner'] as bool? ?? false,
      hasAdvisor: json['hasAdvisor'] as bool? ?? false,
      rawJson: json,
    );
  }

  Map<String, dynamic> toJson() => rawJson;
}
