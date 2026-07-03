class AnpejServiceEntity {
  const AnpejServiceEntity({
    required this.id,
    required this.code,
    required this.name,
    this.typeServiceId,
  });
 
  final int id;
  final String code;
  final String name;
  final int? typeServiceId;
}