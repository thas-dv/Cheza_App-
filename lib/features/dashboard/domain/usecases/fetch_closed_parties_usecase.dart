import 'package:cheza_app/features/dashboard/domain/entities/party_summary.dart';
import 'package:cheza_app/features/dashboard/domain/repositories/dashboard_repository.dart';

class FetchClosedPartiesUseCase {
  const FetchClosedPartiesUseCase(this._repository);

  final DashboardRepository _repository;

  Future<List<PartySummary>> call(int placeId) {
    return _repository.fetchClosedParties(placeId);
  }
}