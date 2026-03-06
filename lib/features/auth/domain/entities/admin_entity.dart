class AdminEntity {
  final String id;
  final String name;
  final String? photoUrl;

  AdminEntity({
    required this.id,
    required this.name,
    this.photoUrl,
  });
}