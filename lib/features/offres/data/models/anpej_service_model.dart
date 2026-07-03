import 'package:sime_v2/features/offres/domain/entities/anpej_service_entity.dart';

class AnpejServiceModel extends AnpejServiceEntity {
  const AnpejServiceModel({
    required super.id,
    required super.code,
    required super.name,
    super.typeServiceId,
  });
 
  factory AnpejServiceModel.fromJson(Map<String, dynamic> json) =>
      AnpejServiceModel(
        id: json['id'] as int,
        code: json['code'] as String,
        name: json['name'] as String,
        typeServiceId:
            (json['typeService'] as Map<String, dynamic>?)?['id'] as int?,
      );
 
  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
        'name': name,
        if (typeServiceId != null) 'typeService': {'id': typeServiceId},
      };
}