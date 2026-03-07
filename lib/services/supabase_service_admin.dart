import 'package:cheza_app/services/supabase_service_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class SupabaseServiceAdmin {
  // ============================================================
  //  REGISTER OWNER + PLACE (SAFE CLIENT VERSION)
  // ============================================================
  static Future<void> registerOwner({
    required String email,
    required String password,
    required String fullname,
    required String username,
    required String phone,
    required String gender,
    required String birthDate,
    required String adminCountry,

    XFile? adminImage,
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
          .from('admins_place')
          .select('''
       admin:admins(
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
          )
        ''')
          .eq('place_id', placeId)
          .eq('active', true)
          .order('created_at', ascending: true);

      final rows = List<Map<String, dynamic>>.from(res);
      return rows
          .map((row) => Map<String, dynamic>.from(row['admin'] ?? const {}))
          .where((admin) => admin.isNotEmpty)
          .toList();
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

      final links = await supabase
          .from('admins_place')
          .select('''
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
          .eq('admin_id', user.id)
          .eq('active', true)
          .limit(1)
          .maybeSingle();

      final admin = await supabase
          .from('admins')
          .select('''
          id,
          fullname,
          username,
          email,
          phone,
          gender,
          type_admin,
          image_url
        ''')
          .eq('id', user.id)
          .maybeSingle();

      if (admin == null) return null;

      return {...admin, 'place': links?['place']};
    } catch (e) {
      print("❌ fetchMyAdminWithPlace error: $e");
      return null;
    }
  }

  //////////////////////////////
  static Future<int?> getCountryIdByName(String name) async {
    try {
      final res = await supabase
          .from('country')
          .select('id')
          .eq('name', name)
          .maybeSingle();

      return res?['id'];
    } catch (e) {
      print("❌ getCountryIdByName error: $e");
      return null;
    }
  }

  /////////////////////////////
  static String? get currentUserEmail {
    return supabase.auth.currentUser?.email;
  }

  ///////////////////////
  static Future<bool> updateMyEmail(String email) async {
    try {
      await supabase.auth.updateUser(
        UserAttributes(email: email.trim().toLowerCase()),
      );
      return true;
    } catch (e) {
      print("❌ updateMyEmail error: $e");
      return false;
    }
  }

  // /////////////////
  static Future<bool> updateMyPassword(String newPassword) async {
    try {
      await supabase.auth.updateUser(UserAttributes(password: newPassword));
      return true;
    } catch (e) {
      print("❌ updateMyPassword error: $e");
      return false;
    }
  }

  ///////////////////////////////////////////////////////////////////////
  static Future<List<Map<String, dynamic>>> fetchMyPlaces() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return [];

      final rows = await supabase
          .from('admins_place')
          .select('''
            id,
            active,
            date_start,
            date_end,
            place:places(
              id,
              name,
              address,
              type_place,
              photo_url,
              opened
            )
          ''')
          .eq('admin_id', user.id)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(rows);
    } catch (e) {
      print("❌ fetchMyPlaces error: $e");
      return [];
    }
  }

  ///////////////////////////////////////////////////////////////////////////////////////
  static Future<int?> createPlaceForCurrentAdmin({
    required String name,
    required String address,
    required String typePlace,
    required String countryName,
    double? latitude,
    double? longitude,
    XFile? image,
  }) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return null;

      final countryId = await getOrCreateCountry(countryName);

      final place = await supabase
          .from('places')
          .insert({
            'name': name,
            'address': address,
            'type_place': typePlace,
            'country_id': countryId,
            'opened': false,
            'latitude': latitude,
            'longitude': longitude,
          })
          .select('id')
          .single();

      final placeId = place['id'] as int;

      if (image != null) {
        final url = await SupabaseServiceStorage.uploadImage(
          image: image,
          bucketName: 'images/uploads',
          fileName:
              'place_${placeId}_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
        if (url != null) {
          await supabase
              .from('places')
              .update({'photo_url': url})
              .eq('id', placeId);
        }
      }

      await supabase.from('admins_place').insert({
        'admin_id': user.id,
        'place_id': placeId,
        'active': true,
        'date_start': DateTime.now().toUtc().toIso8601String(),
      });

      return placeId;
    } catch (e) {
      print("❌ createPlaceForCurrentAdmin error: $e");
      return null;
    }
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
  static Future<bool> assignAdminToPlace({
    required String adminId,

    required int placeId,
    bool active = true,
  }) async {
    try {
      await supabase.from('admins_place').insert({
        'admin_id': adminId,
        'place_id': placeId,
        'active': active,
        'date_start': DateTime.now().toUtc().toIso8601String(),
      });

      return true;
    } catch (e) {
      print("❌ insertAdminToPlce error: $e");
      return false;
    }
  }

  ///////////////////////////////////////////////////////
  static Future<bool> setActivePlaceForCurrentAdmin(int placeId) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return false;

      await supabase
          .from('admins_place')
          .update({
            'active': false,
            'date_end': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('admin_id', user.id)
          .eq('active', true);

      await supabase
          .from('admins_place')
          .update({
            'active': true,
            'date_start': DateTime.now().toUtc().toIso8601String(),
            'date_end': null,
          })
          .eq('admin_id', user.id)
          .eq('place_id', placeId);

      await supabase
          .from('admins')
          .update({'place_id': placeId})
          .eq('id', user.id);
      return true;
    } catch (e) {
      print("❌ setActivePlaceForCurrentAdmin error: $e");
      return false;
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
