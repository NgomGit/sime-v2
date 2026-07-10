class ReferenceModel {
  final int id;
  final String name;
  final String? code;

  const ReferenceModel({
    required this.id,
    required this.name,
    this.code,
  });

  factory ReferenceModel.fromJson(Map<String, dynamic> json) {
    return ReferenceModel(
      id: json['id'] as int,
      // Le backend alterne parfois entre 'name', 'libelle' ou 'nameFr'
      name: (json['name'] ?? json['libelle'] ?? json['nameFr'] ?? '').toString(),
      code: (json['code'] ?? json['iso3'] ?? json['codeAlpha2'])?.toString(),
    );
  }
}

class CountryModel {
  final int id;
  final String code;
  final String alpha2;
  final String name;

  CountryModel({
    required this.id,
    required this.code,
    required this.alpha2,
    required this.name,
  });

  factory CountryModel.fromJson(Map<String, dynamic> json) {
    return CountryModel(
      id: json['id'] ?? 0,
      code: json['code'] ?? '',
      alpha2: json['alpha2'] ?? '',
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'alpha2': alpha2,
      'name': name,
    };
  }
}


class RegionModel {
  final int id;
  final String code;
  final String name;
  final bool status;
  final CountryModel? country; // Relation typée vers CountryModel

  RegionModel({
    required this.id,
    required this.code,
    required this.name,
    required this.status,
    this.country,
  });

  factory RegionModel.fromJson(Map<String, dynamic> json) {
    return RegionModel(
      id: json['id'] ?? 0,
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      status: json['status'] ?? false,
      country: json['country'] != null
          ? CountryModel.fromJson(json['country'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'status': status,
      if (country != null) 'country': country!.toJson(),
    };
  }
}

class DepartmentModel {
  final int id;
  final String code;
  final String name;
  final RegionModel? region; // Relation imbriquée typée !

  DepartmentModel({
    required this.id,
    required this.code,
    required this.name,
    this.region,
  });

  factory DepartmentModel.fromJson(Map<String, dynamic> json) {
    return DepartmentModel(
      id: json['id'] ?? 0,
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      region: json['region'] != null 
          ? RegionModel.fromJson(json['region'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      if (region != null) 'region': region!.toJson(),
    };
  }
}