import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cheza_app/features/auth/presentation/providers/admin_provider.dart';
class Sidebar extends ConsumerWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const Sidebar({
    super.key,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final admin = ref.watch(adminProvider);

    return Container(
      width: 270,
      decoration: const BoxDecoration(
        color: Color(0xFF111827),
        border: Border(right: BorderSide(color: Color(0xFF1E293B))),
      ),
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.grey.shade800,

                 backgroundImage: admin?.photoUrl != null && admin!.photoUrl!.isNotEmpty
                ? NetworkImage(admin.photoUrl!)
                : null,
            child: admin?.photoUrl == null || admin!.photoUrl!.isEmpty
                ? const Icon(Icons.person, color: Colors.white)
                : null,
          ),

          const SizedBox(height: 50),
 const SizedBox(height: 10),
          Text(
            admin?.name ?? 'Admin',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 30),
          _item('Dashboard', Icons.dashboard_outlined, 0),
          _item('Clientèle', Icons.group_outlined, 1),
          _item('Notes', Icons.star_outline, 2),
          _item('Posts', Icons.photo_outlined, 3),
          // _item("Dashboard", Icons.dashboard_outlined, 0),
          // _item("Posts", Icons.photo_outlined, 1),
          // _item("Clientèle", Icons.group_outlined, 2),
          // _item("Promotions", Icons.local_offer_outlined, 3),

          // const Spacer(),

          // _item("Paramètres", Icons.settings_outlined, 4),
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
