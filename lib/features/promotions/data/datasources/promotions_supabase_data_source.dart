import 'package:supabase_flutter/supabase_flutter.dart';

class PromotionsSupabaseDataSource {
  PromotionsSupabaseDataSource({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<int> createPromo({
    required String description,
    required bool unlimited,
    int? limit,
    required DateTime dateStart,
    required DateTime dateEnd,
  }) async {
    final promo = await _client
        .from('promos')
        .insert({
          'promo_desc': description,
          'unlimited': unlimited,
          'limite': unlimited ? null : limit,
          'date_start': dateStart.toIso8601String(),
          'date_end': dateEnd.toIso8601String(),
        })
        .select('id')
        .single();

    return promo['id'] as int;
  }

  Future<void> addPromoItem({
    required int promoId,
    required int itemId,
    required bool isFreeOffer,
    String? discountType,
    double? discountValue,
  }) async {
    await _client.from('promo_items').insert({
      'promo_id': promoId,
      'menu_item_id': itemId,
      'is_free': isFreeOffer,
      'discount_type': isFreeOffer ? null : discountType,
      'discount_value': isFreeOffer ? null : discountValue,
    });
  }

  Future<void> attachPromoToParty({
    required int promoId,
    required int partyId,
  }) async {
    await _client.from('promo_party').insert({
      'promo_id': promoId,
      'party_id': partyId,
    });
  }

  Future<List<Map<String, dynamic>>> loadPromos({required int partyId}) async {
 

    final promos = await _client
        .from('promos')
       
        .select('''
          id,
          promo_desc,
          unlimited,
          limite,
          date_start,
          date_end,
          promo_party!inner(party_id),
          promo_items (
            id,
            promo_id,
            menu_item_id,
            is_free,
            discount_type,
            discount_value,
            menu_items (
              id,
              item_name,
              price
            )
          )
        ''')
        .eq('promo_party.party_id', partyId)
        .order('date_start', ascending: false);



    return [
      for (final promo in List<Map<String, dynamic>>.from(promos))
        {
          ...promo
            ..remove('promo_party')
            ..remove('promo_items'),
          'items': List<Map<String, dynamic>>.from(
           List<Map<String, dynamic>>.from(promo['promo_items'] ?? []).map((item) {
              final menu = (item['menu_items'] as Map<String, dynamic>?) ??
                  const <String, dynamic>{};

              return {
               ...item..remove('menu_items'),
                'item_name': menu['item_name'],
                'item_price': menu['price'],
              };
            }),
          ),
        },
    ];
  }

  Future<List<Map<String, dynamic>>> loadMenuItems({
    required int placeId,
  }) async {
    final menus = await _client
        .from('menu')
        .select('id')
        .eq('place_id', placeId);

    final menuIds = List<int>.from(
      menus.map((menu) => menu['id']).whereType<int>(),
    );
    if (menuIds.isEmpty) return [];

    final items = await _client
        .from('menu_items')
        .select('id,item_name,price')
        .inFilter('menu_id', menuIds)
        .order('item_name', ascending: true);

    return List<Map<String, dynamic>>.from(items);
  }
}
