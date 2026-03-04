import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cheza_app/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:cheza_app/features/dashboard/presentation/widgets/layout/dashboard_state.dart';
import 'package:cheza_app/providers/party_providers.dart' show clienteleProvider;
import 'package:cheza_app/realtime/dashboard_realtime_controller.dart';
import 'package:cheza_app/services/supabase_network_service.dart';
import 'package:cheza_app/features/auth/presentation/providers/admin_provider.dart';
import 'package:cheza_app/core/storage/local_party_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final dashboardControllerProvider =
    StateNotifierProvider<DashboardController, DashboardState>((ref) {
  return DashboardController(ref);
});

class DashboardController extends StateNotifier<DashboardState> {
  final Ref ref;
  final DashboardRealtimeController _realtime = DashboardRealtimeController();

  StreamSubscription? _networkSub;

  DashboardController(this.ref) : super(const DashboardState()) {
    _init();
  }

  void _init() {
    loadInitialData();

    _networkSub = NetworkService.connectionStream.listen((connected) {
      if (connected) {
        loadInitialData();
      }
    });
  }

  // ================= LOAD INITIAL =================

  Future<void> loadInitialData() async {
    state = state.copyWith(isLoading: true, hasNetworkError: false);

    try {
      final place =
          await ref.read(dashboardRepositoryProvider).fetchMyPlace();

      /// image
      ref.read(placePhotoProvider.notifier).state = place.photoUrl;

      state = state.copyWith(
        placeId: place.id,
        placeName: place.name,
        placeAddress: place.address,
        placeImageUrl: place.photoUrl,
        placeDescription: place.typePlace,
        placeOpenedFromDb: place.isOpened,
        isOpen: place.isOpened,
      );

      await _loadAdminSafely();
      await refreshActiveParty();
    } catch (_) {
      state = state.copyWith(hasNetworkError: true);
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  // ================= ADMIN =================

  Future<void> _loadAdminSafely() async {
    try {
      final admin =
          await ref.read(dashboardRepositoryProvider).fetchMyAdmin();

      ref.read(adminProvider.notifier).state = admin;

      state = state.copyWith(adminName: admin.name);
    } catch (_) {
      /// ne bloque jamais le chargement du lieu
    }
  }

  // ================= ACTIVE PARTY =================

  Future<void> refreshActiveParty() async {
    if (state.placeId == null) return;

    final party = await ref.read(fetchActivePartyUseCaseProvider)(
      state.placeId!,
    );

    /// Aucune fête active
    if (party == null) {
      _realtime.dispose();

      ref.read(activePartyIdProvider.notifier).state = null;
      ref.read(dashboardStatsProvider.notifier).clear();
      ref.read(clienteleProvider.notifier).clear();

      await _persistLocalPartySession(isOpen: false);

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

    /// Fête active
    ref.read(activePartyIdProvider.notifier).state = party.id;

    await _persistLocalPartySession(isOpen: true);

    state = state.copyWith(
      isOpen: true,
      activePartyId: party.id,
      partyName: party.name,
      openTime: party.dateStarted,
      closeTime: party.dateClosed,
    );

    await _refreshStats(party.id);
    _setupRealtime(party.id);
  }

  // ================= TOGGLE =================

  Future<bool> togglePlaceStatus() async {
    if (state.isOpen) {
      return closeCurrentParty();
    }

    final now = DateTime.now();

    return openPlaceWithSchedule(
      openedAt: now,
      closedAt: now.add(const Duration(hours: 12)),
    );
  }

  Future<bool> openPlaceWithSchedule({
    required DateTime openedAt,
    required DateTime closedAt,
  }) async {
    if (state.isStatusUpdating || state.placeId == null) return false;

    if (!closedAt.isAfter(openedAt)) return false;

    state = state.copyWith(isStatusUpdating: true);

    try {
      final createParty = ref.read(createPartyUseCaseProvider);

      final createdId = await createParty(
        placeId: state.placeId!,
        name: 'Session ${state.placeName} - ${openedAt.day}/${openedAt.month}',
        openedAt: openedAt,
        closedAt: closedAt,
      );

      if (createdId == null) return false;

      await refreshActiveParty();
      return true;
    } catch (_) {
      return false;
    } finally {
      state = state.copyWith(isStatusUpdating: false);
    }
  }

  Future<bool> closeCurrentParty() async {
    if (state.isStatusUpdating || state.activePartyId == null) return false;

    state = state.copyWith(isStatusUpdating: true);

    try {
      final closeParty = ref.read(closePartyUseCaseProvider);

      final closed = await closeParty(
        partyId: state.activePartyId!,
        closedAt: DateTime.now(),
      );

      if (!closed) return false;

      await refreshActiveParty();
      return true;
    } catch (_) {
      return false;
    } finally {
      state = state.copyWith(isStatusUpdating: false);
    }
  }

  // ================= LOCAL STORAGE =================

  Future<void> _persistLocalPartySession({required bool isOpen}) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    final placeId = state.placeId;

    if (userId == null || placeId == null) return;

    await LocalPartyStorage.setPartySession(
      isOpen: isOpen,
      userId: userId,
      placeId: placeId,
    );
  }

  // ================= STATS =================

  Future<void> _refreshStats(int partyId) async {
    final stats =
        await ref.read(loadDashboardStatsUseCaseProvider)(partyId);

    state = state.copyWith(
      visitors: stats.visitors,
      posts: stats.posts,
      notes: stats.notes,
      engagement: stats.engagement,
    );
  }

  // ================= REALTIME =================

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

  void setSelectedIndex(int index) {
    state = state.copyWith(selectedIndex: index);
  }

  @override
  void dispose() {
    _networkSub?.cancel();
    _realtime.dispose();
    super.dispose();
  }
}