class PlaceInfo {
  const PlaceInfo({
    required this.id,
    required this.name,
    this.photoUrl,
    this.address,
    this.typePlace,
    required this.isOpened,
  });
  final bool isOpened;
  final int id;
  final String name;
  final String? photoUrl;
  final String? address;
  final String? typePlace;
}
