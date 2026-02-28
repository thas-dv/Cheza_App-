import 'package:supabase_flutter/supabase_flutter.dart';

class MenusSupabaseDataSource {
  MenusSupabaseDataSource({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<List<Map<String, dynamic>>> fetchMenusByPlace({
    required int placeId,
  }) async {
    final response = await _client
        .from('menu')
        .select('*')
        .eq('place_id', placeId)
        .order('name', ascending: true);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> fetchMenuItemsByMenu({
    required int menuId,
  }) async {
    final items = await _client
        .from('menu_items')
        .select('id,item_name,price,menu_id')
        .eq('menu_id', menuId)
        .order('item_name', ascending: true);

    return List<Map<String, dynamic>>.from(items);
  }
}
