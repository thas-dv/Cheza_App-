import 'package:cheza_app/features/promotions/domain/entities/promotion_entity.dart';
import 'package:cheza_app/features/promotions/domain/repositories/promotions_repository.dart';

class LoadPromosUseCase {
  const LoadPromosUseCase(this._repository);

  final PromotionsRepository _repository;

  Future<List<PromotionEntity>> call({required int partyId}) {
    return _repository.loadPromos(partyId: partyId);
  }
}
