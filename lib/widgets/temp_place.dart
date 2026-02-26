import 'package:image_picker/image_picker.dart';

class TempPlace {
  final String name;
  final String address;
  final String typePlace;
  final String country;
  final double? latitude;
  final double? longitude;
  final XFile? image;

  TempPlace({
    required this.name,
    required this.address,
    required this.typePlace,
    required this.country,
    this.latitude,
    this.longitude,
    this.image,
  });
}
