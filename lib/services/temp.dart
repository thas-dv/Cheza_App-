// // ============================================================
//   // ======================= AUTH ===============================
//   // ============================================================



//   // ============================================================
//   //  CURRENT AUTH USER EMAIL
//   // ============================================================
 

//   // ============================================================
//   // ======================= ADMINS =============================
//   // ============================================================



//   // ============================================================
//   //  FETCH ADMINS POUR UN LIEU
//   // ============================================================


//   // ================== UPDATE ADMIN ==================
//   // ============================================================
//   //  UPDATE ADMIN PROFILE
//   // ============================================================


 
//   // ======================= PLACES =============================
//   //  FETCH PLACE COMPLET
//   // ============================================================




//   static Future<int?> insertPlace({
//     required String name,
//     required String address,
//     required String typePlace,
//     required String country,
//     double? latitude,
//     double? longitude,
//     String? photoUrl,
//   }) async {
//     try {
//       final res = await supabase
//           .from('places')
//           .insert({
//             'name': name,
//             'address': address,
//             'type_place': typePlace,
//             'country': country,
//             'latitude': latitude,
//             'longitude': longitude,
//             'photo_url': photoUrl,
//             'opened': false,
//           })
//           .select('id')
//           .single();

//       return res['id'] as int;
//     } catch (e) {
//       print("❌ insertPlace error: $e");
//       return null;
//     }
//   }
//   // ================== UPDATE PLACE ==================
//   // ============================================================
//   //  UPDATE PLACE
//   // ============================================================


//   // ============================================================
//   // ======================= PARTIES ============================
//   // ============================================================

//   static Future<bool> closeActiveParty(int placeId) async {
//     try {
//       await supabase
//           .from('parties')
//           .update({'active': false})
//           .eq('place_id', placeId)
//           .eq('active', true);

//       return true;
//     } catch (e) {
//       print("❌ closeActiveParty error: $e");
//       return false;
//     }
//   }

//   static Future<void> forceCloseAllPartiesForMyPlace() async {
//     try {
//       final placeId = await getMyPlaceId();
//       if (placeId == null) return;

//       await supabase
//           .from('parties')
//           .update({'active': false})
//           .eq('place_id', placeId)
//           .eq('active', true);
//     } catch (e) {
//       print("❌ forceCloseAllPartiesForMyPlace error: $e");
//     }
//   }

//   // ======================= CLIENTELE ==========================

//   static Future<bool> disconnectClientByAttendee(int attendeeId) async {
//     try {
//       await supabase
//           .from('parties_attandance')
//           .update({'is_present': false})
//           .eq('id', attendeeId);
//       return true;
//     } catch (_) {
//       return false;
//     }
//   }

//   //================================ TABLE POSTE ================================
//   // DELETE POST (ADMIN)
 

//   // ============================================================
//   // FETCH POSTS PAR FÊTE (classés par popularité) //
//   // ============================================================


//   // ========= FETCH DETAILS CLIENT //
//   //============================================================

 

//   // ======================= MENU ================================
//   // ============================================================
//   //  FETCH MENUS FOR PLACE (OPTIMISÉ)
//   // ============================================================

//   // ============================================================
//   //  INSERT MENU
//   // ============================================================
 
//   // ============================================================
//   //  UPDATE MENU
//   // ============================================================
