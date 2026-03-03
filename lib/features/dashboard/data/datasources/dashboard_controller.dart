import 'dart:async';

import 'package:cheza_app/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:cheza_app/features/dashboard/presentation/widgets/layout/dashboard_state.dart';
import 'package:cheza_app/providers/party_providers.dart' show clienteleProvider;
import 'package:cheza_app/realtime/dashboard_realtime_controller.dart' show DashboardRealtimeController;
import 'package:cheza_app/services/supabase_network_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final dashboardControllerProvider = StateNotifierProvider<DashboardController, DashboardState>((ref) {
  return DashboardController(ref);
});

class DashboardController extends StateNotifier<DashboardState> {
  final Ref ref;
  final DashboardRealtimeController _realtime = DashboardRealtimeController();
  StreamSubscription? _networkSub;

  DashboardController(this.ref) : super(DashboardState()) {
    init();
  }

  void init() {
    loadInitialData();
    _networkSub = NetworkService.connectionStream.listen((connected) {
      if (connected) loadInitialData();
    });
  }

  Future<void> loadInitialData() async {
    state = state.copyWith(isLoading: true, hasNetworkError: false);
    try {
      final place = await ref.read(dashboardRepositoryProvider).fetchMyPlace();
      state = state.copyWith(placeId: place.id, placeName: place.name);
      await refreshActiveParty();
    } catch (e) {
      state = state.copyWith(hasNetworkError: true);
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> refreshActiveParty() async {
    if (state.placeId == null) return;
    final party = await ref.read(fetchActivePartyUseCaseProvider)(state.placeId!);

    if (party == null) {
      _realtime.dispose();
      state = state.copyWith(isOpen: false, activePartyId: null, visitors: 0);
      return;
    }

    state = state.copyWith(
      isOpen: true,
      activePartyId: party.id,
      partyName: party.name,
      openTime: party.dateStarted,
      closeTime: party.dateClosed,
    );
    
    _setupRealtime(party.id);
  }

  void _setupRealtime(int partyId) {
    _realtime.startAttendanceRealtime(
      partyId: partyId,
      reloadClientele: () async {
        final data = await ref.read(dashboardRepositoryProvider).fetchClientele(partyId);
        ref.read(clienteleProvider.notifier).setClients(data);
        state = state.copyWith(visitors: data.length);
      },
      refreshClienteleCount: () async {
         final stats = await ref.read(dashboardRepositoryProvider).loadDashboardStats(partyId);
         state = state.copyWith(visitors: stats.visitors);
      }
    );
  }

  void setSelectedIndex(int index) => state = state.copyWith(selectedIndex: index);

  @override
  void dispose() {
    _networkSub?.cancel();
    _realtime.dispose();
    super.dispose();
  }
}