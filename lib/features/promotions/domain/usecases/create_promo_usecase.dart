import 'package:cheza_app/features/promotions/domain/repositories/promotions_repository.dart';

class CreatePromoUseCase {
  const CreatePromoUseCase(this._repository);

  final PromotionsRepository _repository;

  Future<int> call({
    required String description,
    required bool unlimited,
    required int placeId,
    int? limit,

    required DateTime dateStart,
    required DateTime dateEnd,
  }) {
    return _repository.createPromo(
      placeId: placeId,
      description: description,
      unlimited: unlimited,
      limit: limit,
      dateStart: dateStart,
      dateEnd: dateEnd,
    );
  }
}
