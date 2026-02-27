import 'package:cheza_app/features/dashboard/domain/repositories/dashboard_repository.dart';

class ClosePartyUseCase {
  const ClosePartyUseCase(this._repository);

  final DashboardRepository _repository;

  Future<bool> call({required int partyId, required DateTime closedAt}) {
    return _repository.closeParty(partyId: partyId, closedAt: closedAt);
  }
}

class CreatePartyUseCase {
  const CreatePartyUseCase(this._repository);

  final DashboardRepository _repository;

  Future<int?> call({
    required int placeId,
    required String name,
    required DateTime openedAt,
    required DateTime closedAt,
  }) {
    return _repository.createParty(
      placeId: placeId,
      name: name,
      openedAt: openedAt,
      closedAt: closedAt,
    );
  }
}