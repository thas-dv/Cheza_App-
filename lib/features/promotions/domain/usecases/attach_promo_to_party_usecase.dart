import 'package:cheza_app/features/promotions/domain/repositories/promotions_repository.dart';

class AttachPromoToPartyUseCase {
  const AttachPromoToPartyUseCase(this._repository);

  final PromotionsRepository _repository;

  Future<void> call({required int promoId, required int partyId}) {
    return _repository.attachPromoToParty(promoId: promoId, partyId: partyId);
  }
}
