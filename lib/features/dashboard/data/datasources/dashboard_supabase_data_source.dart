import 'package:cheza_app/services/supabase_service_admin.dart';
import 'package:cheza_app/services/supabase_service_clientel.dart';
import 'package:cheza_app/services/supabase_service_notes.dart';
import 'package:cheza_app/services/supabase_service_parties.dart';
import 'package:cheza_app/services/supabase_service_places.dart';
import 'package:cheza_app/services/supabase_service_poste.dart';

class DashboardSupabaseDataSource {
  Future<Map<String, dynamic>?> fetchMyAdminProfile() {
    return SupabaseServiceAdmin.fetchMyAdminProfile();
  }

  Future<Map<String, dynamic>?> fetchMyPlaceDetails(int placeId) {
    return SupabaseServicePlaces.fetchMyPlaceDetails(placeId);
  }

  Future<Map<String, dynamic>?> fetchActiveParty(int placeId) {
    return SupabaseServiceParties.fetchActivePartyForMyPlace(placeId);
  }

  Future<int> countVisitors(int partyId) {
    return SupabaseServiceClientel.countClienteleByParty(partyId);
  }

  Future<int> countPosts(int partyId) {
    return SupabaseServicePoste.countPostsByParty(partyId);
  }

  Future<int> countRatings(int partyId) {
    return SupabaseServiceNotes.countRatingsByParty(partyId);
  }

  Future<int> countEngagement(int partyId) {
    return SupabaseServiceNotes.countEngagementByParty(partyId);
  }

  Future<List<Map<String, dynamic>>> fetchClientele(int partyId) {
    return SupabaseServiceClientel.fetchClienteleData(partyId);
  }

  Future<bool> closeParty({required int partyId, required DateTime closedAt}) {
    return SupabaseServiceParties.closePartyById(
      partyId: partyId,
      dateClosed: closedAt,
    );
  }

  Future<int?> createParty({
    required int placeId,
    required String name,
    required DateTime openedAt,
    required DateTime closedAt,
  }) {
    return SupabaseServiceParties.insertParty(
      placeId: placeId,
      nameParty: name,
      dateStarted: openedAt,
      dateClosed: closedAt,
    );
  }

  Future<List<Map<String, dynamic>>> fetchClosedParties(int placeId) {
    return SupabaseServiceParties.fetchClosedPartiesForPlace(placeId);
  }
}