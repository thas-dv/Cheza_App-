// import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:cheza_app/services/supabase_service_clientel.dart';

/// ======================================================
/// STATE
/// ======================================================
class ClienteleState {
  final bool loading;
  final bool networkError;
  final List<Map<String, dynamic>> clients;
  final bool hasLoadedOnce;

  const ClienteleState({
    required this.loading,
    required this.networkError,
    required this.clients,
    required this.hasLoadedOnce,
  });

  factory ClienteleState.initial() => const ClienteleState(
    loading: true,
    networkError: false,
    clients: [],
    hasLoadedOnce: false,
  );
}

/// ======================================================
/// PROVIDER
/// ======================================================
final clienteleListProvider = StateNotifierProvider.autoDispose
    .family<ClienteleNotifier, ClienteleState, int>((ref, partyId) {
      final link = ref.keepAlive();
      ref.onDispose(() => link.close());

      return ClienteleNotifier(partyId);
    });

/// ======================================================
/// NOTIFIER
/// ======================================================
class ClienteleNotifier extends StateNotifier<ClienteleState> {
  final int partyId;

  ClienteleNotifier(this.partyId) : super(ClienteleState.initial());

  Future<void> load({bool silent = false}) async {
    if (!mounted) return;

    if (!silent) {
      state = ClienteleState(
        loading: false,
        networkError: true,
        clients: state.hasLoadedOnce ? state.clients : [],
        hasLoadedOnce: state.hasLoadedOnce,
      );
    }

    try {
      final data = await SupabaseServiceClientel.fetchClienteleData(partyId);

      if (!mounted) return;

      state = ClienteleState(
        loading: false,
        networkError: false,
        hasLoadedOnce: true,
        clients: data,
      );
    } catch (_) {
      if (!mounted) return;

      state = ClienteleState(
        loading: false,
        networkError: true,
        hasLoadedOnce: state.hasLoadedOnce,
        clients: state.hasLoadedOnce ? state.clients : [],
      );
    }
  }
}
