// features/offres/data/models/training_offer_model.dart
import 'dart:convert';

import '../../domain/entities/job_offer_entity.dart' show SkillRef, OfferSkill, NamedRef, PartnerInfo;
import '../../domain/entities/training_offer_entity.dart';

// Helpers de parsing (mêmes règles que job_offer_model — dupliqués pour garder
// chaque modèle auto-suffisant).

String _fixEncoding(String input) {
  if (input.isEmpty) return input;
  if (!input.contains('Ã') && !input.contains('Â')) return input;
  try {
    return utf8.decode(latin1.encode(input), allowMalformed: false);
  } catch (_) {
    return input;
  }
}

String? _fixStr(Object? value) {
  final s = value?.toString();
  if (s == null) return null;
  return _fixEncoding(s);
}

int? _asInt(Object? v) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v);
  return null;
}

DateTime? _asDate(Object? v) {
  final s = v?.toString();
  if (s == null || s.isEmpty) return null;
  return DateTime.tryParse(s);
}

Map<String, dynamic>? _basic(Object? node) {
  if (node is! Map<String, dynamic>) return null;
  final basic = node['basicInfo'];
  return basic is Map<String, dynamic> ? basic : node;
}

NamedRef? _namedRef(Object? node) {
  final b = _basic(node);
  if (b == null) return null;
  final id = _asInt(b['id']);
  if (id == null) return null;
  return NamedRef(id: id, code: _fixStr(b['code']), name: _fixStr(b['name']));
}

List<NamedRef> _namedRefList(Object? node) {
  if (node is! List) return const [];
  return node.map(_namedRef).whereType<NamedRef>().toList();
}

SkillRef _skillRef(Map<String, dynamic> skill) {
  final b = _basic(skill) ?? skill;
  return SkillRef(
    id: _asInt(b['id']) ?? _asInt(skill['id']) ?? 0,
    code: _fixStr(b['code']),
    name: _fixStr(b['name'] ?? skill['name']),
  );
}

List<OfferSkill> _offerSkills(Object? node) {
  if (node is! List) return const [];
  final out = <OfferSkill>[];
  for (final e in node) {
    if (e is! Map<String, dynamic>) continue;
    final skillNode = e['skill'];
    if (skillNode is! Map<String, dynamic>) continue;
    out.add(OfferSkill(
      id: _asInt(e['id']) ?? 0,
      skill: _skillRef(skillNode),
      weight: (e['weight'] as num?)?.toDouble() ?? 1.0,
    ));
  }
  return out;
}

PartnerInfo? _partner(Object? node) {
  final b = _basic(node);
  if (b == null) return null;
  final id = _asInt(b['id']);
  if (id == null) return null;
  final country = b['country'];
  return PartnerInfo(
    id: id,
    name: _fixStr(b['name']),
    type: _fixStr(b['type']),
    email: _fixStr(b['email']),
    phone: _fixStr(b['phone']),
    address: _fixStr(b['address']),
    countryName:
        country is Map<String, dynamic> ? _fixStr(country['name']) : null,
    lineBusiness: b['lineBusiness'] is Map<String, dynamic>
        ? _fixStr((b['lineBusiness'] as Map<String, dynamic>)['name'])
        : null,
  );
}

List<String> _fileUrls(Object? node) {
  if (node is! List) return const [];
  return node
      .map((e) => e?.toString() ?? '')
      .where((s) => s.trim().isNotEmpty)
      .toList();
}

class TrainingOfferModel extends TrainingOfferEntity {
  const TrainingOfferModel({
    required super.id,
    required super.name,
    super.status,
    super.description,
    super.reference,
    super.referencePartner,
    super.summary,
    super.mainTasks,
    super.toolsAndSupports,
    super.remuneration,
    super.yearsExperience,
    super.nbTotal,
    super.nbMaxApplic,
    super.nbRemApplic,
    super.startAt,
    super.duration,
    super.durationType,
    super.applicStartAt,
    super.applicEndAt,
    super.offerSkills,
    super.locationType,
    super.location,
    super.forNational,
    super.forInternational,
    super.offerStatus,
    super.areaExpertises,
    super.educationLevels,
    super.contract,
    super.partner,
    super.fileUrls,
    required this.rawJson,
  });

  final Map<String, dynamic> rawJson;

  factory TrainingOfferModel.fromJson(Map<String, dynamic> json) {
    return TrainingOfferModel(
      id: _asInt(json['id']) ?? 0,
      name: _fixStr(json['name']) ?? '',
      status: json['status'] as bool? ?? true,
      description: _fixStr(json['description']),
      reference: _fixStr(json['reference']),
      referencePartner: _fixStr(json['referencePartner']),
      summary: _fixStr(json['summary']),
      mainTasks: _fixStr(json['mainTasks']),
      toolsAndSupports: _fixStr(json['toolsAndSupports']),
      remuneration: _fixStr(json['remuneration']),
      yearsExperience: _asInt(json['yearsExperience']),
      nbTotal: _asInt(json['nbTotal']),
      nbMaxApplic: _asInt(json['nbMaxApplic']),
      nbRemApplic: _asInt(json['nbRemApplic']),
      startAt: _asDate(json['startAt']),
      duration: _asInt(json['duration']),
      durationType: _fixStr(json['durationType']),
      applicStartAt: _asDate(json['applicStartAt']),
      applicEndAt: _asDate(json['applicEndAt']),
      offerSkills: _offerSkills(json['offerSkills']),
      locationType: _fixStr(json['locationType']),
      location: _fixStr(json['location']),
      forNational: json['forNational'] as bool? ?? false,
      forInternational: json['forInternational'] as bool? ?? false,
      offerStatus: _fixStr(json['offerStatus']),
      areaExpertises: _namedRefList(json['areaExpertises']),
      educationLevels: _namedRefList(json['educationLevels']),
      contract: _namedRef(json['contract']),
      partner: _partner(json['partner']),
      fileUrls: _fileUrls(json['fileUrls']),
      rawJson: json,
    );
  }

  Map<String, dynamic> toJson() => rawJson;
}
