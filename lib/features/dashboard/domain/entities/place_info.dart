class PlaceInfo {
  const PlaceInfo({
    required this.id,
    required this.name,
    this.photoUrl,
  });

  final int id;
  final String name;
  final String? photoUrl;
}