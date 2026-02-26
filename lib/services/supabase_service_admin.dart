import 'package:cheza_app/services/supabase_service_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class SupabaseServiceAdmin {
  // ============================================================
  //  REGISTER OWNER + PLACE (SAFE CLIENT VERSION)
  // ============================================================
  static Future<void> registerOwnerWithPlace({
    required String email,
    required String password,
    required String fullname,
    required String username,
    required String phone,
    required String gender,
    required String birthDate,
    required String adminCountry,
    required String placeName,
    required String placeAddress,
    required String placeType,
    required String placeCountry,
    double? latitude,
    double? longitude,
    XFile? adminImage,
    XFile? placeImage,
  }) async {
    final emailLower = email.trim().toLowerCase();

    // 1️⃣ AUTH
    final authRes = await supabase.auth.signUp(
      email: emailLower,
      password: password,
    );

    final user = authRes.user;
    if (user == null) {
      throw Exception("Création du compte échouée");
    }

    // 2️⃣ COUNTRIES
    final adminCountryId = await getOrCreateCountry(adminCountry);
    final placeCountryId = await getOrCreateCountry(placeCountry);

    // 3️⃣ PLACE
    final place = await supabase
        .from('places')
        .insert({
          'name': placeName,
          'address': placeAddress,
          'type_place': placeType,
          'country_id': placeCountryId,
          'opened': false,
          'latitude': latitude,
          'longitude': longitude,
        })
        .select('id')
        .single();

    final placeId = place['id'];

    // 4️⃣ PLACE IMAGE
    if (placeImage != null) {
      final url = await SupabaseServiceStorage.uploadImage(
        image: placeImage,
        bucketName: 'images/uploads',
        fileName: 'place_$placeId.jpg',
      );
      if (url != null) {
        await supabase
            .from('places')
            .update({'photo_url': url})
            .eq('id', placeId);
      }
    }

    // 5️⃣ ADMIN AVATAR
    String? avatarUrl;
    if (adminImage != null) {
      avatarUrl = await SupabaseServiceStorage.uploadImage(
        image: adminImage,
        bucketName: 'profile-image',
        fileName: 'admin_${user.id}.jpg',
      );
    }

    // 6️⃣ ADMIN INSERT (MANUEL, CONTRÔLÉ)
    await supabase.from('admins').insert({
      'id': user.id,
      'place_id': placeId,
      'country_id': adminCountryId,
      'fullname': fullname,
      'username': username,
      'email': emailLower,
      'phone': phone,
      'birth_date': birthDate,
      'gender': gender,
      'type_admin': 'owner',
      'image_url': avatarUrl,
      'is_active': true,
    });
  }

  ///////////////////////////////////////////////////////////////////
  static Future<int> getOrCreateCountry(String name) async {
    final existing = await supabase
        .from('country')
        .select('id')
        .eq('name', name)
        .maybeSingle();
    if (existing != null) {
      return existing['id'];
    }
    final res = await supabase
        .from('country')
        .insert({'name': name})
        .select('id')
        .single();
    return res['id'];
  }

  static Future<List<Map<String, dynamic>>> fetchAdminsForMyPlace(
    int placeId,
  ) async {
    try {
      final res = await supabase
          .from('admins')
          .select('''
          id,
          fullname,
          username,
          email,
          phone,
          gender,
          type_admin,
          image_url,
          is_active,
          created_at
        ''')
          .eq('place_id', placeId)
          .order('created_at', ascending: true);

      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      print("❌ fetchAdminsForMyPlace error: $e");
      return [];
    }
  }

  //////////////////////////////////////////////////////////////////////
  static Future<Map<String, dynamic>?> fetchMyAdminProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return null;

    final res = await supabase
        .from('admins')
        .select(
          'id, fullname, username, email, phone, gender, type_admin, image_url, place_id',
        )
        .eq('id', user.id)
        .maybeSingle();

    return res;
  }

  ///////////////////////////////////////////////////////////////////
  static Future<bool> updateMyAdminProfile({
    required String fullname,
    required String username,
    required String phone,
    required String gender,
    String? imageUrl, // optionnel
  }) async {
    try {
      final userId = supabase.auth.currentUser!.id;

      final Map<String, dynamic> updates = {
        'fullname': fullname,
        'username': username,
        'phone': phone,
        'gender': gender,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      };

      // AJOUTER SEULEMENT SI VALIDÉE
      if (imageUrl != null && imageUrl.isNotEmpty) {
        updates['image_url'] = imageUrl;
      }

      await supabase.from('admins').update(updates).eq('id', userId);

      return true;
    } catch (e) {
      print("❌ updateMyAdminProfile error: $e");
      return false;
    }
  }

  ///////////////////////////////////////////////////////////////////////////
  static Future<Map<String, dynamic>?> fetchMyAdminWithPlace() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return null;

      final res = await supabase
          .from('admins')
          .select('''
          id,
          fullname,
          username,
          email,
          phone,
          gender,
          type_admin,
          image_url,
          place:places (
            id,
            name,
            address,
            type_place,
            photo_url,
            latitude,
            longitude
          )
        ''')
          .eq('id', user.id)
          .maybeSingle();

      return res;
    } catch (e) {
      print("❌ fetchMyAdminWithPlace error: $e");
      return null;
    }
  }

  ///////////////////////////////////////////////////////////////////////
  static Future<void> updateMyEmail(String email) async {
    await supabase.auth.updateUser(UserAttributes(email: email));
  }

  //////////////////////////////////////////////////////////////////////
  static Future<void> updateMyPassword(String password) async {
    await supabase.auth.updateUser(UserAttributes(password: password));
  }

  ///////////////////////////////////////////////////////////////////////////////////////
  static Future<String?> createAdminAuth({
    required String email,
    required String password,
  }) async {
    try {
      final res = await supabase.auth.signUp(email: email, password: password);
      return res.user?.id;
    } catch (e) {
      print("❌ createAdminAuth error: $e");
      return null;
    }
  }

  ///////////////////////////////////////////////////////////
  static String? get currentUserEmail {
    return supabase.auth.currentUser?.email;
  }

  ////////////////////////////////////////////////////
  // static Future<String?> registerAdminAuth({
  //   required String email,
  //   required String password,
  // }) async {
  //   try {
  //     final res = await supabase.auth.signUp(email: email, password: password);
  //     return res.user?.id;
  //   } catch (e) {
  //     print("❌ registerAdminAuth error: $e");
  //     return null;
  //   }
  // }

  ////////////////////////////////////////////////////////////////////////////
  static Future<bool> insertAdmin({
    required String userId,
    required int placeId,
    required String fullname,
    required String username,
    required String email,
    required String phone,
    required String gender,
    required String typeAdmin,
    required int countryId,
    required String birthDate,
    String? imageUrl,
  }) async {
    try {
      await supabase.from('admins').insert({
        'id': userId,
        'place_id': placeId,
        'country_id': countryId,
        'fullname': fullname,
        'username': username,
        'email': email,
        'phone': phone,
        'birth_date': birthDate, // yyyy-MM-dd
        'gender': gender,
        'type_admin': typeAdmin, // waiter | manager
        'image_url': imageUrl,
        'is_active': true,
      });

      return true;
    } catch (e) {
      print("❌ insertAdmin error: $e");
      return false;
    }
  }

  ///////////////////////////////////////////////////////
  static Future<int?> getCountryIdByName(String countryName) async {
    try {
      final res = await supabase
          .from('country')
          .select('id')
          .eq('name', countryName)
          .maybeSingle();

      if (res == null) {
        print("❌ Pays introuvable: $countryName");
        return null;
      }

      return res['id'] as int;
    } catch (e) {
      print("❌ getCountryIdByName error: $e");
      return null;
    }
  }

  ///////////////////////////////////////////////////////////////////////
  static Future<bool> setAdminStatus({
    required String adminId,
    required bool isActive,
  }) async {
    try {
      await supabase
          .from('admins')
          .update({'is_active': isActive})
          .eq('id', adminId);

      return true;
    } catch (e) {
      print("❌ setAdminStatus error: $e");
      return false;
    }
  }
}
