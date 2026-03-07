import 'package:cheza_app/core/ui/responsive_layout.dart' show Breakpoints;
import 'package:cheza_app/features/dashboard/data/datasources/dashboard_controller.dart';
import 'package:cheza_app/features/dashboard/presentation/pages/modern_home_widget.dart';
import 'package:cheza_app/features/dashboard/presentation/widgets/layout/dashboard_state.dart';
import 'package:cheza_app/features/dashboard/presentation/widgets/layout/sidebar.dart';
import 'package:cheza_app/features/dashboard/presentation/widgets/layout/topbar.dart';
import 'package:cheza_app/themes/app_colors.dart';
import 'package:cheza_app/widgets/network_aware_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:cheza_app/widgets/inline_page_loader.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cheza_app/features/dashboard/presentation/widgets/tabs/clientele_tab.dart';
import 'package:cheza_app/features/dashboard/presentation/widgets/tabs/note_tab.dart';
import 'package:cheza_app/features/dashboard/presentation/widgets/tabs/posts_tab.dart';
import 'package:cheza_app/services/supabase_network_service.dart';
import 'package:cheza_app/widgets/network_error.dart';
import 'package:cheza_app/features/dashboard/presentation/widgets/tabs/history_tab.dart';
import 'package:cheza_app/features/dashboard/presentation/widgets/tabs/menu_tab.dart';
import 'package:cheza_app/features/dashboard/presentation/widgets/tabs/settings_tab.dart';
import 'package:cheza_app/features/promotions/presentation/pages/promotions_page.dart';
import 'package:cheza_app/pages/login.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardPage extends ConsumerWidget {
  static const _topTabs = [0, 1, 2, 3];
  static final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>();
  const DashboardPage({super.key});
  Widget _buildSidebar(
    BuildContext context,
    WidgetRef ref,
    DashboardState state,
    bool isLarge,
    DashboardController notifier,
  ) {
    return Sidebar(
      selectedIndex: state.selectedIndex,
      onLogout: () => _logout(context, notifier, state),
      onSelect: (index) {
        if (!isLarge) {
          Navigator.of(context).pop();
        }
        ref.read(dashboardControllerProvider.notifier).setSelectedIndex(index);
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardControllerProvider);
    final notifier = ref.read(dashboardControllerProvider.notifier);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isLarge = Breakpoints.isDesktop(constraints.maxWidth);

        return WillPopScope(
          onWillPop: () async {
            if (state.selectedIndex != 0) {
              notifier.setSelectedIndex(0);
              return false;
            }
            return true;
          },
          child: NetworkToastWrapper(
            child: Scaffold(
              key: _scaffoldKey,
              backgroundColor: AppColors.background,
              drawer: !isLarge
                  ? _buildSidebar(context, ref, state, isLarge, notifier)
                  : null,
              body: Row(
                children: [
                  if (isLarge)
                    _buildSidebar(context, ref, state, isLarge, notifier),
                  Expanded(
                    child: Column(
                      children: [
                        // NOUVEL APPEL TOPBAR
                        TopBar(
                          isOpen: state.isOpen,
                          isStatusUpdating: state.isStatusUpdating,
                          isLargeScreen: isLarge,
                          selectedIndex: state.selectedIndex
                              .clamp(0, 3)
                              .toInt(),
                          onSelect: notifier.setSelectedIndex,
                          onToggleStatus: () =>
                              _onToggleStatus(context, notifier, state.isOpen),
                          onMenuPressed: () =>
                              _scaffoldKey.currentState?.openDrawer(),
                        ),

                        const Divider(
                          height: 1,
                          color: Colors.white10,
                        ), // Divider subtil

                        Expanded(
                          child: state.isLoading
                              ? const InlinePageLoader(
                                  message: 'Synchronisation du dashboard...',
                                )
                              : state.hasNetworkError
                              ? NetworkErrorView(
                                  onRetry: notifier.loadInitialData,
                                )
                              : _buildSelectedPage(state, notifier),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              bottomNavigationBar: isLarge
                  ? null
                  : BottomNavigationBar(
                      currentIndex: _topTabs.contains(state.selectedIndex)
                          ? state.selectedIndex
                          : 0,
                      type: BottomNavigationBarType.fixed,
                      onTap: notifier.setSelectedIndex,
                      items: const [
                        BottomNavigationBarItem(
                          icon: Icon(Icons.home),
                          label: 'Dashboard',
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(Icons.group_outlined),
                          label: 'Visiteurs',
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(Icons.star_outline),
                          label: 'Notes',
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(Icons.photo_library_outlined),
                          label: 'Posts',
                        ),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _logout(
    BuildContext context,
    DashboardController notifier,
    DashboardState state,
  ) async {
    await Supabase.instance.client.auth.signOut();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginAdminPage()),
      (_) => false,
    );
  }

  Future<void> _onToggleStatus(
    BuildContext context,
    DashboardController notifier,
    bool isOpen,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF111827),
          title: Text(
            isOpen ? 'Fermer le lieu ?' : 'Ouvrir le lieu ?',
            style: const TextStyle(color: Colors.white),
          ),
          content: Text(
            isOpen
                ? 'La session active sera fermée immédiatement.'
                : 'Une nouvelle session sera créée avec vos dates.',
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(isOpen ? 'Fermer' : 'Continuer'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    bool ok;
    if (isOpen) {
      ok = await notifier.closeCurrentParty();
    } else {
      final schedule = await _pickPartySchedule(context);
      if (schedule == null) return;
      ok = await notifier.openPlaceWithSchedule(
        openedAt: schedule.$1,
        closedAt: schedule.$2,
      );
    }

    if (!context.mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Action impossible, veuillez réessayer.')),
      );
    }
  }

  Future<(DateTime, DateTime)?> _pickPartySchedule(BuildContext context) async {
    final now = DateTime.now();

    Future<DateTime?> pickDateTime(DateTime initial) async {
      final date = await showDatePicker(
        context: context,
        initialDate: initial,
        firstDate: now.subtract(const Duration(days: 1)),
        lastDate: now.add(const Duration(days: 365)),
      );
      if (date == null) return null;
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initial),
      );
      if (time == null) return null;
      return DateTime(date.year, date.month, date.day, time.hour, time.minute);
    }

    final openedAt = await pickDateTime(now);
    if (openedAt == null) return null;
    final closedAt = await pickDateTime(
      openedAt.add(const Duration(hours: 12)),
    );
    if (closedAt == null || !closedAt.isAfter(openedAt)) return null;

    return (openedAt, closedAt);
  }

  // À ajouter à l'intérieur de ta classe DashboardPage
  // Widget _buildSelectedPage(int index) {
  //   switch (index) {
  //     case 1: return const Center(child: Text("Page Clientèle", style: TextStyle(color: Colors.white)));
  //     case 2: return const Center(child: Text("Page Notes", style: TextStyle(color: Colors.white)));
  //     case 3: return const Center(child: Text("Page Posts", style: TextStyle(color: Colors.white)));
  //     default: return const SizedBox.shrink();
  //   }
  // }
  Widget _buildSelectedPage(
    DashboardState state,
    DashboardController notifier,
  ) {
    switch (state.selectedIndex) {
      case 0:
        return ModernHomeWidget(state: state);
      case 1:
        return ClienteleTab(
          key: ValueKey(state.activePartyId),
          partyId: state.activePartyId,
          onBack: () => notifier.setSelectedIndex(0),
          cachedCount: state.visitors,
          isOnline: NetworkService.isConnected,
        );
      case 2:
        return NoteTab(onBack: () => notifier.setSelectedIndex(0));
      case 3:
        return PostsTab(onBack: () => notifier.setSelectedIndex(0));
      case 4:
        return HistoryTab(placeId: state.placeId);
      case 5:
        return PromotionsPage(
          placeId: state.placeId,
          activePartyId: state.activePartyId,
          placeName: state.placeName,
        );
      case 6:
        return MenuTab(placeName: state.placeName, placeId: state.placeId);
      case 7:
        return const SettingsTab();

      default:
        return const Center(
          child: Text(
            'Page indisponible',
            style: TextStyle(color: Colors.white70),
          ),
        );
    }
  }
}
