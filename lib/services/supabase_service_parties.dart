import 'dart:io';

import 'package:cheza_app/services/network_guard.dart';
import 'package:cheza_app/services/supabase_network_service.dart';
import 'package:cheza_app/services/supabase_service_places.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class SupabaseServiceParties {
  //////////////////////////////////////////////////////
  // static Future<Map<String, dynamic>?> fetchActivePartyForMyPlace(
  //   int placeId,
  // ) async {
  //   try {
  //     final res = await supabase
  //         .from('parties')
  //         .select('id, name_party, date_started, date_closed')
  //         .eq('place_id', placeId)
  //         .eq('active', true)
  //         .order('date_started', ascending: false)
  //         .limit(1)
  //         .maybeSingle();

  //     return res;
  //   } catch (e) {
  //     print("❌ fetchActivePartyForMyPlace error: $e");
  //     return null;
  //   }
  // }
  static Future<Map<String, dynamic>?> fetchActivePartyForMyPlace(
    int placeId,
  ) async {
    // 🚫 NE PAS FETCH SI OFFLINE
    if (!NetworkService.isConnected) {
      debugPrint("⚠️ Offline → skip fetchActivePartyForMyPlace");
      throw const SocketException("Offline");
    }

    try {
      final res = await supabase
          .from('parties')
          .select('id, name_party, date_started, date_closed')
          .eq('place_id', placeId)
          .eq('active', true)
          .order('date_started', ascending: false)
          .limit(1)
          .maybeSingle();

      // ⚠️ ICI : null = vraiment aucune fête active
      return res;
    } catch (e) {
      debugPrint("⚠️ fetchActivePartyForMyPlace failed → keep last value");
      throw e; // 👈 IMPORTANT : on remonte l'erreur
    }
  }

  /////////////////////////////////
  static Future<int?> getActivePartyId() async {
    try {
      final placeId = await SupabaseServicePlaces.getMyPlaceId();
      if (placeId == null) return null;

      final res = await supabase
          .from('parties')
          .select('id')
          .eq('place_id', placeId)
          .eq('active', true)
          .limit(1)
          .maybeSingle();

      return res?['id'] as int?;
    } catch (e) {
      print("❌ getActivePartyId error: $e");
      return null;
    }
  }

  ///////////////////////////////////////////////////////
  // static Future<bool> closePartyById({
  //   required int partyId,
  //   required DateTime dateClosed,
  // }) async {
  //   try {
  //     await supabase
  //         .from('parties')
  //         .update({
  //           'date_closed': dateClosed.toUtc().toIso8601String(),
  //           'active': false,

  //         })
  //         .eq('id', partyId);
  //     await supabase.from('places').update({})
  //     return true;
  //   } catch (e) {
  //     print("❌ closePartyById error: $e");
  //     return false;
  //   }
  // }
  static Future<bool> closePartyById({
    required int partyId,
    required DateTime dateClosed,
  }) async {
    try {
      // 1️⃣ Récupérer la party pour avoir place_id
      final partyResponse = await supabase
          .from('parties')
          .select('place_id')
          .eq('id', partyId)
          .single();

      final int placeId = partyResponse['place_id'];

      // 2️⃣ Fermer la party
      await supabase
          .from('parties')
          .update({
            'date_closed': dateClosed.toUtc().toIso8601String(),
            'active': false,
          })
          .eq('id', partyId);

      // 3️⃣ Fermer le lieu associé
      await supabase.from('places').update({'opened': false}).eq('id', placeId);

      return true;
    } catch (e) {
      print("❌ closePartyById error: $e");
      return false;
    }
  }

  /////////////////////////////////////////////////////////////
  // static Future<void> autoCloseExpiredParties() async {
  //   try {
  //     final placeId = await SupabaseServicePlaces.getMyPlaceId();
  //     if (placeId == null) return;

  //     await supabase
  //         .from('parties')
  //         .update({'active': false})
  //         .eq('place_id', placeId)
  //         .eq('active', true)
  //         .lte('date_closed', DateTime.now().toUtc().toIso8601String());
  //   } catch (e) {
  //     print("❌ autoCloseExpiredParties error: $e");
  //   }
  // }
  static Future<void> autoCloseExpiredParties() async {
    // 🛑 Guard rapide
    if (!NetworkGuard.allowRequest()) return;

    try {
      final placeId = await SupabaseServicePlaces.getMyPlaceId();
      if (placeId == null) return;

      await supabase
          .from('parties')
          .update({'active': false})
          .eq('place_id', placeId)
          .eq('active', true)
          .lte('date_closed', DateTime.now().toUtc().toIso8601String());
    } catch (_) {
      // 🧼 SILENCE TOTAL (offline / timeout / DNS / handshake)
    }
  }

  /////////////////////////////////////////////////////////////
  static Future<int?> insertParty({
    required int placeId,
    required String nameParty,
    required DateTime dateStarted,
    required DateTime dateClosed,
  }) async {
    try {
      final res = await supabase
          .from('parties')
          .insert({
            'place_id': placeId,
            'name_party': nameParty,
            'date_started': dateStarted.toUtc().toIso8601String(),
            'date_closed': dateClosed.toUtc().toIso8601String(),
            'active': true,
          })
          .select('id')
          .single();

      return res['id'] as int;
    } catch (e) {
      print("❌ insertParty error: $e");
      return null;
    }
  }

  ///////////////////////////////////////////////////////
  static Future<List<Map<String, dynamic>>> fetchClosedPartiesForMyPlace(
    int? placeId,
  ) async {
    try {
      placeId = await SupabaseServicePlaces.getMyPlaceId();
      if (placeId == null) return [];

      final res = await supabase
          .from('parties')
          .select('id, name_party, date_started, date_closed')
          .eq('place_id', placeId)
          .eq('active', false)
          .order('date_closed', ascending: false);

      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      print("❌ fetchClosedPartiesForMyPlace error: $e");
      return [];
    }
  }

  ///////////////////////////////////////////////////////
  static Future<List<Map<String, dynamic>>> fetchClosedPartiesForPlace(
    int placeId,
  ) async {
    final res = await supabase
        .from('parties')
        .select()
        .eq('place_id', placeId)
        .eq('active', false)
        .order('date_closed', ascending: false);

    return List<Map<String, dynamic>>.from(res);
  }
}
