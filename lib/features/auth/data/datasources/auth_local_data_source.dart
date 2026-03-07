import 'package:cheza_app/core/storage/local_party_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthLocalDataSource {
  const AuthLocalDataSource(this._client);

  final SupabaseClient _client;
  String? getCurrentUserId() {
    try {
      return _client.auth.currentUser?.id;
    } catch (_) {
      return null;
    }
  }

  bool hasActiveSession() {
    try {
      return _client.auth.currentSession != null;
    } catch (_) {
      return false;
    }
  }

  Future<bool> hasSeenWelcome() {
    return LocalPartyStorage.hasSeenWelcome();
  }

  Future<void> markWelcomeSeen() {
    return LocalPartyStorage.markWelcomeSeen();
  }

  Future<bool> hasOpenPartyOfflineAccessForCurrentUser() async {
    try {
      final userId = getCurrentUserId();
      if (userId == null) return false;
      return await LocalPartyStorage.isPartyOpenForUser(userId);
    } catch (_) {
      return false;
    }
  }

  Future<bool> hasActiveOpenedPlaceForCurrentUser() async {
    final userId = getCurrentUserId();
    if (userId == null) return false;
    try {
      final link = await _client
          .from('admins_place')
          .select('place_id')
          .eq('admin_id', userId)
          .eq('active', true)
          .limit(1)
          .maybeSingle();

      final placeId = link?['place_id'] as int?;
      if (placeId == null) return false;

      final place = await _client
          .from('places')
          .select('opened')
          .eq('id', placeId)
          .maybeSingle();
      final opened = place?['opened'] == true;
      if (!opened) return false;

      final party = await _client
          .from('parties')
          .select('id')
          .eq('place_id', placeId)
          .eq('active', true)
          .limit(1)
          .maybeSingle();

      return party != null;
    } catch (_) {
      return false;
    }
  }
}
