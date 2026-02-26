import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cheza_app/services/supabase_service_parties.dart';
import 'package:cheza_app/services/supabase_service_places.dart';
import 'package:flutter_riverpod/legacy.dart';

final activePartyIdProvider = StateProvider<int?>((ref) => null);

final activePartyProvider =
    AsyncNotifierProvider<ActivePartyNotifier, int?>(
  ActivePartyNotifier.new,
);

class ActivePartyNotifier extends AsyncNotifier<int?> {
  @override
  Future<int?> build() async {
    final placeId = await SupabaseServicePlaces.getMyPlaceId();
    if (placeId == null) return null;

    final party =
        await SupabaseServiceParties.fetchActivePartyForMyPlace(placeId);

    return party?['id'];
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = AsyncData(await build());
  }
}
