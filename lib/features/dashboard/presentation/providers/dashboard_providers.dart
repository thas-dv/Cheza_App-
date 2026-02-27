import 'package:cheza_app/features/dashboard/data/datasources/dashboard_supabase_data_source.dart';
import 'package:cheza_app/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:cheza_app/features/dashboard/domain/entities/dashboard_snapshot.dart';
import 'package:cheza_app/features/dashboard/domain/entities/dashboard_stats.dart';
import 'package:cheza_app/features/dashboard/domain/entities/party_summary.dart';
import 'package:cheza_app/features/dashboard/domain/usecases/fetch_active_party_usecase.dart';
import 'package:cheza_app/features/dashboard/domain/usecases/fetch_closed_parties_usecase.dart';
import 'package:cheza_app/features/dashboard/domain/usecases/load_dashboard_snapshot_usecase.dart';
import 'package:cheza_app/features/dashboard/domain/usecases/load_dashboard_stats_usecase.dart';
import 'package:cheza_app/features/dashboard/domain/usecases/manage_party_usecases.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final dashboardDataSourceProvider = Provider(
  (ref) => DashboardSupabaseDataSource(),
);

final dashboardRepositoryProvider = Provider(
  (ref) => DashboardRepositoryImpl(ref.read(dashboardDataSourceProvider)),
);

final loadDashboardSnapshotUseCaseProvider = Provider(
  (ref) => LoadDashboardSnapshotUseCase(ref.read(dashboardRepositoryProvider)),
);

final loadDashboardStatsUseCaseProvider = Provider(
  (ref) => LoadDashboardStatsUseCase(ref.read(dashboardRepositoryProvider)),
);

final fetchActivePartyUseCaseProvider = Provider(
  (ref) => FetchActivePartyUseCase(ref.read(dashboardRepositoryProvider)),
);

final fetchClosedPartiesUseCaseProvider = Provider(
  (ref) => FetchClosedPartiesUseCase(ref.read(dashboardRepositoryProvider)),
);

final closePartyUseCaseProvider = Provider(
  (ref) => ClosePartyUseCase(ref.read(dashboardRepositoryProvider)),
);

final createPartyUseCaseProvider = Provider(
  (ref) => CreatePartyUseCase(ref.read(dashboardRepositoryProvider)),
);

final activePartyIdProvider = StateProvider<int?>((ref) => null);
final placePhotoProvider = StateProvider<String?>((ref) => null);

class DashboardStatsNotifier extends StateNotifier<DashboardStats?> {
  DashboardStatsNotifier(this._loadDashboardStatsUseCase) : super(null);

  final LoadDashboardStatsUseCase _loadDashboardStatsUseCase;

  Future<void> load(int partyId) async {
    state = await _loadDashboardStatsUseCase(partyId);
  }

  void clear() => state = null;
}

final dashboardStatsProvider =
    StateNotifierProvider<DashboardStatsNotifier, DashboardStats?>(
      (ref) => DashboardStatsNotifier(ref.read(loadDashboardStatsUseCaseProvider)),
    );

final dashboardSnapshotProvider = FutureProvider<DashboardSnapshot>((ref) async {
  return ref.read(loadDashboardSnapshotUseCaseProvider)();
});

final closedPartiesProvider =
    FutureProvider.family<List<PartySummary>, int>((ref, placeId) async {
      return ref.read(fetchClosedPartiesUseCaseProvider)(placeId);
    });
