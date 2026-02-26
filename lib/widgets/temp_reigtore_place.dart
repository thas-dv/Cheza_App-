import 'package:image_picker/image_picker.dart';

class TempRegisterStore {
  // PLACE
  static String? placeName;
  static String? placeAddress;
  static String? placeType;
  static String? placeCountry; // nom du pays
  static double? latitude;
  static double? longitude;
  static XFile? placeImage;

  static bool hasPlace() {
    return placeName != null &&
        placeAddress != null &&
        placeType != null &&
        placeCountry != null;
  }

  static void clear() {
    placeName = null;
    placeAddress = null;
    placeType = null;
    placeCountry = null;
    latitude = null;
    longitude = null;
    placeImage = null;
  }
}
