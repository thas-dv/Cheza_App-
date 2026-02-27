import 'package:cheza_app/features/dashboard/domain/entities/dashboard_snapshot.dart';
import 'package:cheza_app/features/dashboard/domain/repositories/dashboard_repository.dart';

class LoadDashboardSnapshotUseCase {
  const LoadDashboardSnapshotUseCase(this._repository);

  final DashboardRepository _repository;

  Future<DashboardSnapshot> call() {
    return _repository.loadDashboardSnapshot();
  }
}