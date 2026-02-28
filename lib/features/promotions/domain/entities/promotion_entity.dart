class PromotionEntity {
  const PromotionEntity({
    required this.id,
    required this.description,
    required this.forEveryone,
    this.limit,
    required this.dateStart,
    required this.dateEnd,
    this.items = const [],
  });

  final int id;
  final String description;
  final bool forEveryone;
  final int? limit;
  final DateTime dateStart;
  final DateTime dateEnd;
  final List<PromoItemEntity> items;
}

class PromoItemEntity {
  const PromoItemEntity({
    required this.id,
    required this.promoId,
    required this.itemId,
    required this.itemName,
    required this.itemPrice,
    required this.isFreeOffer,
    this.discountType,
    this.discountValue,
  });

  final int id;
  final int promoId;
  final int itemId;
  final String itemName;
  final double itemPrice;
  final bool isFreeOffer;
  final String? discountType;
  final double? discountValue;
}

// class MenuItemOptionEntity {
//   const MenuItemOptionEntity({
//     required this.id,
//     required this.name,
//     required this.price,
//   });

//   final int id;
//   final String name;
//   final double price;
// }
