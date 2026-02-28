import 'package:cheza_app/features/promotions/domain/entities/promotion_entity.dart';

abstract class PromotionsRepository {
  Future<int> createPromo({
    required String description,
    required bool forEveryone,
    int? limit,
    required DateTime dateStart,
    required DateTime dateEnd,
  });

  Future<void> addPromoItem({
    required int promoId,
    required int itemId,
    required bool isFreeOffer,
    String? discountType,
    double? discountValue,
  });

  Future<void> attachPromoToParty({
    required int promoId,
    required int partyId,
  });

  Future<List<PromotionEntity>> loadPromos({required int partyId});

  Future<List<MenuItemOptionEntity>> loadMenuItems({required int placeId});
}
