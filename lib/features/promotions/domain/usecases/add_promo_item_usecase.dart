import 'package:cheza_app/features/promotions/domain/repositories/promotions_repository.dart';

class AddPromoItemUseCase {
  const AddPromoItemUseCase(this._repository);

  final PromotionsRepository _repository;

  Future<void> call({
    required int promoId,
    required int itemId,
    required bool isFreeOffer,
    String? discountType,
    double? discountValue,
  }) {
    return _repository.addPromoItem(
      promoId: promoId,
      itemId: itemId,
      isFreeOffer: isFreeOffer,
      discountType: discountType,
      discountValue: discountValue,
    );
  }
}
