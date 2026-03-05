import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cheza_app/features/dashboard/data/datasources/dashboard_controller.dart';
import 'package:cheza_app/features/auth/presentation/providers/admin_provider.dart';

class Sidebar extends ConsumerWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final VoidCallback onLogout;

  const Sidebar({
    super.key,
    required this.selectedIndex,
    required this.onSelect,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final admin = ref.watch(adminProvider);
    final dashboardState = ref.watch(dashboardControllerProvider);

    return Container(
      width: 270,
      decoration: const BoxDecoration(
        color: Color(0xFF111827),
        border: Border(right: BorderSide(color: Color(0xFF1E293B))),
      ),
           padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10,),
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.grey.shade800,
            backgroundImage:
                admin?.photoUrl != null && admin!.photoUrl!.isNotEmpty
                    ? NetworkImage(admin.photoUrl!)
                    : null,
            child: admin?.photoUrl == null || admin!.photoUrl!.isEmpty
                ? const Icon(Icons.person, color: Colors.white)
                : null,
          ),

          const SizedBox(height: 10),

          Text(
            admin?.name ?? 'Admin',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            dashboardState.placeAddress?.trim().isNotEmpty == true
                ? dashboardState.placeAddress!
                : 'Adresse non renseignée',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
          ),

          const SizedBox(height: 30),

          _item('Dashboard', Icons.dashboard_outlined, 0),
          _item('Clientèle', Icons.group_outlined, 1),
          _item('Notes', Icons.star_outline, 2),
          _item('Posts', Icons.photo_outlined, 3),
          _item('Historique', Icons.history, 4),
          _item('Promotions', Icons.local_offer_outlined, 5),
          _item('Menu', Icons.restaurant_menu_outlined, 6),

          const Spacer(),

          _item('Paramètres', Icons.settings_outlined, 7),

          const SizedBox(height: 6),

          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text(
              'Déconnexion',
              style: TextStyle(color: Colors.redAccent),
            ),
            onTap: onLogout,
          ),
        ],
      ),
    );
  }

  Widget _item(String title, IconData icon, int index) {
    final selected = selectedIndex == index;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: selected ? Colors.blue : Colors.grey),
      title: Text(
        title,
        style: TextStyle(color: selected ? Colors.white : Colors.grey),
      ),
      onTap: () => onSelect(index),
    );
  }
}
