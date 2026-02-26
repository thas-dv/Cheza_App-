import 'dart:io';
import 'package:geolocator/geolocator.dart';

import 'package:cheza_app/pages/registerAdmin.dart';
// import 'package:cheza_app/themes/app_colors.dart';
// import 'package:cheza_app/widgets/network_aware_wrapper.dart';
import 'package:cheza_app/widgets/temp_reigtore_place.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class RegisterPlacePage extends StatefulWidget {
  const RegisterPlacePage({super.key});

  @override
  State<RegisterPlacePage> createState() => _RegisterPlacePageState();
}

class _RegisterPlacePageState extends State<RegisterPlacePage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController addressCtrl = TextEditingController();
  final TextEditingController latitudeCtrl = TextEditingController();
  final TextEditingController longitudeCtrl = TextEditingController();

  String? selectedType;
  XFile? selectedImage;
  String? selectedCountryName;

  bool isLoading = false;

  final placeTypes = [
    "Bar",
    "Club",
    "Lounge",
    "Restaurant",
    "Salon",
    "Spa",
    "Gym",
    "Hotel",
  ];

  Future<void> pickImage() async {
    try {
      final picker = ImagePicker();
      final img = await picker.pickImage(source: ImageSource.gallery);

      if (!mounted) return;

      if (img != null) {
        setState(() {
          selectedImage = img;
        });
      }
    } catch (e) {
      debugPrint("Erreur image picker: $e");
    }
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    addressCtrl.dispose();
    latitudeCtrl.dispose();
    longitudeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),

      body: Stack(
        children: [
          /// BACKGROUND
          Positioned.fill(
            child: Image.asset(
              "assets/images/fondlogin.png",
              fit: BoxFit.cover,
              alignment: Alignment.centerRight,
            ),
          ),

          /// OVERLAY
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  stops: [0.0, 0.4, 0.7, 1],
                  colors: [
                    Color(0xFF0F0C29),
                    Color(0xFF141235),
                    Color(0x99000000),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          /// CONTENU
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Container(
                  width: isDesktop ? 1100 : double.infinity,
                  margin: EdgeInsets.all(isDesktop ? 15 : 0),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 80 : 25,
                      vertical: 10,
                    ),
                    child: isDesktop
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(flex: 5, child: _leftForm()),
                              const Spacer(),
                              Expanded(flex: 3, child: _uploadSection()),
                            ],
                          )
                        : _leftForm(isMobile: true),
                  ),
                ),
              ),
            ),
          ),

          /// 🔥 FLÈCHE RETOUR (TOUJOURS EN DERNIER)
          if (isDesktop)
            SafeArea(
              child: Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(30),
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withOpacity(0.4),
                          border: Border.all(
                            color: const Color(0xFFB44CFF).withOpacity(0.4),
                          ),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _neonInput(
    TextEditingController ctrl,
    String hint,
    bool read,
    String? Function(String?)? validator,
  ) {
    return TextFormField(
      validator: validator,
      readOnly: read,
      controller: ctrl,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: read
            ? TextStyle(color: Colors.blueGrey)
            : TextStyle(color: Colors.white),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 25,
          vertical: 18,
        ),
        filled: true,
        fillColor: const Color(0xFF1A1443).withOpacity(0.6),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(40),
          borderSide: const BorderSide(color: Color(0xFF6A5AE0), width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(40),
          borderSide: const BorderSide(color: Color(0xFFB44CFF), width: 2),
        ),
      ),
    );
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    Position position = await Geolocator.getCurrentPosition();

    latitudeCtrl.text = position.latitude.toString();
    longitudeCtrl.text = position.longitude.toString();
  }

  Widget _leftForm({bool isMobile = false}) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 600;

    return SizedBox(
      width: isDesktop ? 500 : double.infinity,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Enregistrer un Nouveau Lieu",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 30),

            // NOM
            _neonInput(
              nameCtrl,
              'Nom du Lieu',
              false,
              (v) => v == null || v.isEmpty ? "Latitude obligatoire" : null,
            ),

            const SizedBox(height: 15),

            // ADRESSE
            _neonInput(
              addressCtrl,
              "Adresse",
              false,
              (v) => v == null || v.isEmpty ? "Latitude obligatoire" : null,
            ),
            const SizedBox(height: 15),

            // 🔥 LATITUDE
            _neonInput(
              latitudeCtrl,
              "Latitude",
              false,
              (v) => v == null || v.isEmpty ? "Latitude obligatoire" : null,
            ),
            const SizedBox(height: 15),

            // 🔥 LONGITUDE
            _neonInput(
              longitudeCtrl,
              "Longitude",
              false,
              (v) => v == null || v.isEmpty ? "Latitude obligatoire" : null,
            ),
            const SizedBox(height: 15),
            // TYPE + PAYS RESPONSIVE
            if (isDesktop)
              Row(
                children: [
                  Expanded(child: _styledDropdown()),
                  const SizedBox(width: 20),
                  Expanded(child: _styledCountryPicker()),
                ],
              )
            else
              Column(
                children: [
                  _styledDropdown(),
                  const SizedBox(height: 15),
                  _styledCountryPicker(),
                ],
              ),

            const SizedBox(height: 15),

            // 🔥 GPS + PHOTO ALIGNÉS EN MOBILE
            if (isDesktop)
              _gpsButton()
            else
              Row(
                children: [
                  Expanded(flex: 3, child: _gpsButton()),
                  const SizedBox(width: 15),
                  Expanded(flex: 1, child: _uploadCircleMobile()),
                ],
              ),

            const SizedBox(height: 40),

            // BOUTON FINAL
            _submitButton(),
          ],
        ),
      ),
    );
  }

  Widget _uploadCircleMobile() {
    return GestureDetector(
      onTap: isLoading ? null : pickImage,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xFF6A5AE0), Color(0xFFB44CFF)],
          ),
        ),
        child: ClipOval(
          child: selectedImage == null
              ? const Icon(Icons.camera_alt, color: Colors.white, size: 25)
              : Image.file(File(selectedImage!.path), fit: BoxFit.cover),
        ),
      ),
    );
  }

  Widget _uploadSection({bool isMobile = false}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: isLoading ? null : pickImage,
          child: Container(
            height: isMobile ? 60 : 120,
            width: isMobile ? 60 : 120,

            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF6A5AE0), Color(0xFFB44CFF)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFB44CFF).withOpacity(0.6),
                  blurRadius: 25,
                ),
              ],
            ),
            child: ClipOval(
              child: selectedImage == null
                  ? const Icon(Icons.camera_alt, color: Colors.white, size: 40)
                  : Image.file(File(selectedImage!.path), fit: BoxFit.cover),
            ),
          ),
        ),
        const SizedBox(height: 15),
        const Text(
          "Télécharger des Photos",
          style: TextStyle(color: Colors.white70),
        ),
      ],
    );
  }

  Widget _gpsButton() {
    return Container(
      height: 55,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6A5AE0), Color(0xFFB44CFF)],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB44CFF).withOpacity(0.5),
            blurRadius: 20,
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : _getCurrentLocation,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        icon: const Icon(Icons.my_location, color: Colors.white),
        label: const Text(
          "Obtenir Position GPS",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _submitButton() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6A5AE0), Color(0xFFB44CFF)],
        ),
        borderRadius: BorderRadius.circular(30),
      ),
      child: ElevatedButton(
        onPressed: isLoading
            ? null
            : () {
                if (!_formKey.currentState!.validate()) return;

                final lat = double.tryParse(latitudeCtrl.text.trim());
                final lng = double.tryParse(longitudeCtrl.text.trim());

                if (lat == null || lng == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Latitude et longitude invalides"),
                    ),
                  );
                  return;
                }

                // STOCKAGE TEMPORAIRE
                TempRegisterStore.placeName = nameCtrl.text.trim();
                TempRegisterStore.placeAddress = addressCtrl.text.trim();
                TempRegisterStore.placeType = selectedType;
                TempRegisterStore.placeCountry = selectedCountryName;
                TempRegisterStore.latitude = lat;
                TempRegisterStore.longitude = lng;
                TempRegisterStore.placeImage = selectedImage;

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterAdminPage()),
                );
              },

        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        child: const Text(
          "S'inscrire",
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
    );
  }

  Widget _styledDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedType,
      style: const TextStyle(color: Colors.white),
      dropdownColor: const Color(0xFF1A1443),
      icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white70),

      decoration: InputDecoration(
        hintText: "Type de lieu",
        hintStyle: const TextStyle(color: Colors.white60),
        filled: true,
        fillColor: const Color(0xFF1A1443).withOpacity(0.6),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 25,
          vertical: 18,
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(40),
          borderSide: const BorderSide(color: Color(0xFF6A5AE0), width: 1.2),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(40),
          borderSide: const BorderSide(color: Color(0xFFB44CFF), width: 2),
        ),
      ),

      items: placeTypes
          .map(
            (e) => DropdownMenuItem(
              value: e,
              child: Text(e, style: const TextStyle(color: Colors.white)),
            ),
          )
          .toList(),

      onChanged: isLoading ? null : (v) => setState(() => selectedType = v),

      validator: (v) => v == null ? "Choisir un type" : null,
    );
  }

  Widget _styledCountryPicker() {
    return FormField<String>(
      validator: (value) {
        if (selectedCountryName == null) {
          return "Pays obligatoire";
        }
        return null;
      },
      builder: (FormFieldState<String> state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: isLoading
                  ? null
                  : () {
                      showCountryPicker(
                        context: context,
                        showPhoneCode: false,
                        onSelect: (country) {
                          if (!mounted) return;
                          setState(() {
                            selectedCountryName = country.name;
                            state.didChange(country.name);
                          });
                        },
                      );
                    },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1443).withOpacity(0.6),
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(
                    color: state.hasError
                        ? Colors.red
                        : const Color(0xFF6A5AE0),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        selectedCountryName ?? "Pays",
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: selectedCountryName == null
                              ? Colors.white60
                              : Colors.white,
                        ),
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down, color: Colors.white70),
                  ],
                ),
              ),
            ),
            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(left: 20, top: 8),
                child: Text(
                  state.errorText!,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                ),
              ),
          ],
        );
      },
    );
  }

  // Widget _styledCountryPicker() {
  //   return GestureDetector(
  //     onTap: isLoading
  //         ? null
  //         : () {
  //             showCountryPicker(
  //               context: context,
  //               showPhoneCode: false,
  //               onSelect: (country) {
  //                 if (!mounted) return;
  //                 setState(() {
  //                   selectedCountryName = country.name;
  //                 });
  //               },
  //             );
  //           },
  //     child: Container(
  //       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
  //       decoration: BoxDecoration(
  //         color: const Color(0xFF1A1443).withOpacity(0.6),
  //         borderRadius: BorderRadius.circular(40),
  //         border: Border.all(color: const Color(0xFF6A5AE0)),
  //       ),
  //       child: Row(
  //         children: [
  //           Expanded(
  //             // 🔥 IMPORTANT
  //             child: Text(
  //               selectedCountryName ?? "Pays",
  //               overflow: TextOverflow.ellipsis,
  //               style: TextStyle(
  //                 color: selectedCountryName == null
  //                     ? Colors.white60
  //                     : Colors.white,
  //               ),
  //             ),
  //           ),
  //           const Icon(Icons.arrow_drop_down, color: Colors.white70),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // InputDecoration _input(String label) {
  //   return InputDecoration(
  //     labelText: label,
  //     border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
  //     filled: true,
  //     fillColor: Colors.black,
  //   );
  // }
}
