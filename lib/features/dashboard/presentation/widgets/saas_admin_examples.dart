import 'package:cheza_app/core/ui/responsive_layout.dart';
import 'package:cheza_app/widgets/adaptive_network_image.dart';
import 'package:flutter/material.dart';

class SaaSAdminScreenExample extends StatelessWidget {
  const SaaSAdminScreenExample({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: const _MobileAdminView(),
      tablet: const _MobileAdminView(),
      desktop: const _DesktopAdminView(),
    );
  }
}

class _DesktopAdminView extends StatelessWidget {
  const _DesktopAdminView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: const [
          _AdminSidebar(),
          Expanded(
            child: Column(
              children: [
                _AdminHeader(),
                Expanded(child: _AdminCardsGrid()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileAdminView extends StatelessWidget {
  const _MobileAdminView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard Admin')),
      drawer: const Drawer(child: _AdminSidebar(compact: true)),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.campaign), label: 'Posts'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
      body: const _AdminCardsGrid(),
    );
  }
}

class _AdminSidebar extends StatelessWidget {
  const _AdminSidebar({this.compact = false});
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: compact ? double.infinity : 264,
      color: const Color(0xFF0F172A),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('Cheza Admin', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 24),
          ListTile(leading: Icon(Icons.dashboard_outlined), title: Text('Dashboard')),
          ListTile(leading: Icon(Icons.group_outlined), title: Text('Clientèle')),
          ListTile(leading: Icon(Icons.local_offer_outlined), title: Text('Promotions')),
        ],
      ),
    );
  }
}

class _AdminHeader extends StatelessWidget {
  const _AdminHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0x1FFFFFFF)))),
      child: Row(
        children: [
          const Expanded(child: Text('Vue générale', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600))),
          const CircleAvatar(radius: 18),
          const SizedBox(width: 12),
          SizedBox(
            width: 42,
            height: 42,
            child: AdaptiveNetworkImage(
              imageUrl: null,
              borderRadius: BorderRadius.circular(21),
              placeholderIcon: Icons.person_outline,
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminCardsGrid extends StatelessWidget {
  const _AdminCardsGrid();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = Breakpoints.isDesktop(constraints.maxWidth)
            ? 3
            : Breakpoints.isTablet(constraints.maxWidth)
                ? 2
                : 1;

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.5,
          ),
          itemCount: 6,
          itemBuilder: (_, index) => Container(
            decoration: BoxDecoration(
              color: const Color(0xFF111827),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0x1FFFFFFF)),
            ),
            padding: const EdgeInsets.all(16),
            child: Text('Card KPI ${index + 1}'),
          ),
        );
      },
    );
  }
}
