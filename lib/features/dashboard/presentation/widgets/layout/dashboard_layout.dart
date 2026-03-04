import 'package:cheza_app/features/dashboard/presentation/widgets/layout/sidebar.dart';
import 'package:cheza_app/features/dashboard/presentation/widgets/layout/topbar.dart';
import 'package:flutter/material.dart';

class DashboardLayout extends StatelessWidget {
  final Widget child;
  final int selectedIndex;
  final Function(int) onSelect;
  final bool isOpen;
  final bool isStatusUpdating;
  final VoidCallback onToggleStatus;

  const DashboardLayout({
    super.key,
    required this.child,
    required this.selectedIndex,
    required this.onSelect,
    required this.isOpen,
    required this.isStatusUpdating,
    required this.onToggleStatus,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 1100;

    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),

      drawer: !isDesktop
          ? Sidebar(selectedIndex: selectedIndex, onSelect: onSelect)
          : null,

      body: Row(
        children: [
          // SIDEBAR DESKTOP
          if (isDesktop)
            Sidebar(selectedIndex: selectedIndex, onSelect: onSelect),

          // CONTENU PRINCIPAL
          Expanded(
            child: Column(
              children: [
                // ✅ TOPBAR BIEN APPELÉ ICI
                TopBar(
                  isLargeScreen: isDesktop,
                  isOpen: isOpen,
                  isStatusUpdating: isStatusUpdating,
                  selectedIndex: selectedIndex,
                  onSelect: onSelect,
                  onToggleStatus: onToggleStatus,
                ),

                const Divider(height: 1),

                // BODY
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
