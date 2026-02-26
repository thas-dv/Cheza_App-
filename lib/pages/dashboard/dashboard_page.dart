// ignore_for_file: invalid_use_of_protected_member

import 'dart:async';
import 'dart:ui';

import 'package:cheza_app/pages/dashboard/promotion_tab.dart';
import 'package:cheza_app/providers/posts_provider.dart';
import 'package:cheza_app/realtime/dashboard_realtime_controller.dart';
import 'package:cheza_app/pages/dashboard/tabs/history_tab.dart';
import 'package:cheza_app/pages/dashboard/tabs/parties_tab.dart';
import 'package:cheza_app/pages/dashboard/tabs/settings_tab.dart';
import 'package:cheza_app/providers/active_party_provider.dart';
import 'package:cheza_app/providers/dashboard_providers.dart';
import 'package:cheza_app/providers/party_providers.dart'
    hide DashboardStats, dashboardStatsProvider;
import 'package:cheza_app/core/storage/local_party_storage.dart';
import 'package:marquee/marquee.dart';
import 'package:cheza_app/services/supabase_network_service.dart';
import 'package:cheza_app/services/supabase_service_admin.dart';
import 'package:cheza_app/services/supabase_service_clientel.dart';
import 'package:cheza_app/services/supabase_service_notes.dart';
import 'package:cheza_app/services/supabase_service_parties.dart';
import 'package:cheza_app/services/supabase_service_places.dart';
import 'package:cheza_app/services/supabase_service_poste.dart';
import 'package:cheza_app/themes/app_colors.dart';
import 'package:cheza_app/widgets/network_aware_wrapper.dart';
import 'package:cheza_app/widgets/network_error.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'tabs/clientele_tab.dart';
import 'tabs/menu_tab.dart';

import 'tabs/posts_tab.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  bool isOpen = false;

  DateTime? selectedOpenTime;
  DateTime? selectedCloseTime;
  int lastKnownClienteleCount = 0;
  int postsCount = 0;

  final DashboardRealtimeController _realtimeController =
      DashboardRealtimeController();

  int notesCount = 0;
  int engagementCount = 0;
  bool loadingDashboard = true;
  bool networkError = false;
  int? _currentPartyId;
  String placeName = "Nom du Lieu";
  String partyName = "";
  // String? placePhotoUrl;
  int? activePartyId;
  bool isClosing = false;
  int? placeId;
  int selectedIndex = 0;

  late StreamSubscription<bool> _networkSub;

  @override
  void initState() {
    super.initState();
    _loadMyPlace();

    _networkSub = NetworkService.connectionStream.listen((isConnected) async {
      if (isConnected && mounted) {
        debugPrint("🔄 Internet back → refresh dashboard");
        await refreshDashboard();
      }
    });
  }

  @override
  void dispose() {
    _networkSub.cancel();
    _realtimeController.dispose();
    super.dispose();
  }

  // ================= FORMAT =================
  String _formatDateFR(DateTime dt) =>
      "${dt.day.toString().padLeft(2, '0')}/"
      "${dt.month.toString().padLeft(2, '0')}/"
      "${dt.year}";
  //////////////////////////////////////////////////////
  String _formatHourFR(DateTime dt) =>
      "${dt.hour.toString().padLeft(2, '0')} : "
      "${dt.minute.toString().padLeft(2, '0')} : "
      "${dt.second.toString().padLeft(2, '0')} ";

  String _formatDateTimeFR(DateTime dt) {
    return "${_formatDateFR(dt)}  —  ${_formatHourFR(dt)}";
  }

  //////////////////////////////////////////////////////////

  ////////////////////////////////////////////////

  // ================= PICKER =================
  Future<DateTime?> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date == null) return null;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return null;

    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  /////////////////////////////////////////////////////////////////
  //Ecoute en temps réel

  ////////////////////////////////////////////

  //////////////////////////////////////////////////////
  ///Rechargement des clients

  ///////////////////Arrêter proprement l'ecoute

  ////////////////////////////////////////////////////////////////

  Future<void> _loadDashboardStats() async {
    // 🛑 Capture locale IMMÉDIATE
    final int? partyId = activePartyId;

    if (partyId == null) return;

    try {
      final posts = await SupabaseServicePoste.countPostsByParty(partyId);

      final notes = await SupabaseServiceNotes.countRatingsByParty(partyId);

      final engagement = await SupabaseServiceNotes.countEngagementByParty(
        partyId,
      );

      if (!mounted) return;

      // 🔁 Vérification post-await (IMPORTANT)
      if (activePartyId != partyId) return;

      setState(() {
        postsCount = posts;
        notesCount = notes;
        engagementCount = engagement;
      });
    } catch (_) {
      // 🧼 SILENCE (jamais de crash UI)
    }
  }

  // ================= CHARGER LES INFOS DU LIEU =================

  Future<void> _loadMyPlace() async {
    if (!mounted) return;

    setState(() {
      loadingDashboard = true;
      networkError = false;
    });

    try {
      final session = await SupabaseServiceAdmin.fetchMyAdminProfile();
      if (session == null) {
        throw Exception("Session admin introuvable");
      }

      final pid = session['place_id'];
      if (pid == null) {
        throw Exception("Place ID introuvable");
      }

      placeId = pid;

      final place = await SupabaseServicePlaces.fetchMyPlaceDetails(pid);
      if (place == null) {
        throw Exception("Détails du lieu introuvables");
      }

      if (!mounted) return;

      // setState(() {
      //   placeName = place['name'] ?? placeName;
      //   placePhotoUrl = place['photo_url'];
      // });
      setState(() {
        placeName = place['name'] ?? placeName;
      });

      ref.read(placePhotoProvider.notifier).state = place['photo_url'];
      // ⚠️ CET APPEL PEUT LANCER UNE ERREUR
      await _loadActiveParty();
    } catch (e) {
      debugPrint("❌ DASHBOARD LOAD ERROR: $e");

      if (!mounted) return;
      setState(() {
        networkError = true;
      });
    } finally {
      // ✅ TOUJOURS exécuté (succès OU erreur)
      if (!mounted) return;
      setState(() {
        loadingDashboard = false;
      });
    }
  }

  Future<void> _refreshClienteleCount() async {
    if (_currentPartyId == null) return;

    // 🔒 Ne jamais refresh sans internet
    if (!NetworkService.isConnected) return;

    final count = await SupabaseServiceClientel.countClienteleByParty(
      _currentPartyId!,
    );

    if (!mounted) return;

    setState(() {
      lastKnownClienteleCount = count;
    });
  }

  Future<void> _loadActiveParty() async {
    try {
      if (placeId == null) return;

      final party = await SupabaseServiceParties.fetchActivePartyForMyPlace(
        placeId!,
      );

      if (!mounted) return;

      // ❌ Aucune fête active
      if (party == null) {
        _realtimeController.dispose();

        ref.read(activePartyIdProvider.notifier).state = null;
        ref.read(dashboardStatsProvider.notifier).state = null;
        ref.read(clienteleProvider.notifier).clear();

        setState(() {
          isOpen = false;
          activePartyId = null;
          _currentPartyId = null;
          partyName = "";
          selectedOpenTime = null;
          selectedCloseTime = null;
        });
        return;
      }

      final int partyId = party['id'];

      // ======================
      // 🔥 RIVERPOD SYNC
      // ======================
      ref.read(activePartyIdProvider.notifier).state = partyId;

      final stats = DashboardStats(
        visitors: await SupabaseServiceClientel.countClienteleByParty(partyId),
        posts: await SupabaseServicePoste.countPostsByParty(partyId),
        notes: await SupabaseServiceNotes.countRatingsByParty(partyId),
        engagement: await SupabaseServiceNotes.countEngagementByParty(partyId),
      );

      ref.read(dashboardStatsProvider.notifier).state = stats;

      ref
          .read(clienteleProvider.notifier)
          .setClients(
            await SupabaseServiceClientel.fetchClienteleData(partyId),
          );

      // ======================
      // UI LOCALE
      // ======================
      final open = DateTime.parse(party['date_started']).toLocal();
      final close = DateTime.parse(party['date_closed']).toLocal();

      setState(() {
        activePartyId = partyId;
        _currentPartyId = partyId;
        isOpen = true;
        partyName = party['name_party'];
        selectedOpenTime = open;
        selectedCloseTime = close;
      });
      // ======================
      // 🔥 REALTIME START
      // ======================
      // _realtimeController.startAttendanceRealtime(
      //   partyId: partyId,
      //   reloadClientele: () async {
      //     final data = await SupabaseServiceClientel.fetchClienteleData(
      //       partyId,
      //     );
      //     ref.read(clienteleProvider.notifier).setClients(data);
      //   },
      //   refreshClienteleCount: _refreshClienteleCount,
      // );
      // ======================
      // 🔥 REALTIME START
      // ======================

      // 👥 VISITEURS (ATTENDANCE)
      _realtimeController.startAttendanceRealtime(
        partyId: partyId, // partyId est NON NULL ici
        reloadClientele: () async {
          final data = await SupabaseServiceClientel.fetchClienteleData(
            partyId,
          );

          ref.read(clienteleProvider.notifier).setClients(data);
        },
        refreshClienteleCount: _refreshClienteleCount,
      );

      // 📝 DASHBOARD (POSTS / STATS)
      _realtimeController.startDashboardRealtime(
        partyId: partyId,
        refreshDashboardStats: () async {
          await ref.read(dashboardStatsProvider.notifier).load(partyId);
        },
      );

      // 🛟 FALLBACK (SÉCURITÉ)
      _realtimeController.startFallbackResync(
        partyId: partyId,
        reloadClientele: () async {
          final data = await SupabaseServiceClientel.fetchClienteleData(
            partyId,
          );

          ref.read(clienteleProvider.notifier).setClients(data);
        },
        refreshClienteleCount: _refreshClienteleCount,
        refreshDashboardStats: () async {
          await ref.read(dashboardStatsProvider.notifier).load(partyId);
        },
      );
    } catch (e) {
      debugPrint("❌ _loadActiveParty ERROR: $e");
    }
  }

  // ===== AJOUTE CETTE MÉTHODE DANS _DashboardPageState =====
  Future<void> refreshDashboard() async {
    await _loadActiveParty();
    await _loadDashboardStats();
  }

  // ================= DIALOG FERMETURE DU LIEU =================
  Future<void> updateCloseTimeDialog() async {
    DateTime? tempCloseTime = selectedCloseTime;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setLocalState) {
            return Dialog(
              backgroundColor: const Color(0xFF1E1E1E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: SizedBox(
                width: 380,
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Modifier l'heure de fermeture",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 16),

                      _dateRow(
                        label: "Nouvelle fermeture",
                        value: tempCloseTime == null
                            ? "Choisir la date & l'heure"
                            : _formatDateTimeFR(tempCloseTime!),
                        onTap: () async {
                          final dt = await _pickDateTime();
                          if (dt != null) {
                            setLocalState(() => tempCloseTime = dt);
                          }
                        },
                      ),

                      const SizedBox(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Annuler"),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: isClosing
                                ? null
                                : () async {
                                    if (tempCloseTime == null ||
                                        activePartyId == null) {
                                      return;
                                    }

                                    setLocalState(() => isClosing = true);

                                    try {
                                      await SupabaseServiceParties.closePartyById(
                                        partyId: activePartyId!,
                                        dateClosed: tempCloseTime!,
                                      );
                                      await LocalPartyStorage.setPartyOpen(
                                        false,
                                      );
                                      setState(() {
                                        isOpen = false;
                                        activePartyId = null;
                                        partyName = "";
                                        selectedOpenTime = null;
                                        selectedCloseTime = null;
                                        // clienteleCount = 0;
                                      });

                                      Navigator.pop(context);
                                    } finally {
                                      setLocalState(() => isClosing = false);
                                    }
                                  },
                            child: isClosing
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text("Valider"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ================= DIALOG OUVERTURE DU LIEU =================
  Future<void> openPartyDialog() async {
    DateTime? tempOpenTime;
    DateTime? tempCloseTime;
    String tempPartyName =
        "Soirée du ${DateTime.now().day}/${DateTime.now().month}";

    await showDialog(
      context: context,
      builder: (_) {
        bool isCreatingParty = false;

        return StatefulBuilder(
          builder: (context, setLocalState) {
            return Dialog(
              backgroundColor: const Color(0xFF1E1E1E),
              insetPadding: const EdgeInsets.symmetric(horizontal: 40),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: SizedBox(
                width: 420, // largeur contrôlée
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Ouvrir le lieu",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 14),

                      TextField(
                        controller: TextEditingController(text: tempPartyName),
                        decoration: const InputDecoration(
                          labelText: "Nom de la fête",
                          isDense: true,
                          filled: true,
                        ),
                        onChanged: (v) => tempPartyName = v,
                      ),

                      const SizedBox(height: 12),

                      // ---------------- OPEN TIME ----------------
                      _dateRow(
                        label: "Ouverture",
                        value: tempOpenTime == null
                            ? "Choisir"
                            : _formatDateTimeFR(tempOpenTime!),
                        onTap: () async {
                          final dt = await _pickDateTime();
                          if (dt != null) {
                            setLocalState(() => tempOpenTime = dt);
                          }
                        },
                      ),

                      const SizedBox(height: 8),

                      // ---------------- CLOSE TIME ----------------
                      _dateRow(
                        label: "Fermeture",
                        value: tempCloseTime == null
                            ? "Choisir"
                            : _formatDateTimeFR(tempCloseTime!),
                        onTap: () async {
                          final dt = await _pickDateTime();
                          if (dt != null) {
                            setLocalState(() => tempCloseTime = dt);
                          }
                        },
                      ),

                      const SizedBox(height: 18),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Annuler"),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: isCreatingParty
                                ? null
                                : () async {
                                    setLocalState(() => isCreatingParty = true);

                                    try {
                                      if (tempOpenTime == null ||
                                          tempCloseTime == null) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              "Veuillez choisir l'heure d'ouverture et de fermeture",
                                            ),
                                          ),
                                        );
                                        return;
                                      }

                                      if (!_isValidOpenClose(
                                        tempOpenTime!,
                                        tempCloseTime!,
                                      )) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              "L'heure de fermeture doit être après l'heure d'ouverture",
                                            ),
                                          ),
                                        );
                                        return;
                                      }

                                      if (placeId == null) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text("Lieu introuvable"),
                                          ),
                                        );
                                        return;
                                      }

                                      // fermer uniquement les fêtes expirées (sécurité)

                                      // ✅ CRÉATION DE LA FÊTE
                                      final partyId =
                                          await SupabaseServiceParties.insertParty(
                                            placeId: placeId!,
                                            nameParty: tempPartyName,
                                            dateStarted: tempOpenTime!,
                                            dateClosed: tempCloseTime!,
                                          );

                                      if (partyId == null) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              "Erreur lors de la création de la fête",
                                            ),
                                          ),
                                        );
                                        return;
                                      }
                                      await LocalPartyStorage.setPartyOpen(
                                        true,
                                      );
                                      // ✅ MISE À JOUR UI
                                      setState(() {
                                        isOpen = true;
                                        activePartyId = partyId;
                                        _currentPartyId =
                                            partyId; // ✅ OBLIGATOIRE
                                        partyName = tempPartyName;
                                        selectedOpenTime = tempOpenTime;
                                        selectedCloseTime = tempCloseTime;
                                      });

                                      Navigator.pop(context);
                                    } finally {
                                      setLocalState(
                                        () => isCreatingParty = false,
                                      );
                                    }
                                  },

                            child: isCreatingParty
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text("Valider"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  //Ligne date
  Widget _dateRow({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 90,
          child: Text(label, style: const TextStyle(fontSize: 14)),
        ),
        Expanded(
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(value, style: const TextStyle(fontSize: 13)),
            ),
          ),
        ),
      ],
    );
  }

  //fonction de valudation de l'heur d'ouverture et de fermeture
  bool _isValidOpenClose(DateTime open, DateTime close) {
    // ❌ Fermeture doit être après ouverture
    if (!close.isAfter(open)) return false;

    // ❌ Interdire exactement la même minute
    final sameMinute =
        open.year == close.year &&
        open.month == close.month &&
        open.day == close.day &&
        open.hour == close.hour &&
        open.minute == close.minute;

    if (sameMinute) return false;

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isLarge = constraints.maxWidth > 900;
        // =======================
        // RIVERPOD (LEGACY)
        // =======================

        // // Party active
        // final int? partyId = ref.watch(activePartyIdProvider);

        // // Stats dashboard
        // final DashboardStats? stats = ref.watch(dashboardStatsProvider);

        // // Clientèle
        // final clients = ref.watch(clienteleProvider);
        ref.watch(activePartyIdProvider);
        final DashboardStats? stats = ref.watch(dashboardStatsProvider);
        final clients = ref.watch(clienteleProvider);
        final placePhotoUrl = ref.watch(placePhotoProvider);
        // WidgetsBinding.instance.addPostFrameCallback((_) {
        //   if (mounted && clienteleCount != clients.length) {
        //     setState(() => clienteleCount = clients.length);
        //   }
        // });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;

          // ✅ on mémorise UNIQUEMENT quand online
          if (NetworkService.isConnected &&
              lastKnownClienteleCount != clients.length) {
            setState(() {
              lastKnownClienteleCount = clients.length;
            });
          }
        });

        // Sync UI
        if (stats != null) {
          postsCount = stats.posts;
          notesCount = stats.notes;
          engagementCount = stats.engagement;
        }

        return PopScope(
          canPop: selectedIndex == 0,
          onPopInvoked: (didPop) {
            if (!didPop && selectedIndex != 0) {
              setState(() {
                selectedIndex = 0; // 🔥 Retour à Accueil
              });
            }
          },
          child: NetworkToastWrapper(
            child: Scaffold(
              backgroundColor: const Color(0xFF0F0F0F),
              drawer: Drawer(
                child: Container(
                  color: const Color(0xFF1A1A1A),
                  padding: const EdgeInsets.only(top: 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _menuItem("Accueil", Icons.home, 0, isLarge),
                      _menuItem(
                        "Historiques",
                        Icons.history_outlined,
                        1,
                        isLarge,
                      ),
                      _menuItem("Membres", Icons.person, 2, isLarge),
                      _menuItem("Promotions", Icons.propane_tank, 3, isLarge),
                      _menuItem("Menus", Icons.menu_book, 4, isLarge),
                      const Spacer(),
                      Row(
                        children: [
                          _menuItem("", Icons.settings, 5, isLarge),

                          _menuItem("", Icons.exit_to_app, 9, isLarge),
                          _actionButton(),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              body: Row(
                children: [
                  // ===== DRAWER FIXE DESKTOP =====
                  if (isLarge)
                    Container(
                      width: 250,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF0F172A), Color(0xFF111827)],
                        ),
                      ),
                      padding: const EdgeInsets.only(top: 30),
                      child: Column(
                        children: [
                          /// ===== LOGO DU LIEU =====
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: Colors.grey.shade800,
                                  ),
                                  child: placePhotoUrl == null
                                      ? const Icon(
                                          Icons.place,
                                          color: Colors.white,
                                        )
                                      : ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          child: Image.network(
                                            placePhotoUrl,
                                            key: ValueKey(placePhotoUrl),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    placeName,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      height: 1.2,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 40),

                          _menuItem("Accueil", Icons.home, 0, isLarge),
                          _menuItem(
                            "Historiques",
                            Icons.history_outlined,
                            1,
                            isLarge,
                          ),
                          _menuItem("Membres", Icons.person, 2, isLarge),
                          _menuItem(
                            "Promotions",
                            Icons.propane_tank,
                            3,
                            isLarge,
                          ),
                          _menuItem("Menus", Icons.menu_book, 4, isLarge),
                          const Spacer(),
                          _menuItem("Paramètres", Icons.settings, 5, isLarge),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),

                  // ===== CONTENU PRINCIPAL =====
                  Expanded(
                    child: Stack(
                      children: [
                        /// Background image plein écran
                        Positioned.fill(
                          child: Image.asset(
                            "assets/images/fondprincipal.png",
                            fit: BoxFit.cover,
                          ),
                        ),

                        /// Overlay bleu nuit
                        Positioned.fill(
                          child: Container(
                            color: const Color(0xFF0B1120).withOpacity(0.75),
                          ),
                        ),

                        Column(
                          children: [
                            _topNavigationBar(isLarge),

                            /// ===== LIGNE SEPARATRICE =====
                            Container(
                              height: 1,
                              width: double.infinity,
                              color: Colors.white.withOpacity(0.08),
                            ),

                            Expanded(child: _buildSelectedPage()),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Widget _headerBar(bool isLarge) {
  //   return Container(
  //     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  //     color: const Color(0xFF1E1E1E),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         // ================= LIGNE 1 =================

  //         // ================= LIGNE 2 (SEULEMENT SI OUVERT) =================
  //         if (isOpen) ...[
  //           Row(
  //             children: [
  //               // 🟢 OUVERT — GAUCHE
  //               Expanded(
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.center,
  //                   children: [
  //                     const Text(
  //                       "Ouverture",
  //                       textAlign: TextAlign.center,
  //                       style: TextStyle(
  //                         color: Colors.green,
  //                         fontSize: 15,
  //                         fontWeight: FontWeight.bold,
  //                       ),
  //                     ),
  //                     const SizedBox(height: 4),
  //                     Text(
  //                       " ${_formatHourFR(selectedOpenTime!)}",
  //                       textAlign: TextAlign.center,
  //                       style: const TextStyle(fontSize: 13),
  //                     ),
  //                     Text(
  //                       _formatDateFR(selectedOpenTime!),
  //                       textAlign: TextAlign.center,
  //                       style: const TextStyle(fontSize: 13),
  //                     ),
  //                   ],
  //                 ),
  //               ),

  //               // 🔹 SÉPARATION CENTRALE
  //               Container(
  //                 width: 0.5,
  //                 height: 40,
  //                 margin: const EdgeInsets.symmetric(horizontal: 12),
  //                 color: Colors.grey.withOpacity(0.4),
  //               ),

  //               // FERMÉ — DROITE
  //               Expanded(
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.center,
  //                   children: [
  //                     const Text(
  //                       "Fermeture",
  //                       textAlign: TextAlign.center,
  //                       style: TextStyle(
  //                         color: Colors.red,
  //                         fontSize: 15,
  //                         fontWeight: FontWeight.bold,
  //                       ),
  //                     ),
  //                     const SizedBox(height: 4),
  //                     Text(
  //                       _formatHourFR(selectedCloseTime!),
  //                       textAlign: TextAlign.center,
  //                       style: const TextStyle(fontSize: 13),
  //                     ),
  //                     Text(
  //                       _formatDateFR(selectedCloseTime!),
  //                       textAlign: TextAlign.center,
  //                       style: const TextStyle(fontSize: 13),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ],
  //       ],
  //     ),
  //   );
  // }

  // Bouton Ouvrir/Fermer
  Widget _actionButton() {
    if (!isOpen) {
      return Text("");
    } else {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.bacgroundRed,
        ),
        onPressed: updateCloseTimeDialog,
        child: const Text("Fermer"),
      );
    }
  }

  // =============================================================
  // MENU GAUCHE — ITEM CLIQUABLE
  // =============================================================
  Widget _menuItem(String title, IconData icon, int index, bool isLarge) {
    final bool selected = selectedIndex == index;

    return InkWell(
      onTap: () {
        if (selectedIndex == index) return;

        setState(() {
          selectedIndex = index;
        });

        // fermer seulement le drawer mobile
        if (!isLarge) {
          Navigator.pop(context);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        color: selected ? const Color(0xFF262626) : Colors.transparent,
        child: Row(
          children: [
            Icon(icon, color: selected ? Colors.purple : Colors.grey, size: 22),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                color: selected ? Colors.white : Colors.grey.shade400,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
  // =============================================================
  // CONTENU SELON ONGLET SELECTIONNÉ
  // =============================================================

  Widget _buildSelectedPage() {
    if (loadingDashboard) {
      return const Center(child: CircularProgressIndicator());
    }

    if (networkError) {
      return NetworkErrorView(
        onRetry: () {
          _loadMyPlace(); // 🔁 recharge TOUT
        },
      );
    }

    switch (selectedIndex) {
      case 0:
        return _homePage();

      case 1:
        return HistoryTab(placeId: placeId);

      case 2:
        return const Text("Membres");

      case 3:
  return PromotionPage(
    placeId: placeId,
    activePartyId: activePartyId,
    placeName: placeName,
  );

      case 4:
        return const MenuTab();

      case 5:
        return const SettingsTab();

      case 6:
        if (_currentPartyId == null) {
          return const Center(
            child: Text(
              "Aucune fête active",
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        return ClienteleTab(
          key: ValueKey(_currentPartyId),
          partyId: _currentPartyId,
          onBack: () => setState(() => selectedIndex = 0),

          // 🔥 LES DEUX LIGNES CRITIQUES
          cachedCount: lastKnownClienteleCount,
          isOnline: NetworkService.isConnected,
        );

      case 7:
        if (activePartyId == null) {
          return Center(
            child: Text(
              "Aucune fête active",
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        // return PostsTab(
        //   partyId: activePartyId!,
        //   onBack: () => setState(() => selectedIndex = 0),
        // );
        return PostsTab(
          key: ValueKey(activePartyId), // ⭐ OBLIGATOIRE

          onBack: () => setState(() => selectedIndex = 0),
        );

      case 8:
        return PartiesTab(onBack: () => setState(() => selectedIndex = 0));

      case 9:
        return const Text("Engagements");

      default:
        return const Center(
          child: Text(
            "Page indisponible",
            style: TextStyle(color: Colors.grey),
          ),
        );
    }
  }

  // =============================================================
  // PAGE D’ACCUEIL
  // =============================================================
  // Widget _homePage() {
  //   final int? partyId = ref.watch(activePartyIdProvider);

  //   final postsState = partyId != null
  //       ? ref.watch(postsProvider(partyId))
  //       : null;

  //   // 🔥 COUNT FINAL (ONLINE → serveur, OFFLINE → cache)
  //   final int effectivePostsCount = (postsCount > 0)
  //       ? postsCount
  //       : (postsState?.posts.length ?? 0);
  //   return SingleChildScrollView(
  //     padding: const EdgeInsets.all(30),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         // --- LIGNE DES 4 CARDS (STATISTIQUES) ---
  //         Row(
  //           children: [
  //             _bigStatCard(
  //               "Visiteurs",
  //               value: lastKnownClienteleCount,
  //               Icons.group,
  //               Colors.blue,
  //               onTap: () {
  //                 debugPrint(
  //                   "👆 TAP Visiteurs | isOpen=$isOpen | count=$lastKnownClienteleCount",
  //                 );
  //                 setState(() => selectedIndex = 6);
  //               },
  //             ),
  //             // _bigStatCard(
  //             //   "Posts",
  //             //   value: postsCount,
  //             //   Icons.photo,
  //             //   Colors.purple,
  //             //   onTap: () => setState(() => selectedIndex = 7),
  //             // ),
  //             _bigStatCard(
  //               "Posts",
  //               value: effectivePostsCount, // ✅ fallback offline
  //               Icons.photo,
  //               Colors.purple,
  //               onTap: () {
  //                 debugPrint(
  //                   "📝 TAP Posts | online=${NetworkService.isConnected} | count=$effectivePostsCount",
  //                 );
  //                 setState(() => selectedIndex = 7);
  //               },
  //             ),
  //             _bigStatCard(
  //               "Notes",
  //               value: notesCount,
  //               Icons.star,
  //               Colors.orange,
  //               onTap: () => setState(() => selectedIndex = 8),
  //             ),

  //             _bigStatCard(
  //               "Engagement",
  //               value: engagementCount,
  //               Icons.show_chart,
  //               Colors.green,
  //               onTap: () => setState(() => selectedIndex = 9),
  //             ),
  //           ],
  //         ),

  //         const SizedBox(height: 25),

  //         // --- DESCRIPTION DU LIEU ---
  //         _infoCard(
  //           title: "Description du lieu",
  //           content:
  //               "Bienvenue dans votre espace de gestion.\n\n"
  //               "Ici vous pouvez suivre l’activité du lieu, gérer vos clients, "
  //               "vérifier les posts, analyser les notes et ajuster les paramètres.\n\n"
  //               "Ajoutez ici la vraie description de votre établissement.",
  //         ),

  //         const SizedBox(height: 20),

  //         // --- INFO DU LIEU ---
  //         _infoCard(
  //           title: "Informations",
  //           content:
  //               "📍 Conakry, Guinée\n"
  //               "🏢 Lieu créé depuis 3 ans\n"
  //               "🕒 Horaires configurables dans l’en-tête",
  //         ),
  //       ],
  //     ),
  //   );
  // }
  Widget _homePage() {
    if (!isOpen) {
      return _closedPlaceView(); // 👈 NOUVEAU VISUEL
    }

    // 🔥 TON CODE EXISTANT (RIEN TOUCHÉ)
    final int? partyId = ref.watch(activePartyIdProvider);

    final postsState = partyId != null
        ? ref.watch(postsProvider(partyId))
        : null;

    final int effectivePostsCount = (postsCount > 0)
        ? postsCount
        : (postsState?.posts.length ?? 0);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _bigStatCard(
                "Visiteurs",
                value: lastKnownClienteleCount,
                Icons.group,
                Colors.blue,
                onTap: () => setState(() => selectedIndex = 6),
              ),
              _bigStatCard(
                "Posts",
                value: effectivePostsCount,
                Icons.photo,
                Colors.purple,
                onTap: () => setState(() => selectedIndex = 7),
              ),
              _bigStatCard(
                "Notes",
                value: notesCount,
                Icons.star,
                Colors.orange,
                onTap: () => setState(() => selectedIndex = 8),
              ),
              _bigStatCard(
                "Engagement",
                value: engagementCount,
                Icons.show_chart,
                Colors.green,
                onTap: () => setState(() => selectedIndex = 9),
              ),
            ],
          ),
          const SizedBox(height: 25),
          _infoCard(
            title: "Description du lieu",
            content:
                "Bienvenue dans votre espace de gestion.\n\n"
                "Ici vous pouvez suivre l’activité du lieu, gérer vos clients, "
                "vérifier les posts, analyser les notes et ajuster les paramètres.",
          ),
          const SizedBox(height: 20),
          _infoCard(
            title: "Informations",
            content:
                "📍 Conakry, Guinée\n"
                "🏢 Lieu créé depuis 3 ans\n"
                "🕒 Horaires configurables dans l’en-tête",
          ),
        ],
      ),
    );
  }

  //////////////////////////////////////

  Widget _closedPlaceView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                placeName,
                style: const TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 15),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFB23B3B),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  "Fermé",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 60),

          Container(
            width: 500,
            padding: const EdgeInsets.symmetric(vertical: 60),
            decoration: BoxDecoration(
              color: AppColors.backgroundDark,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6A5AE0), Color(0xFFB44CFF)],
                  ),
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFB44CFF).withOpacity(0.6),
                      blurRadius: 30,
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: openPartyDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 80,
                      vertical: 24,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                  child: const Text(
                    "Ouvrir le Lieu",
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  ///////////////////////////////////////////////

  // Widget _topNavigationBar(bool isLarge) {
  //   final placePhotoUrl = ref.watch(placePhotoProvider);
  //   return Container(
  //     width: double.infinity,
  //     padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 35),
  //     child: Row(
  //       crossAxisAlignment: CrossAxisAlignment.center,
  //       children: [
  //         /// ===== GAUCHE : MENU + LOGO (MOBILE) =====
  //         if (!isLarge) ...[
  //           Builder(
  //             builder: (context) => IconButton(
  //               icon: const Icon(Icons.menu, color: Colors.white),
  //               onPressed: () {
  //                 Scaffold.of(context).openDrawer();
  //               },
  //             ),
  //           ),
  //           const SizedBox(width: 8),
  //           Container(
  //             width: 60,
  //             height: 40,
  //             decoration: BoxDecoration(
  //               borderRadius: BorderRadius.circular(12),
  //               color: Colors.grey.shade800,
  //             ),
  //             // child: placePhotoUrl == null
  //             //     ? const Icon(Icons.place, color: Colors.white)
  //             //     : ClipRRect(
  //             //         borderRadius: BorderRadius.circular(12),
  //             //         child: Image.network(placePhotoUrl!, fit: BoxFit.cover),
  //             //       ),
  //             child: (placePhotoUrl == null || placePhotoUrl.isEmpty)
  //                 ? const Icon(Icons.home_filled, color: Colors.white)
  //                 : ClipRRect(
  //                     borderRadius: BorderRadius.circular(12),
  //                     child: Image.network(
  //                       placePhotoUrl,
  //                       fit: BoxFit.cover,
  //                       errorBuilder: (_, __, ___) {
  //                         return const Icon(Icons.place, color: Colors.white);
  //                       },
  //                     ),
  //                   ),
  //           ),
  //         ],

  //         /// pousse le contenu droit vers la droite
  //         const Spacer(),
  //         if (selectedCloseTime != null && selectedOpenTime != null) ...[
  //           SizedBox(
  //             height: 30,
  //             width: 170,
  //             child: Marquee(
  //               text:
  //                   "🟢 Ouverture ${_formatHourFR(selectedOpenTime!)} ${_formatDateFR(selectedOpenTime!)}     |     "
  //                   "🔴 Fermeture ${_formatHourFR(selectedCloseTime!)} ${_formatDateFR(selectedCloseTime!)}",
  //               style: const TextStyle(color: Colors.white, fontSize: 14),
  //               scrollAxis: Axis.horizontal,
  //               blankSpace: 40,
  //               velocity: 40,
  //               pauseAfterRound: const Duration(seconds: 1),
  //               startPadding: 10,
  //               accelerationDuration: const Duration(milliseconds: 500),
  //               accelerationCurve: Curves.easeIn,
  //               decelerationDuration: const Duration(milliseconds: 500),
  //               decelerationCurve: Curves.easeOut,
  //             ),
  //           ),
  //           const SizedBox(width: 20),
  //         ],

  //         /// ===== STATUT + ADMIN =====
  //         Row(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             Text(
  //               isOpen ? "Ouvert" : "",
  //               style: TextStyle(
  //                 color: isOpen ? Colors.green : Colors.red,
  //                 fontSize: 20,
  //                 fontWeight: FontWeight.bold,
  //               ),
  //             ),
  //             const SizedBox(width: 8),
  //             const CircleAvatar(radius: 18, backgroundColor: Colors.grey),
  //             const SizedBox(width: 8),
  //             _actionButton(),
  //           ],
  //         ),
  //       ],
  //     ),
  //   );
  // }
  Widget _topNavigationBar(bool isLarge) {
    final placePhotoUrl = ref.watch(placePhotoProvider);

    return SafeArea(
      bottom: false, // protège uniquement le haut
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            /// ===== GAUCHE : MENU + LOGO (MOBILE) =====
            if (!isLarge) ...[
              Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 60,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey.shade800,
                ),
                child: (placePhotoUrl == null || placePhotoUrl.isEmpty)
                    ? const Icon(Icons.home_filled, color: Colors.white)
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          placePhotoUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) {
                            return const Icon(Icons.place, color: Colors.white);
                          },
                        ),
                      ),
              ),
            ],

            const Spacer(),

            /// ===== MARQUEE HEURES =====
            if (selectedCloseTime != null && selectedOpenTime != null) ...[
              SizedBox(
                height: 30,
                width: 170,
                child: Marquee(
                  text:
                      "🟢 Ouverture ${_formatHourFR(selectedOpenTime!)} ${_formatDateFR(selectedOpenTime!)}     |     "
                      "🔴 Fermeture ${_formatHourFR(selectedCloseTime!)} ${_formatDateFR(selectedCloseTime!)}",
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  scrollAxis: Axis.horizontal,
                  blankSpace: 40,
                  velocity: 40,
                  pauseAfterRound: const Duration(seconds: 1),
                  startPadding: 10,
                  accelerationDuration: const Duration(milliseconds: 500),
                  accelerationCurve: Curves.easeIn,
                  decelerationDuration: const Duration(milliseconds: 500),
                  decelerationCurve: Curves.easeOut,
                ),
              ),
              const SizedBox(width: 20),
            ],

            /// ===== STATUT + ADMIN =====
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isOpen ? "Ouvert" : "",
                  style: TextStyle(
                    color: isOpen ? Colors.green : Colors.red,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                const CircleAvatar(radius: 18, backgroundColor: Colors.grey),
                const SizedBox(width: 8),
                _actionButton(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /////////////////////////////////////
  // =============================================================
  //   CARD STATISTIQUE
  // =============================================================
  Widget _bigStatCard(
    String title,
    IconData icon,
    Color color, {
    required int value,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Opacity(
        opacity: isOpen ? 1 : 0.4,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: isOpen ? onTap : null, // désactivé si fermé
          child: Container(
            height: 120,
            margin: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 36, color: isOpen ? color : Colors.grey),
                const SizedBox(height: 6),
                Text(
                  isOpen ? value.toString() : "0",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                Text(title, style: const TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =============================================================
  //   CARD D’INFORMATION (DESCRIPTION / INFOS)
  // =============================================================
  Widget _infoCard({required String title, required String content}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: const TextStyle(fontSize: 15, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
