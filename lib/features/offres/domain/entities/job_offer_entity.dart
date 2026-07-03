
enum JobOfferStatus { draft, published, closed, archived }
 
class JobOfferEntity {
  const JobOfferEntity({
    required this.id,
    required this.title,
    required this.status,
    this.description,
    this.location,
    this.contractType,
    this.deadline,
    this.partnerId,
  });
 
  final int id;
  final String title;
  final JobOfferStatus status;
  final String? description;
  final String? location;
  final String? contractType;
  final String? deadline;
  final int? partnerId;
 
  bool get isAvailable => status == JobOfferStatus.published;
}