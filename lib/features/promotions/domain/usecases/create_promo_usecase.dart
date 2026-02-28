import 'package:cheza_app/features/promotions/domain/repositories/promotions_repository.dart';

class CreatePromoUseCase {
  const CreatePromoUseCase(this._repository);

  final PromotionsRepository _repository;

  Future<int> call({
    required String description,
    required bool forEveryone,
    int? limit,
    required DateTime dateStart,
    required DateTime dateEnd,
  }) {
    return _repository.createPromo(
      description: description,
      forEveryone: forEveryone,
      limit: limit,
      dateStart: dateStart,
      dateEnd: dateEnd,
    );
  }
}
