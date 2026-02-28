import 'package:cheza_app/features/promotions/data/datasources/promotions_supabase_data_source.dart';
import 'package:cheza_app/features/promotions/domain/entities/promotion_entity.dart';
import 'package:cheza_app/features/promotions/domain/repositories/promotions_repository.dart';

class PromotionsRepositoryImpl implements PromotionsRepository {
  const PromotionsRepositoryImpl(this._dataSource);

  final PromotionsSupabaseDataSource _dataSource;

  @override
  Future<void> addPromoItem({
    required int promoId,
    required int itemId,
    required bool isFreeOffer,
    String? discountType,
    double? discountValue,
  }) {
    return _dataSource.addPromoItem(
      promoId: promoId,
      itemId: itemId,
      isFreeOffer: isFreeOffer,
      discountType: discountType,
      discountValue: discountValue,
    );
  }

  @override
  Future<void> attachPromoToParty({
    required int promoId,
    required int partyId,
  }) {
    return _dataSource.attachPromoToParty(promoId: promoId, partyId: partyId);
  }

  @override
  Future<int> createPromo({
    required String description,
    required bool unlimited,
    int? limit,
    required DateTime dateStart,
    required DateTime dateEnd,
  }) {
    return _dataSource.createPromo(
      description: description,
      unlimited: unlimited,
      limit: limit,
      dateStart: dateStart,
      dateEnd: dateEnd,
    );
  }

  @override
  Future<List<MenuItemOptionEntity>> loadMenuItems({
    required int placeId,
  }) async {
    final raw = await _dataSource.loadMenuItems(placeId: placeId);
    return raw
        .map(
          (item) => MenuItemOptionEntity(
            id: item['id'] as int,
            name: item['item_name']?.toString() ?? 'Article',
            price: (item['price'] as num?)?.toDouble() ?? 0,
          ),
        )
        .toList();
  }

  @override
  Future<List<PromotionEntity>> loadPromos({required int partyId}) async {
    final raw = await _dataSource.loadPromos(partyId: partyId);

    return raw.map((promo) {
      final items = List<Map<String, dynamic>>.from(promo['items'] ?? []);

      return PromotionEntity(
        id: promo['id'] as int,
        description: promo['promo_desc']?.toString() ?? '',
        forEveryone: promo['for_everyone'] as bool? ?? true,
        limit: promo['limite'] as int?,
        dateStart:
            DateTime.tryParse(promo['date_start']?.toString() ?? '') ??
            DateTime.now(),
        dateEnd:
            DateTime.tryParse(promo['date_end']?.toString() ?? '') ??
            DateTime.now(),
        items: items
            .map(
              (item) => PromoItemEntity(
                id: item['id'] as int,
                promoId: item['promo_id'] as int,
                itemId: item['item_id'] as int,
                itemName: item['item_name']?.toString() ?? 'Article',
                itemPrice: (item['item_price'] as num?)?.toDouble() ?? 0,
                isFreeOffer: item['is_free_offer'] as bool? ?? true,
                discountType: item['discount_type']?.toString(),
                discountValue: (item['discount_value'] as num?)?.toDouble(),
              ),
            )
            .toList(),
      );
    }).toList();
  }
}
