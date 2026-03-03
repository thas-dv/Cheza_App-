import 'dart:async';

import 'package:cheza_app/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:cheza_app/features/dashboard/presentation/widgets/layout/dashboard_state.dart';
import 'package:cheza_app/providers/party_providers.dart'
    show clienteleProvider;
import 'package:cheza_app/realtime/dashboard_realtime_controller.dart'
    show DashboardRealtimeController;
import 'package:cheza_app/features/dashboard/domain/usecases/manage_party_usecases.dart';
import 'package:cheza_app/services/supabase_network_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:cheza_app/features/auth/presentation/providers/admin_provider.dart';

final dashboardControllerProvider =
    StateNotifierProvider<DashboardController, DashboardState>((ref) {
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
      if (connected) {
        loadInitialData();
      }
    });
  }

  Future<void> loadInitialData() async {
    state = state.copyWith(isLoading: true, hasNetworkError: false);
    try {
      final place = await ref.read(dashboardRepositoryProvider).fetchMyPlace();
      final admin = await ref.read(dashboardRepositoryProvider).fetchMyAdmin();

      ref.read(adminProvider.notifier).state = admin;
      ref.read(placePhotoProvider.notifier).state = place.photoUrl;

      state = state.copyWith(
        placeId: place.id,
        placeName: place.name,
        placeImageUrl: _normalizeImageUrl(place.photoUrl),
        placeAddress: place.address,
        placeDescription: place.typePlace,
        adminName: admin.name,
        placeOpenedFromDb: place.isOpened,
        isOpen: place.isOpened,
      );
      await refreshActiveParty();
    } catch (_) {
      state = state.copyWith(hasNetworkError: true);
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> refreshActiveParty() async {
    if (state.placeId == null) return;
    final party = await ref.read(fetchActivePartyUseCaseProvider)(
      state.placeId!,
    );

    if (party == null) {
      _realtime.dispose();
      ref.read(activePartyIdProvider.notifier).state = null;
      ref.read(dashboardStatsProvider.notifier).clear();
      state = state.copyWith(
        isOpen: state.placeOpenedFromDb,
        activePartyId: null,
        partyName: '',
        openTime: null,
        closeTime: null,
        visitors: 0,
        posts: 0,
        notes: 0,
        engagement: 0,
      );
      return;
    }
    ref.read(activePartyIdProvider.notifier).state = party.id;
    state = state.copyWith(
      placeOpenedFromDb: true,
      activePartyId: party.id,
      partyName: party.name,
      openTime: party.dateStarted,
      closeTime: party.dateClosed,
    );

    await _refreshStats(party.id);
    _setupRealtime(party.id);
  }

  //////////////////////////////////////////
  String? _normalizeImageUrl(String? rawUrl) {
    if (rawUrl == null) return null;
    final trimmed = rawUrl.trim();
    if (trimmed.isEmpty) return null;

    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return Uri.encodeFull(trimmed);
    }

    return Uri.encodeFull(trimmed);
  }

  Future<bool> togglePlaceStatus() async {
    if (state.isStatusUpdating || state.placeId == null) return false;

    state = state.copyWith(isStatusUpdating: true);

    try {
      if (state.isOpen) {
        final activePartyId = state.activePartyId;
        if (activePartyId == null) return false;

        final closeParty = ref.read(closePartyUseCaseProvider);
        final closed = await closeParty(
          partyId: activePartyId,
          closedAt: DateTime.now(),
        );

        if (!closed) return false;
        state = state.copyWith(isOpen: false, placeOpenedFromDb: false);
      } else {
        final createParty = ref.read(createPartyUseCaseProvider);
        final now = DateTime.now();
        final createdId = await createParty(
          placeId: state.placeId!,
          name:
              'Session ${state.placeName} - ${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}',
          openedAt: now,
          closedAt: now.add(const Duration(hours: 12)),
        );

        if (createdId == null) return false;
        state = state.copyWith(isOpen: true, placeOpenedFromDb: true);
      }

      await refreshActiveParty();
      return true;
    } catch (_) {
      return false;
    } finally {
      state = state.copyWith(isStatusUpdating: false);
    }
  }

  /////////////////////////////////////////////
  Future<void> _refreshStats(int partyId) async {
    final stats = await ref.read(loadDashboardStatsUseCaseProvider)(partyId);
    state = state.copyWith(
      visitors: stats.visitors,
      posts: stats.posts,
      notes: stats.notes,
      engagement: stats.engagement,
    );
  }

  void _setupRealtime(int partyId) {
    _realtime.startAttendanceRealtime(
      partyId: partyId,
      reloadClientele: () async {
        final data = await ref
            .read(dashboardRepositoryProvider)
            .fetchClientele(partyId);
        ref.read(clienteleProvider.notifier).setClients(data);
        state = state.copyWith(visitors: data.length);
      },
      refreshClienteleCount: () async {
        final stats = await ref
            .read(dashboardRepositoryProvider)
            .loadDashboardStats(partyId);
        state = state.copyWith(
          visitors: stats.visitors,
          posts: stats.posts,
          notes: stats.notes,
          engagement: stats.engagement,
        );
      },
    );
  }

  void setSelectedIndex(int index) =>
      state = state.copyWith(selectedIndex: index);

  @override
  void dispose() {
    _networkSub?.cancel();
    _realtime.dispose();
    super.dispose();
  }
}
