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
        .select('id,menu_name,place_id')
        .eq('place_id', placeId)
        .order('menu_name', ascending: true);

    return List<Map<String, dynamic>>.from(response);
  }
}
