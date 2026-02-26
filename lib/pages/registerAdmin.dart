import 'dart:io';

import 'package:cheza_app/pages/login.dart';
import 'package:cheza_app/services/supabase_service_admin.dart';
import 'package:cheza_app/widgets/network_aware_wrapper.dart';
import 'package:cheza_app/widgets/temp_reigtore_place.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class RegisterAdminPage extends StatefulWidget {
  const RegisterAdminPage({super.key});

  @override
  State<RegisterAdminPage> createState() => _RegisterAdminPageState();
}

class _RegisterAdminPageState extends State<RegisterAdminPage> {
  final _formKey = GlobalKey<FormState>();

  final fullnameCtrl = TextEditingController();
  final usernameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final passConfirmCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final birthCtrl = TextEditingController();

  String? selectedGender;
  String? selectedType;
  String? selectedCountry; // pays de l’admin
  XFile? adminImage;

  bool isLoading = false;

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final img = await picker.pickImage(source: ImageSource.gallery);
    if (img != null) {
      setState(() => adminImage = img);
    }
  }

  Future<void> pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 20),
      firstDate: DateTime(1900),
      lastDate: DateTime(now.year - 18),
    );

    if (picked != null) {
      birthCtrl.text = "${picked.year}-${picked.month}-${picked.day}";
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return NetworkToastWrapper(
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0A0F),
        body: Stack(
          children: [
            /// IMAGE FULL
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
                                Expanded(flex: 5, child: _adminForm()),
                                const Spacer(),
                                Expanded(flex: 3, child: _uploadSection()),
                              ],
                            )
                          : _adminForm(isMobile: true),
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
      ),
    );
  }

  Widget _adminForm({bool isMobile = false}) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 600;

    return SizedBox(
      width: isDesktop ? 500 : double.infinity,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              "Créer un Administrateur",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 30),

            _field(fullnameCtrl, "Nom complet", true),
            const SizedBox(height: 10),

            _field(usernameCtrl, "Nom d’utilisateur", true),
            const SizedBox(height: 10),

            _field(emailCtrl, "Email", true),
            const SizedBox(height: 10),

            _field(
              passCtrl,
              "Mot de passe (min. 6 caractères)",
              true,
              isPassword: true,
            ),
            const SizedBox(height: 10),
            _field(
              passConfirmCtrl,
              "Confirme mot de passe",
              true,
              isPassword: true,
            ),
            const SizedBox(height: 10),

            _field(phoneCtrl, "Téléphone", true, type: TextInputType.phone),
            const SizedBox(height: 10),
            _typeAdminDropdown(),
            const SizedBox(height: 10),

            /// GENRE + PAYS RESPONSIVE
            if (isDesktop)
              Row(
                children: [
                  Expanded(child: _genderDropdown()),
                  const SizedBox(width: 20),
                  Expanded(child: _countryPicker()),
                ],
              )
            else
              Column(
                children: [
                  _genderDropdown(),
                  const SizedBox(height: 15),
                  _countryPicker(),
                ],
              ),

            const SizedBox(height: 20),

            _birthDateField(),

            const SizedBox(height: 20),
            if (isDesktop)
              _submitButton()
            else
              Row(
                children: [
                  Expanded(flex: 3, child: _submitButton()),
                  const SizedBox(width: 15),
                  Expanded(flex: 1, child: _uploadCircleMobile()),
                ],
              ),
          ],
        ),
      ),
    );
  }

  ////////////////////////////////////////////
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
          child: adminImage == null
              ? const Icon(Icons.camera_alt, color: Colors.white, size: 25)
              : Image.file(File(adminImage!.path), fit: BoxFit.cover),
        ),
      ),
    );
  }

  ///////////////////////////////////////////////////////
  Widget _genderDropdown() {
    return DropdownButtonFormField(
      value: selectedGender,
      style: const TextStyle(color: Colors.white),
      dropdownColor: const Color(0xFF1A1443),
      icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white70),
      decoration: _input("Genre"),
      items: const [
        DropdownMenuItem(value: "male", child: Text("Homme")),
        DropdownMenuItem(value: "female", child: Text("Femme")),
      ],
      onChanged: (v) => setState(() => selectedGender = v),
      validator: (v) => v == null ? "Sélectionner un genre" : null,
    );
  }

  Widget _typeAdminDropdown() {
    return DropdownButtonFormField(
      value: selectedType,
      style: const TextStyle(color: Colors.white),
      dropdownColor: const Color(0xFF1A1443),
      icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white70),
      decoration: _input("Type Admin"),
      items: const [
        DropdownMenuItem(value: "owner", child: Text("Owner")),
        DropdownMenuItem(value: "manager", child: Text("Manager")),
        DropdownMenuItem(value: "waiter", child: Text("Waiter")),
      ],
      onChanged: (v) => setState(() => selectedType = v),
      validator: (v) => v == null ? "Sélectionner un type" : null,
    );
  }

  Widget _countryPicker() {
    return GestureDetector(
      onTap: () {
        showCountryPicker(
          context: context,
          showPhoneCode: false,
          onSelect: (country) {
            setState(() => selectedCountry = country.name);
          },
        );
      },
      child: InputDecorator(
        decoration: _input("Pays (admin)"),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              selectedCountry ?? "Sélectionner un pays",
              style: TextStyle(
                color: selectedCountry == null ? Colors.grey : Colors.white,
              ),
            ),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }

  Widget _birthDateField() {
    return GestureDetector(
      onTap: pickBirthDate,
      child: AbsorbPointer(
        child: TextFormField(
          controller: birthCtrl,
          decoration: _input("Date de naissance (18+)"),
          validator: (v) =>
              v == null || v.isEmpty ? "Sélection obligatoire" : null,
        ),
      ),
    );
  }

  /////////////////////////////////////////////
  Widget _submitButton() {
    return Container(
      height: 60,
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
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        onPressed: isLoading
            ? null
            : () async {
                if (!_formKey.currentState!.validate()) {
                  return;
                }

                setState(() => isLoading = true);

                try {
                  if (passCtrl.text != passConfirmCtrl.text) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Mot passe incorrect")),
                    );
                  } else {
                    await SupabaseServiceAdmin.registerOwnerWithPlace(
                      email: emailCtrl.text,
                      password: passCtrl.text,
                      fullname: fullnameCtrl.text,
                      username: usernameCtrl.text,
                      phone: phoneCtrl.text,
                      gender: selectedGender!,
                      birthDate: birthCtrl.text,
                      adminCountry: selectedCountry!,
                      placeName: TempRegisterStore.placeName!,
                      placeAddress: TempRegisterStore.placeAddress!,
                      placeType: TempRegisterStore.placeType!,
                      placeCountry: TempRegisterStore.placeCountry!,
                      latitude: TempRegisterStore.latitude,
                      longitude: TempRegisterStore.longitude,
                      adminImage: adminImage,
                      placeImage: TempRegisterStore.placeImage,
                    );

                    TempRegisterStore.clear();

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginAdminPage()),
                    );
                  }
                } catch (e, s) {
                  debugPrint("❌ REGISTER ERROR = $e");
                  debugPrint("📌 STACK = $s");

                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(e.toString())));
                } finally {
                  if (mounted) {
                    setState(() => isLoading = false);
                  }
                }
              },

        child: isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text("Créer l’administrateur"),
      ),
    );
  }

  ///////////////////////////////////////
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
              child: adminImage == null
                  ? const Icon(Icons.camera_alt, color: Colors.white, size: 40)
                  : Image.file(File(adminImage!.path), fit: BoxFit.cover),
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

  Widget _field(
    TextEditingController ctrl,
    String label,
    bool required, {
    bool isPassword = false,
    TextInputType type = TextInputType.text,
  }) {
    return TextFormField(
      controller: ctrl,
      obscureText: isPassword,
      keyboardType: type,
      decoration: _input(label),
      validator: required
          ? (v) => v == null || v.isEmpty ? "Champ obligatoire" : null
          : null,
    );
  }

  InputDecoration _input(String label) {
    return InputDecoration(
      hintText: label,
      hintStyle: const TextStyle(color: Colors.white60),
      filled: true,
      fillColor: const Color(0xFF1A1443).withOpacity(0.6),
      contentPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 18),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(40),
        borderSide: const BorderSide(color: Color(0xFF6A5AE0), width: 1.2),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(40),
        borderSide: const BorderSide(color: Color(0xFFB44CFF), width: 2),
      ),
    );
  }
}
