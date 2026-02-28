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
    final response = await _client
        .from('promos')
        .select('''
        id,
        promo_desc,
        unlimited,
        limite,
        date_start,
        date_end,
        promo_party!inner(party_id),
        items:promo_items (
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

    final promos = List<Map<String, dynamic>>.from(response);

    return promos.map((promo) {
      final rawItems = List<Map<String, dynamic>>.from(
        promo['items'] ?? const [],
      );

      final mappedItems = rawItems.map((item) {
        final menu = (item['menu_items'] as Map<String, dynamic>?) ?? const {};

        return {
          'id': item['id'],
          'promo_id': item['promo_id'],
          'menu_item_id': item['menu_item_id'],
          'is_free': item['is_free'],
          'discount_type': item['discount_type'],
          'discount_value': item['discount_value'],
          'item_name': menu['item_name'],
          'item_price': menu['price'],
        };
      }).toList();

      return {
        'id': promo['id'],
        'promo_desc': promo['promo_desc'],
        'unlimited': promo['unlimited'],
        'limite': promo['limite'],
        'date_start': promo['date_start'],
        'date_end': promo['date_end'],
        'items': mappedItems,
      };
    }).toList();
  }

  Future<void> updatePromo({
    required int promoId,
    required String description,
    required bool unlimited,
    int? limit,
    required DateTime dateStart,
    required DateTime dateEnd,
  }) async {
    await _client
        .from('promos')
        .update({
          'promo_desc': description,
          'unlimited': unlimited,
          'limite': unlimited ? null : limit,
          'date_start': dateStart.toIso8601String(),
          'date_end': dateEnd.toIso8601String(),
        })
        .eq('id', promoId);
  }

  Future<void> deletePromo({required int promoId}) async {
    await _client.from('promo_items').delete().eq('promo_id', promoId);
    await _client.from('promo_party').delete().eq('promo_id', promoId);
    await _client.from('promos').delete().eq('id', promoId);
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
