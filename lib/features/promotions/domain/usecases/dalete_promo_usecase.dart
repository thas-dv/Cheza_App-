import 'package:cheza_app/features/promotions/domain/repositories/promotions_repository.dart';

class DeletePromoUseCase {
  const DeletePromoUseCase(this._repository);

  final PromotionsRepository _repository;

  Future<void> call({required int promoId}) {
    return _repository.deletePromo(promoId: promoId);
  }
}
