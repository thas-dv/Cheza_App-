import 'package:cheza_app/features/dashboard/domain/entities/dashboard_stats.dart';
import 'package:cheza_app/features/dashboard/domain/repositories/dashboard_repository.dart';

class LoadDashboardStatsUseCase {
  const LoadDashboardStatsUseCase(this._repository);

  final DashboardRepository _repository;

  Future<DashboardStats> call(int partyId) {
    return _repository.loadDashboardStats(partyId);
  }
}