import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseServicePromotion {
  static final SupabaseClient _client = Supabase.instance.client;

  // ==========================================================
  // 🔹 GET PROMOS BY PARTY
  // ==========================================================
  static Future<List<Map<String, dynamic>>> fetchPromotionsByParty(
    int partyId,
  ) async {
    try {
      final response = await _client
          .from('promo_party')
          .select('''
            id,
            date_expire,
            promos (
              id,
              promo_desc,
              limite
            )
          ''')
          .eq('party_id', partyId)
          .timeout(const Duration(seconds: 15));

      return List<Map<String, dynamic>>.from(response);
    } on TimeoutException {
      print("⏱️ fetchPromotionsByParty timeout");
      return [];
    } catch (e) {
      print("❌ fetchPromotionsByParty error: $e");
      return [];
    }
  }

  // ==========================================================
  // 🔹 INSERT PROMO
  // ==========================================================
  static Future<bool> insertPromotion({
    required int partyId,
    required String description,
    required int limite,
    required DateTime expireDate,
  }) async {
    try {
      // 1️⃣ Insert promo
      final promo = await _client
          .from('promos')
          .insert({'promo_desc': description, 'limite': limite})
          .select()
          .single()
          .timeout(const Duration(seconds: 15));

      if (promo['id'] == null) {
        return false;
      }

      // 2️⃣ Link promo to party
      await _client
          .from('promo_party')
          .insert({
            'party_id': partyId,
            'promo_id': promo['id'],
            'date_expire': expireDate.toIso8601String(),
          })
          .timeout(const Duration(seconds: 15));

      return true;
    } on TimeoutException {
      print("⏱️ insertPromotion timeout");
      return false;
    } catch (e) {
      print("❌ insertPromotion error: $e");
      return false;
    }
  }

  // ==========================================================
  // 🔹 UPDATE PROMO
  // ==========================================================
  static Future<bool> updatePromotion({
    required int promoId,
    required String description,
    required int limite,
  }) async {
    try {
      await _client
          .from('promos')
          .update({'promo_desc': description, 'limite': limite})
          .eq('id', promoId)
          .timeout(const Duration(seconds: 15));

      return true;
    } on TimeoutException {
      print("⏱️ updatePromotion timeout");
      return false;
    } catch (e) {
      print("❌ updatePromotion error: $e");
      return false;
    }
  }

  // ==========================================================
  // 🔹 DELETE PROMO
  // ==========================================================
  static Future<bool> deletePromotion(int promoId) async {
    try {
      await _client
          .from('promo_party')
          .delete()
          .eq('promo_id', promoId)
          .timeout(const Duration(seconds: 15));

      await _client
          .from('promos')
          .delete()
          .eq('id', promoId)
          .timeout(const Duration(seconds: 15));

      return true;
    } on TimeoutException {
      print("⏱️ deletePromotion timeout");
      return false;
    } catch (e) {
      print("❌ deletePromotion error: $e");
      return false;
    }
  }
}
