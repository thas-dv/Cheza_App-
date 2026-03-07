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
    required int placeId,
  }) async {
    final promo = await _client
        .from('promos')
        .insert({
          'promo_desc': description,
          'place_id': placeId,
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
    final normalizedType = switch (discountType) {
      'Pourcentage' => 'Pourcentage',
      'Montant' => 'Montant',
      _ => discountType,
    };
    await _client.from('promo_items').insert({
      'promo_id': promoId,
      'menu_item_id': itemId,
      'is_free': isFreeOffer,
      'discount_type': isFreeOffer ? null : normalizedType,
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

  Future<List<Map<String, dynamic>>> loadPromos({
    required int placeId,
    int? partyId,
  }) async {
    final response = partyId == null
        ? await _client
              .from('promos')
              .select("""
            id,
            promo_desc,
            unlimited,
            limite,
            date_start,
            date_end,
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
          """)
              .eq('place_id', placeId)
              .order('date_start', ascending: false)
        : await _client.from('promos').select("""
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
          """);

    return response.map((promo) {
      final items = promo['items'] as List? ?? [];

      final mappedItems = items.map((item) {
        final menuItem = item['menu_items'];

        return {
          'id': item['id'],
          'promo_id': item['promo_id'],
          'menu_item_id': item['menu_item_id'],
          'is_free': item['is_free'],
          'discount_type': item['discount_type'],
          'discount_value': item['discount_value'],
          'item_name': menuItem?['item_name'],
          'price': menuItem?['price'],
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

  Future<List<Map<String, dynamic>>> loadPromoWinners({
    required int promoId,
  }) async {
    final rows = await _client
        .from('promo_winners')
        .select('''
        id,
        winner_id,
        created_at,
        attendee:parties_attandance!promo_winners_winner_id_fkey(
          id,
          is_present,
          user_id,
          profiles:profiles!parties_attandance_user_id_fkey(
            username,
            avatar_url
          )
        )
      ''')
        .eq('promo_id', promoId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(rows);
  }

  Future<List<Map<String, dynamic>>> loadPresentAttendees({
    required int partyId,
  }) async {
    final rows = await _client
        .from('parties_attandance')
        .select('''
        id,
        is_present,
        profiles:profiles!parties_attandance_user_id_fkey(
          username,
          avatar_url
        )
      ''')
        .eq('party_id', partyId)
        .eq('is_present', true)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(rows);
  }

  Future<void> addPromoWinner({
    required int promoId,
    required int attendeeId,
  }) async {
    await _client.from('promo_winners').insert({
      'promo_id': promoId,
      'winner_id': attendeeId,
    });
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

  // Future<List<Map<String, dynamic>>> fetchMenuItemsByMenu({
  //   required int menuId,
  // }) async {
  //   final items = await _client
  //       .from('menu_items')
  //       .select('id,item_name,price,menu_id')
  //       .eq('menu_id', menuId)
  //       .order('item_name', ascending: true);

  //   return List<Map<String, dynamic>>.from(items);
  // }
}
