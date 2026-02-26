import 'package:cheza_app/services/supabase_service_parties.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class SupabaseServicePlaces {
  ////////////////////////////////////
  static Future<int?> getMyPlaceId() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return null;

    final res = await Supabase.instance.client
        .from('admins')
        .select('place_id')
        .eq('id', user.id)
        .maybeSingle();

    return res?['place_id'] as int?;
  }

  ////////////////////////////////////
  static Future<Map<String, dynamic>?> fetchMyPlace() async {
    try {
      final placeId = await getMyPlaceId();
      if (placeId == null) return null;

      final place = await supabase
          .from('places')
          .select('id, name, address, photo_url')
          .eq('id', placeId)
          .single();

      return place;
    } catch (e) {
      print("❌ fetchMyPlace error: $e");
      return null;
    }
  }

  //////////////////////////////////////////////////
  static Future<int> fetchPresentClientCount() async {
    final partyId = await SupabaseServiceParties.getActivePartyId();
    if (partyId == null) return 0;

    final res = await supabase
        .from('parties_attandance')
        .select('id')
        .eq('party_id', partyId)
        .eq('is_present', true)
        .count(CountOption.exact);

    return res.count;
  }

  ////////////////////////////////////////////
  static Future<Map<String, dynamic>?> fetchMyPlaceDetails(int placeId) async {
    try {
      final res = await supabase
          .from('places')
          .select('''
          id,
          name,
          address,
          type_place,
          opened,
          photo_url,
          latitude,
          longitude,
          qr_code,
          country_id,
          country:country (
            name
          )
        ''')
          .eq('id', placeId)
          .maybeSingle();

      if (res == null) return null;

      res['country_name'] = res['country']?['name'];

      return res;
    } catch (e) {
      print("❌ fetchMyPlaceDetails error: $e");
      return null;
    }
  }

  ///////////////////////////////////////////////////////////////////
  static Future<bool> updatePlace({
    required int placeId,
    required String name,
    required String address,
    required String? typePlace,
    String? photoUrl,
    double? latitude,
    double? longitude,
  }) async {
    try {
      await supabase
          .from('places')
          .update({
            'name': name,
            'address': address,
            'photo_url': photoUrl,
            'latitude': latitude,
            'longitude': longitude,
            'type_place': typePlace,
          })
          .eq('id', placeId);

      return true;
    } catch (e) {
      print("❌ updatePlace error: $e");
      return false;
    }
  }

  ///////////////////////////////////////////////////////////////////////////////////////
  static Future<int?> getExistingPlaceId({
    required String name,
    required String address,
    required String country,
  }) async {
    try {
      final res = await supabase
          .from('places')
          .select('id')
          .eq('name', name)
          .eq('address', address)
          .eq('country', country)
          .maybeSingle();

      return res?['id'] as int?;
    } catch (e) {
      print("❌ getExistingPlaceId error: $e");
      return null;
    }
  }
}
