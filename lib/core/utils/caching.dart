// ── Helper générique liste depuis cache ───────────────────────────────────────
List<T> listFromCache<T>(
  dynamic json,
  T Function(Map<String, dynamic>) fromJson,
) =>
    (json as List<dynamic>)
        .map((e) => fromJson(e as Map<String, dynamic>))
        .toList();
 
// ── Helper générique sérialisation liste ──────────────────────────────────────
List<Map<String, dynamic>> listToJson<T>(
  List<T> list,
  Map<String, dynamic> Function(T) toJson,
) =>
    list.map(toJson).toList();