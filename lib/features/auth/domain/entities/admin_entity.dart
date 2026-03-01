class AdminEntity {
  final int id;
  final String name;
  final String? photoUrl;

  AdminEntity({
    required this.id,
    required this.name,
    this.photoUrl,
  });
}