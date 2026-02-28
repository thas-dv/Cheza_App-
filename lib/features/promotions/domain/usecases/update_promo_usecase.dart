import 'package:cheza_app/features/promotions/domain/repositories/promotions_repository.dart';

class UpdatePromoUseCase {
  const UpdatePromoUseCase(this._repository);

  final PromotionsRepository _repository;

  Future<void> call({
    required int promoId,
    required String description,
    required bool unlimited,
    int? limit,
    required DateTime dateStart,
    required DateTime dateEnd,
  }) {
    return _repository.updatePromo(
      promoId: promoId,
      description: description,
      unlimited: unlimited,
      limit: limit,
      dateStart: dateStart,
      dateEnd: dateEnd,
    );
  }
}
