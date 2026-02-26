import 'package:cheza_app/services/supabase_service_places.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class SupabaseServiceMenu {
  ////////////////////////////////////////////////
  static Future<List<Map<String, dynamic>>>
  fetchMenusForMyPlaceWithPlaceId() async {
    try {
      final placeId = await SupabaseServicePlaces.getMyPlaceId();
      if (placeId == null) return [];
      final res = await supabase
          .from('menu')
          .select('''
  id,
  name,
  created_at,
  menu_items (
    id,
    item_name,
    price
  )
''')
          .eq('place_id', placeId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      print("❌ fetchMenusForMyPlaceWithPlaceId error: $e");
      return [];
    }
  }

  ///////////////////////////////////////////////////
  static Future<bool> insertMenu({required String name}) async {
    try {
      final placeId = await SupabaseServicePlaces.getMyPlaceId();
      if (placeId == null) return false;

      await supabase.from('menu').insert({'place_id': placeId, 'name': name});

      return true;
    } catch (e) {
      print("❌ insertMenu error: $e");
      return false;
    }
  }

  //////////////////////////////////////////////////
  static Future<bool> updateMenu({
    required int menuId,
    required String name,
  }) async {
    try {
      await supabase.from('menu').update({'name': name}).eq('id', menuId);
      return true;
    } catch (e) {
      print("❌ updateMenu error: $e");
      return false;
    }
  }

  //////////////////////////////////////////////////////////
  static Future<bool> deleteMenu(int menuId) async {
    try {
      await supabase.from('menu').delete().eq('id', menuId);
      return true;
    } catch (e) {
      print("❌ deleteMenu error: $e");
      return false;
    }
  }

  ///////////////////////////////////
  static Future<List<Map<String, dynamic>>> fetchItemsForMenu(
    int menuId,
  ) async {
    try {
      final res = await supabase
          .from('menu_items')
          .select()
          .eq('menu_id', menuId)
          .order('created_at', ascending: true);

      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      print("❌ fetchItemsForMenu error: $e");
      return [];
    }
  }

  ////////////////////////////////////////
  static Future<bool> insertItem({
    required int menuId,
    required String name,
    required double price,
  }) async {
    try {
      await supabase.from('menu_items').insert({
        'menu_id': menuId,
        'item_name': name,
        'price': price,
      });

      return true;
    } catch (e) {
      print("❌ insertItem error: $e");
      return false;
    }
  }

  static Future<bool> updateItem({
    required int itemId,
    required String name,
    required double price,
  }) async {
    try {
      await supabase
          .from('menu_items')
          .update({'item_name': name, 'price': price})
          .eq('id', itemId);

      return true;
    } catch (e) {
      print("❌ updateItem error: $e");
      return false;
    }
  }

  //////////////////////////////////
  static Future<bool> deleteItem(int itemId) async {
    try {
      await supabase.from('menu_items').delete().eq('id', itemId);

      return true;
    } catch (e) {
      print("❌ deleteItem error: $e");
      return false;
    }
  }
}
