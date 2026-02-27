import 'package:cheza_app/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:cheza_app/services/supabase_service_places.dart';
import 'package:cheza_app/services/supabase_service_storage.dart';
import 'package:cheza_app/themes/app_colors.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../services/supabase_service_admin.dart';

class SettingsTab extends ConsumerStatefulWidget {
  const SettingsTab({super.key});

  @override
  ConsumerState<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends ConsumerState<SettingsTab> {
  bool loading = true;
  bool imageSaving = false;

  Map<String, dynamic>? admin;
  Map<String, dynamic>? place;
  List<Map<String, dynamic>> admins = [];
  final placeTypes = [
    "Bar",
    "Club",
    "Lounge",
    "Restaurant",
    "Lounge/Club",
    "Lounge/Restaurant",
  ];
  String? selectedType;
  // AJOUT (preview images)
  String? _tempAdminImage;

  String? _tempPlaceImage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  ///////////////////////////////////////////////////
  Future<void> _loadData() async {
    try {
      setState(() => loading = true);

      admin = await SupabaseServiceAdmin.fetchMyAdminProfile();
      if (admin == null || admin!['place_id'] == null) {
        throw Exception("Admin ou place_id introuvable");
      }

      place = await SupabaseServicePlaces.fetchMyPlaceDetails(
        admin!['place_id'],
      );

      admins = await SupabaseServiceAdmin.fetchAdminsForMyPlace(
        admin!['place_id'],
      );
    } catch (e) {
      debugPrint("❌ SETTINGS LOAD ERROR: $e");
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  // ================= PICK IMAGE ADMIN =================
  Future<void> _pickAdminImage() async {
    if (admin == null || admin!['id'] == null) return;

    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    final user = Supabase.instance.client.auth.currentUser;
    bool processing = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Confirmer la photo"),
              content: processing
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        SizedBox(height: 12),
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text("Mise à jour de la photo…"),
                      ],
                    )
                  : const Text(
                      "Voulez-vous utiliser cette image comme photo de profil ?",
                    ),
              actions: processing
                  ? []
                  : [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Annuler"),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          setDialogState(() => processing = true);

                          try {
                            // 1️⃣ UPLOAD IMAGE
                            final url = await SupabaseServiceStorage.uploadImage(
                              image: image,
                              bucketName: 'profile-image',
                              fileName:
                                  '${user!.id}/profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
                            );

                            if (url == null) {
                              throw Exception("Upload échoué");
                            }

                            // 2️⃣ SAUVEGARDE EN BASE
                            final success =
                                await SupabaseServiceAdmin.updateMyAdminProfile(
                                  fullname: admin!['fullname'],
                                  username: admin!['username'],
                                  phone: admin!['phone'] ?? '',
                                  gender: admin!['gender'] ?? 'male',
                                  imageUrl: url,
                                );

                            if (!success) {
                              throw Exception("Sauvegarde échouée");
                            }

                            if (!mounted) return;

                            // MAJ UI
                            setState(() {
                              _tempAdminImage = url;
                              admin!['image_url'] = url;
                            });

                            Navigator.pop(context); // fermer dialog
                          } catch (e) {
                            debugPrint("❌ _pickAdminImage error: $e");

                            if (mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Erreur réseau. Vérifiez votre connexion.",
                                  ),
                                ),
                              );
                            }
                          }
                        },
                        child: const Text("Confirmer"),
                      ),
                    ],
            );
          },
        );
      },
    );
  }

  // ================= PICK IMAGE PLACE =================
  Future<void> _pickPlaceImage() async {
    if (place == null || place!['id'] == null) return;

    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (image == null) return;

    bool processing = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Confirmer la photo du lieu"),
              content: processing
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        SizedBox(height: 12),
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text("Mise à jour de la photo du lieu…"),
                      ],
                    )
                  : const Text(
                      "Voulez-vous utiliser cette image comme photo du lieu ?",
                    ),
              actions: processing
                  ? []
                  : [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Annuler"),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          setDialogState(() => processing = true);

                          try {
                            // 1️⃣ UPLOAD IMAGE
                            final url = await SupabaseServiceStorage.uploadImage(
                              image: image,
                              bucketName: 'images/uploads',
                              fileName:
                                  'place_${place!['id']}_${DateTime.now().millisecondsSinceEpoch}.jpg',
                            );

                            if (url == null) {
                              throw Exception("Upload échoué");
                            }

                            // 2️⃣ SAUVEGARDE EN BASE
                            final success =
                                await SupabaseServicePlaces.updatePlace(
                                  placeId: place!['id'],
                                  name: place!['name'],
                                  address: place!['address'],
                                  photoUrl: url,
                                  typePlace: place!['type_place'],
                                  latitude: (place!['latitude'] as num?)
                                      ?.toDouble(),
                                  longitude: (place!['longitude'] as num?)
                                      ?.toDouble(),
                                );

                            if (!success) {
                              throw Exception("Sauvegarde échouée");
                            }

                            if (!mounted) return;

                            // 3️⃣ MAJ UI LOCALE
                            setState(() {
                              _tempPlaceImage = url;
                              place!['photo_url'] = url;
                            });

                            // 4️⃣ MAJ GLOBALE (HEADER / SIDEBAR)
                            ref.read(placePhotoProvider.notifier).state = url;

                            Navigator.pop(context);
                          } catch (e) {
                            debugPrint("❌ _pickPlaceImage error: $e");

                            if (mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Erreur réseau. Vérifiez votre connexion.",
                                  ),
                                ),
                              );
                            }
                          }
                        },
                        child: const Text("Confirmer"),
                      ),
                    ],
            );
          },
        );
      },
    );
  }

  // ================= EDIT ADMIN =================
  Future<void> _openEditAdminDialog() async {
    final fullnameCtrl = TextEditingController(text: admin!['fullname'] ?? '');
    final usernameCtrl = TextEditingController(text: admin!['username'] ?? '');
    final phoneCtrl = TextEditingController(text: admin!['phone'] ?? '');
    String gender = admin!['gender'] ?? 'male';

    bool saving = false;

    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setLocal) {
          return AlertDialog(
            title: const Text("Modifier le profil"),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: fullnameCtrl,
                    decoration: const InputDecoration(labelText: "Nom complet"),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: usernameCtrl,
                    decoration: const InputDecoration(
                      labelText: "Nom d'utilisateur",
                    ),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: phoneCtrl,
                    decoration: const InputDecoration(labelText: "Téléphone"),
                  ),
                  SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: gender,
                    items: const [
                      DropdownMenuItem(value: "male", child: Text("Homme")),
                      DropdownMenuItem(value: "female", child: Text("Femme")),
                    ],
                    onChanged: (v) => gender = v!,
                    decoration: const InputDecoration(labelText: "Genre"),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Annuler"),
              ),
              ElevatedButton(
                onPressed: saving
                    ? null
                    : () async {
                        setLocal(() => saving = true);

                        await SupabaseServiceAdmin.updateMyAdminProfile(
                          fullname: fullnameCtrl.text.trim(),
                          username: usernameCtrl.text.trim(),
                          phone: phoneCtrl.text.trim(),
                          gender: gender,
                          imageUrl: _tempAdminImage,
                        );

                        _tempAdminImage = null;
                        Navigator.pop(context);
                        _loadData();
                      },
                child: saving
                    ? const CircularProgressIndicator(strokeWidth: 2)
                    : const Text("Valider"),
              ),
            ],
          );
        },
      ),
    );
  }

  // ================= SECURITY =================
  Future<void> _openSecurityDialog() async {
    final emailCtrl = TextEditingController(
      text: SupabaseServiceAdmin.currentUserEmail,
    );
    final ancienPassCtrl = TextEditingController();
    final nouveauPassCtrl = TextEditingController();
    final confPassCtrl = TextEditingController();

    bool saving = false;

    // VISIBILITÉ MOT DE PASSE
    bool showOldPass = false;
    bool showNewPass = false;
    bool showConfPass = false;

    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setLocal) {
          return AlertDialog(
            title: const Text("Sécurité du compte"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// EMAIL
                  TextField(
                    controller: emailCtrl,
                    decoration: const InputDecoration(
                      labelText: "Nouvel email",
                    ),
                  ),

                  const SizedBox(height: 8),

                  /// ANCIEN MOT DE PASSE
                  TextField(
                    controller: ancienPassCtrl,
                    obscureText: !showOldPass,
                    decoration: InputDecoration(
                      labelText: "Ancien mot de passe",
                      suffixIcon: IconButton(
                        icon: Icon(
                          showOldPass ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setLocal(() => showOldPass = !showOldPass);
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  /// NOUVEAU MOT DE PASSE
                  TextField(
                    controller: nouveauPassCtrl,
                    obscureText: !showNewPass,
                    decoration: InputDecoration(
                      labelText: "Nouveau mot de passe",
                      suffixIcon: IconButton(
                        icon: Icon(
                          showNewPass ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setLocal(() => showNewPass = !showNewPass);
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  /// CONFIRMATION MOT DE PASSE
                  TextField(
                    controller: confPassCtrl,
                    obscureText: !showConfPass,
                    decoration: InputDecoration(
                      labelText: "Confirmer le mot de passe",
                      suffixIcon: IconButton(
                        icon: Icon(
                          showConfPass
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setLocal(() => showConfPass = !showConfPass);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            /// ACTIONS
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Annuler"),
              ),
              ElevatedButton(
                onPressed: saving
                    ? null
                    : () async {
                        setLocal(() => saving = true);

                        /// UPDATE EMAIL
                        if (emailCtrl.text.trim().isNotEmpty) {
                          await SupabaseServiceAdmin.updateMyEmail(
                            emailCtrl.text.trim(),
                          );
                        }

                        /// UPDATE PASSWORD
                        if (ancienPassCtrl.text.isNotEmpty &&
                            nouveauPassCtrl.text.isNotEmpty &&
                            confPassCtrl.text.isNotEmpty) {
                          if (nouveauPassCtrl.text != confPassCtrl.text) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Les mots de passe ne correspondent pas",
                                ),
                              ),
                            );
                            setLocal(() => saving = false);
                            return;
                          }

                          await SupabaseServiceAdmin.updateMyPassword(
                            confPassCtrl.text.trim(),
                          );
                        }

                        Navigator.pop(context);
                      },
                child: saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text("Valider"),
              ),
            ],
          );
        },
      ),
    );
  }

  // ================= EDIT PLACE =================
  Future<void> _openEditPlaceDialog() async {
    final nameCtrl = TextEditingController(text: place!['name'] ?? '');
    final addressCtrl = TextEditingController(text: place!['address'] ?? '');
    final latitudeCtrl = TextEditingController(
      text: place!['latitude']?.toString() ?? '',
    );
    final longitudeCtrl = TextEditingController(
      text: place!['longitude']?.toString() ?? '',
    );

    String? localType = place!['type_place']; //INITIALISATION

    bool saving = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => StatefulBuilder(
        builder: (context, setLocal) {
          return AlertDialog(
            title: const Text("Modifier le lieu"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: "Nom du lieu"),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: addressCtrl,
                    decoration: const InputDecoration(labelText: "Adresse"),
                  ),
                  const SizedBox(height: 8),

                  // TYPE DE LIEU
                  DropdownButtonFormField<String>(
                    value: localType,
                    decoration: _input("Type de lieu"),
                    items: placeTypes
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: saving
                        ? null
                        : (v) => setLocal(() => localType = v),
                  ),

                  const SizedBox(height: 8),
                  TextField(
                    controller: latitudeCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(labelText: "Latitude"),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: longitudeCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(labelText: "Longitude"),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: saving ? null : () => Navigator.pop(context),
                child: const Text("Annuler"),
              ),
              ElevatedButton(
                onPressed: saving
                    ? null
                    : () async {
                        setLocal(() => saving = true);

                        try {
                          final success =
                              await SupabaseServicePlaces.updatePlace(
                                placeId: place!['id'],
                                name: nameCtrl.text.trim(),
                                address: addressCtrl.text.trim(),
                                photoUrl: _tempPlaceImage,
                                latitude: double.tryParse(latitudeCtrl.text),
                                longitude: double.tryParse(longitudeCtrl.text),
                                typePlace: localType, //IMPORTANT
                              );

                          if (!success) {
                            throw Exception("Échec de la mise à jour");
                          }

                          if (!mounted) return;

                          // ✅ MAJ LOCALE IMMÉDIATE
                          setState(() {
                            place!['name'] = nameCtrl.text.trim();
                            place!['address'] = addressCtrl.text.trim();
                            place!['latitude'] = double.tryParse(
                              latitudeCtrl.text,
                            );
                            place!['longitude'] = double.tryParse(
                              longitudeCtrl.text,
                            );
                            place!['type_place'] = localType;
                            if (_tempPlaceImage != null) {
                              place!['photo_url'] = _tempPlaceImage;
                            }
                          });

                          _tempPlaceImage = null;
                          Navigator.pop(context);
                        } catch (e) {
                          debugPrint("❌ update place error: $e");
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Erreur lors de la mise à jour du lieu",
                              ),
                            ),
                          );
                          setLocal(() => saving = false);
                        }
                      },
                child: saving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text("Valider"),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _openAddAdminDialog() async {
    final fullnameCtrl = TextEditingController();
    final usernameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final birthCtrl = TextEditingController();

    String role = "waiter";
    String? selectedGender;
    String? selectedCountry;

    bool saving = false;
    bool showPassword = false;
    bool uploadingImage = false;
    String? avatarUrl;

    await showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setLocal) {
            return AlertDialog(
              title: const Text("Ajouter un administrateur"),

              /// 👉 AGRANDISSEMENT
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      /// 📸 PHOTO DE PROFIL (ANTI-CRASH)
                      GestureDetector(
                        onTap: uploadingImage
                            ? null
                            : () async {
                                try {
                                  final picker = ImagePicker();
                                  final image = await picker.pickImage(
                                    source: ImageSource.gallery,
                                    imageQuality: 70,
                                    maxWidth: 800,
                                  );

                                  if (image == null) return;

                                  setLocal(() => uploadingImage = true);

                                  final url =
                                      await SupabaseServiceStorage.uploadImage(
                                        image: image,
                                        bucketName: 'avatars',
                                        fileName:
                                            'admin_${DateTime.now().millisecondsSinceEpoch}.jpg',
                                      );

                                  if (url != null && url.startsWith('http')) {
                                    setLocal(() => avatarUrl = url);
                                  }
                                } catch (e) {
                                  debugPrint("❌ Image upload error: $e");

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Erreur lors de l’ajout de la photo",
                                      ),
                                    ),
                                  );
                                } finally {
                                  setLocal(() => uploadingImage = false);
                                }
                              },
                        child: CircleAvatar(
                          radius: 45,
                          backgroundColor: Colors.grey.shade800,
                          child:
                              avatarUrl != null && avatarUrl!.startsWith('http')
                              ? ClipOval(
                                  child: Image.network(
                                    avatarUrl!,
                                    width: 90,
                                    height: 90,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) {
                                      return const Icon(Icons.person, size: 40);
                                    },
                                  ),
                                )
                              : uploadingImage
                              ? const CircularProgressIndicator()
                              : const Icon(Icons.camera_alt, size: 30),
                        ),
                      ),
                      const SizedBox(height: 16),

                      _field(fullnameCtrl, "Nom complet", true),
                      const SizedBox(height: 12),

                      _field(usernameCtrl, "Nom d’utilisateur", true),
                      const SizedBox(height: 12),

                      TextFormField(
                        controller: emailCtrl,
                        decoration: _input("Email"),
                      ),
                      const SizedBox(height: 12),

                      /// 👁️ MOT DE PASSE
                      TextField(
                        controller: passCtrl,
                        obscureText: !showPassword,
                        decoration: _input("Mot de passe (min. 6 caractères)")
                            .copyWith(
                              suffixIcon: IconButton(
                                icon: Icon(
                                  showPassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setLocal(() => showPassword = !showPassword);
                                },
                              ),
                            ),
                      ),
                      const SizedBox(height: 12),

                      _field(
                        phoneCtrl,
                        "Téléphone",
                        true,
                        type: TextInputType.phone,
                      ),
                      const SizedBox(height: 12),

                      /// GENRE
                      DropdownButtonFormField<String>(
                        value: selectedGender,
                        decoration: _input("Genre"),
                        items: const [
                          DropdownMenuItem(value: "male", child: Text("Homme")),
                          DropdownMenuItem(
                            value: "female",
                            child: Text("Femme"),
                          ),
                        ],
                        onChanged: (v) => setLocal(() => selectedGender = v),
                      ),
                      const SizedBox(height: 12),

                      /// PAYS
                      GestureDetector(
                        onTap: () {
                          showCountryPicker(
                            context: context,
                            showPhoneCode: false,
                            onSelect: (country) {
                              setLocal(() {
                                selectedCountry = country.name;
                              });
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
                                  color: selectedCountry == null
                                      ? Colors.grey
                                      : Colors.white,
                                ),
                              ),
                              const Icon(Icons.arrow_drop_down),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      /// DATE NAISSANCE
                      GestureDetector(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now().subtract(
                              const Duration(days: 6570),
                            ),
                            firstDate: DateTime(1950),
                            lastDate: DateTime.now().subtract(
                              const Duration(days: 6570),
                            ),
                          );
                          if (picked != null) {
                            setLocal(() {
                              birthCtrl.text =
                                  "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                            });
                          }
                        },
                        child: AbsorbPointer(
                          child: TextField(
                            controller: birthCtrl,
                            decoration: _input("Date de naissance (18+)"),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      /// ROLE
                      DropdownButtonFormField<String>(
                        value: role,
                        decoration: _input("Rôle"),
                        items: const [
                          DropdownMenuItem(
                            value: "waiter",
                            child: Text("Waiter"),
                          ),
                          DropdownMenuItem(
                            value: "manager",
                            child: Text("Manager"),
                          ),
                        ],
                        onChanged: (v) => role = v!,
                      ),
                    ],
                  ),
                ),
              ),

              /// ACTIONS
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Annuler"),
                ),
                ElevatedButton(
                  onPressed: saving
                      ? null
                      : () async {
                          setLocal(() => saving = true);

                          // VALIDATION
                          if (fullnameCtrl.text.isEmpty ||
                              usernameCtrl.text.isEmpty ||
                              emailCtrl.text.isEmpty ||
                              passCtrl.text.length < 6 ||
                              phoneCtrl.text.isEmpty ||
                              selectedGender == null ||
                              selectedCountry == null ||
                              birthCtrl.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Veuillez remplir tous les champs obligatoires",
                                ),
                              ),
                            );
                            setLocal(() => saving = false);
                            return;
                          }

                          final countryId =
                              await SupabaseServiceAdmin.getCountryIdByName(
                                selectedCountry!,
                              );

                          if (countryId == null) {
                            setLocal(() => saving = false);
                            return;
                          }

                          try {
                            // APPEL EDGE FUNCTION
                            final res = await Supabase.instance.client.functions
                                .invoke(
                                  'dynamic-function',
                                  body: {
                                    'email': emailCtrl.text
                                        .trim()
                                        .toLowerCase(),
                                    'password': passCtrl.text,
                                    'fullname': fullnameCtrl.text.trim(),
                                    'username': usernameCtrl.text.trim(),
                                    'phone': phoneCtrl.text.trim(),
                                    'gender': selectedGender,
                                    'birth_date': birthCtrl.text,
                                    'country_id': countryId,
                                    'type_admin': role, // waiter | manager
                                    'place_id': admin!['place_id'],
                                    'image_url': avatarUrl,
                                  },
                                );

                            if (res.status != 200) {
                              throw Exception(res.data);
                            }

                            Navigator.pop(context);
                            _loadData(); // RESTE SUR SETTINGS + refresh liste
                          } catch (e) {
                            debugPrint("❌ create-admin error: $e");
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Erreur lors de l’ajout de l’administrateur",
                                ),
                              ),
                            );
                          } finally {
                            setLocal(() => saving = false);
                          }
                        },
                  child: saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text("Ajouter"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (admin == null || place == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Erreur de chargement des paramètres",
              style: TextStyle(color: Colors.grey, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            IconButton(
              icon: const Icon(Icons.refresh, size: 28),
              color: Colors.white,
              tooltip: "Rafraîchir",
              onPressed: () {
                _loadData();
              },
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Paramètres",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 24),

          // ================= PROFIL ADMIN =================
          _sectionTitle("Profil Administrateur"),
          _card(
            child: Column(
              children: [
                _avatarRow(
                  title: "Photo de profil",
                  subtitle: "Modifier votre photo",
                  icon: Icons.person,
                  imageUrl: _tempAdminImage ?? admin!['image_url'],
                  onEdit: _pickAdminImage,
                ),

                const Divider(),
                _infoRow("Nom complet", admin!['fullname'] ?? ""),
                _infoRow("Nom d'utilisateur", admin!['username'] ?? ""),
                _infoRow(
                  "Email",
                  admin!['email'] ??
                      SupabaseServiceAdmin.currentUserEmail ??
                      "",
                  disabled: true,
                ),
                _infoRow("Téléphone", admin!['phone'] ?? ""),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _primaryButton(
                      "Modifier le profil",
                      onPressed: _openEditAdminDialog,
                    ),
                    _primaryButton(
                      "Email / Mot de passe",
                      onPressed: _openSecurityDialog,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // ================= INFORMATIONS LIEU =================
          _sectionTitle("Informations du lieu"),
          _card(
            child: Column(
              children: [
                _avatarRow(
                  title: "Photo du lieu",
                  subtitle: "Modifier la photo du lieu",
                  icon: Icons.store,
                  imageUrl: _tempPlaceImage ?? place!['photo_url'],
                  onEdit: _pickPlaceImage,
                  isLieu: true,
                ),
                const Divider(),
                _infoRow("Nom du lieu", place!['name'] ?? ""),
                _infoRow("Adresse", place!['address'] ?? ""),
                _infoRow("Type", place!['type_place'] ?? ""),
                // _infoRow("Latitude", place!['latitude'].toString() ?? ""),
                // _infoRow("Longitude", place!['longitude'].toString() ?? ""),
                _infoRow(
                  "Latitude",
                  place!['latitude'] != null
                      ? place!['latitude'].toString()
                      : "Non défini",
                ),
                _infoRow(
                  "Longitude",
                  place!['longitude'] != null
                      ? place!['longitude'].toString()
                      : "Non défini",
                ),
                _primaryButton(
                  "Modifier le lieu",
                  onPressed: _openEditPlaceDialog,
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // ================= ADMINS =================
          _sectionTitle("Administrateurs"),
          _card(
            child: Column(
              children: [
                ...admins.map(
                  (a) => _adminCard(
                    name: a['fullname'] ?? '',
                    role: a['type_admin'] ?? '',
                    email: a['email'] ?? '',
                    imageUrl: a['image_url'],
                  ),
                ),
                const SizedBox(height: 12),
                if (admin!['type_admin'] == 'Owner')
                  _secondaryButton(
                    icon: Icons.person_add,
                    label: "Ajouter un administrateur",
                    onPressed: _openAddAdminDialog,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= UI COMPONENTS =================

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }

  Widget _infoRow(String label, String value, {bool disabled = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              value,
              style: TextStyle(
                color: disabled ? Colors.grey : Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatarRow({
    required String title,
    required String subtitle,
    required IconData icon,
    String? imageUrl,
    VoidCallback? onEdit,
    bool isLieu = false, // 👈 nouveau paramètre
  }) {
    return Row(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            isLieu
                // 🔹 IMAGE RECTANGULAIRE POUR LIEU
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 52,
                      height: 52,
                      color: Colors.grey.shade700,
                      child: imageUrl != null
                          ? Image.network(imageUrl, fit: BoxFit.cover)
                          : Icon(icon, color: Colors.white),
                    ),
                  )
                // 🔹 CIRCLE POUR PROFIL
                : CircleAvatar(
                    radius: 26,
                    backgroundColor: Colors.grey.shade700,
                    backgroundImage: imageUrl != null
                        ? NetworkImage(imageUrl)
                        : null,
                    child: imageUrl == null
                        ? Icon(icon, color: Colors.white)
                        : null,
                  ),

            if (imageSaving)
              const SizedBox(
                width: 26,
                height: 26,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 15),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
              ),
            ],
          ),
        ),
        IconButton(
          icon: Icon(Icons.edit, color: Colors.grey.shade400),
          onPressed: onEdit,
        ),
      ],
    );
  }

  Widget _adminCard({
    required String name,
    required String role,
    required String email,
    String? imageUrl,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.blueGrey,
            backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
            child: imageUrl == null ? const Icon(Icons.person) : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "$role • $email",
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                ),
              ],
            ),
          ),
          Icon(Icons.more_vert, color: Colors.grey.shade400),
        ],
      ),
    );
  }

  Widget _primaryButton(String label, {VoidCallback? onPressed}) {
    return SizedBox(
      width: 150,
      child: ElevatedButton(onPressed: onPressed, child: Text(label)),
    );
  }

  Widget _secondaryButton({
    required IconData icon,
    required String label,
    VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
      ),
    );
  }

  InputDecoration _input(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.black,
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
}
