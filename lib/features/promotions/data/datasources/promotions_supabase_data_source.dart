import 'package:supabase_flutter/supabase_flutter.dart';

class PromotionsSupabaseDataSource {
  PromotionsSupabaseDataSource({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<int> createPromo({
    required String description,
    required bool forEveryone,
    int? limit,
    required DateTime dateStart,
    required DateTime dateEnd,
  }) async {
    final promo = await _client
        .from('promos')
        .insert({
          'promo_desc': description,
          'for_everyone': forEveryone,
          'limite': forEveryone ? null : limit,
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
      'item_id': itemId,
      'is_free_offer': isFreeOffer,
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
    final links = await _client
        .from('promo_party')
        .select('promo_id')
        .eq('party_id', partyId);

    final promoIds = List<int>.from(
      links.map((link) => link['promo_id']).whereType<int>(),
    );

    if (promoIds.isEmpty) return [];

    final promos = await _client
        .from('promos')
        .select('id,promo_desc,for_everyone,limite,date_start,date_end')
        .inFilter('id', promoIds)
        .order('date_start', ascending: false);

    final items = await _client
        .from('promo_items')
        .select(
          'id,promo_id,item_id,is_free_offer,discount_type,discount_value',
        )
        .inFilter('promo_id', promoIds);

    final itemIds = List<int>.from(
      items.map((item) => item['item_id']).whereType<int>(),
    );

    final menuItems = itemIds.isEmpty
        ? <Map<String, dynamic>>[]
        : List<Map<String, dynamic>>.from(
            await _client
                .from('menu_items')
                .select('id,item_name,price')
                .inFilter('id', itemIds),
          );

    return [
      for (final promo in List<Map<String, dynamic>>.from(promos))
        {
          ...promo,
          'items': List<Map<String, dynamic>>.from(
            items.where((item) => item['promo_id'] == promo['id']).map((item) {
              final menu = menuItems.firstWhere(
                (menuItem) => menuItem['id'] == item['item_id'],
                orElse: () => const <String, dynamic>{},
              );

              return {
                ...item,
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
