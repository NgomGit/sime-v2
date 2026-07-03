
import 'package:sime_v2/features/auth/domain/entities/subscription_entity.dart';

class SubscriptionModel extends SubscriptionEntity {
  const SubscriptionModel({
    required super.id,
    required super.reference,
    required super.status,
    super.typeServiceId,
    super.typeServiceLabel,
    super.serviceId,
    super.serviceName,
  });
 
  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    final typeService =
        json['typeService'] as Map<String, dynamic>?;
    final service = json['service'] as Map<String, dynamic>?;
 
    return SubscriptionModel(
      id: json['id'] as int,
      reference: json['reference'] as String? ?? '',
      status: SubscriptionStatus.fromString(
        json['statusSub'] as String? ?? 'IN_VALIDATION',
      ),
      typeServiceId: typeService?['id'] as int?,
      typeServiceLabel: typeService?['label'] as String?,
      serviceId: service?['id'] as int?,
      serviceName: service?['name'] as String?,
    );
  }
 
  Map<String, dynamic> toJson() => {
        'id': id,
        'reference': reference,
        'statusSub': status.name.toUpperCase(),
      };
}