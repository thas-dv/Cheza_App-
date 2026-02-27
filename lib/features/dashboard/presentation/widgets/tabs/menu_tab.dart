import 'package:cheza_app/services/supabase_service_menu.dart';
import 'package:cheza_app/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MenuTab extends StatefulWidget {
  const MenuTab({super.key});

  @override
  State<MenuTab> createState() => _MenuTabState();
}

class _MenuTabState extends State<MenuTab> {
  bool loading = true;
  List<Map<String, dynamic>> menus = [];

  @override
  void initState() {
    super.initState();
    loadMenus();
  }

  /////////////////////////////
  String formatGNF(num value) {
    final formatter = NumberFormat('#,###', 'fr_FR');
    return '${formatter.format(value)} GNF';
  }

  // =============================================================
  // LOAD MENUS
  // =============================================================
  Future<void> loadMenus() async {
    if (!mounted) return;

    setState(() => loading = true);

    try {
      final res = await SupabaseServiceMenu.fetchMenusForMyPlaceWithPlaceId();

      if (!mounted) return;

      setState(() {
        menus = res;
        loading = false;
      });
    } catch (e) {
      debugPrint("❌ loadMenus error: $e");
      if (!mounted) return;
      setState(() {
        menus = [];
        loading = false;
      });
    }
  }

  // =============================================================
  // ADD / EDIT MENU
  // =============================================================
  Future<void> openMenuDialog({Map<String, dynamic>? menu}) async {
    final controller = TextEditingController(text: menu?['name'] ?? '');
    final isEdit = menu != null;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        bool saving = false;

        return StatefulBuilder(
          builder: (context, setLocalState) {
            return Dialog(
              backgroundColor: const Color(0xFF1E1E1E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: SizedBox(
                width: 360,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isEdit ? "Modifier le menu" : "Ajouter un menu",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: controller,
                        decoration: const InputDecoration(
                          labelText: "Nom du menu",
                          isDense: true,
                          filled: true,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: saving
                                ? null
                                : () => Navigator.pop(context),
                            child: const Text("Annuler"),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: saving
                                ? null
                                : () async {
                                    if (controller.text.trim().isEmpty) return;

                                    setLocalState(() => saving = true);

                                    final menuId = menu?['id'];
                                    if (isEdit && menuId == null) {
                                      setLocalState(() => saving = false);
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "Impossible de modifier : menu sans ID",
                                          ),
                                        ),
                                      );
                                      return;
                                    }

                                    final success = isEdit
                                        ? await SupabaseServiceMenu.updateMenu(
                                            menuId: menuId!,
                                            name: controller.text.trim(),
                                          )
                                        : await SupabaseServiceMenu.insertMenu(
                                            name: controller.text.trim(),
                                          );

                                    if (!success) {
                                      setLocalState(() => saving = false);
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "Erreur lors de l'enregistrement",
                                          ),
                                        ),
                                      );
                                      return;
                                    }

                                    Navigator.pop(context);
                                    await loadMenus();
                                  },
                            child: saving
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
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

  // =============================================================
  // CONFIRM DELETE MENU
  // =============================================================
  Future<void> confirmDeleteMenu(int menuId) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        bool deleting = false;

        return StatefulBuilder(
          builder: (context, setLocalState) {
            return Dialog(
              backgroundColor: const Color(0xFF1E1E1E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: SizedBox(
                width: 340,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.red,
                        size: 40,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "Supprimer ce menu ?",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Cette action est irréversible.",
                        style: TextStyle(color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: deleting
                                ? null
                                : () => Navigator.pop(context),
                            child: const Text("Annuler"),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            onPressed: deleting
                                ? null
                                : () async {
                                    setLocalState(() => deleting = true);
                                    await SupabaseServiceMenu.deleteMenu(
                                      menuId,
                                    );
                                    Navigator.pop(context);
                                    await loadMenus();
                                  },
                            child: deleting
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text("Supprimer"),
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

  // =============================================================
  // UI
  // =============================================================
  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width < 500
        ? 1
        : width < 900
        ? 2
        : 3;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ================= HEADER =================
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Notre Menu",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              ElevatedButton(
                onPressed: () => openMenuDialog(),
                child: const Text("Ajouter"),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ================= EMPTY STATE =================
          if (menus.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.menu_book, size: 64, color: Colors.grey),
                    const SizedBox(height: 12),
                    const Text(
                      "Aucun menu pour le moment",
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => openMenuDialog(),
                      child: const Text("Créer le premier menu"),
                    ),
                  ],
                ),
              ),
            )
          else
            // ================= GRID =================
            Expanded(
              child: GridView.builder(
                itemCount: menus.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1,
                ),
                itemBuilder: (context, index) {
                  final menu = menus[index];
                  return _menuCard(
                    menuId: menu['id'],
                    menuName: menu['name'],
                    createdAt: menu['created_at'].toString().substring(0, 10),
                    items: menu['menu_items'] ?? [],
                    onEdit: () => openMenuDialog(menu: menu),
                    onDelete: () => confirmDeleteMenu(menu['id']),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  // =============================================================
  // Items Dialog
  // =============================================================
  Future<void> _openItemsDialog(int menuId, String menuName) async {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();

    await showDialog(
      context: context,
      builder: (_) {
        bool saving = false;

        return StatefulBuilder(
          builder: (context, setLocal) {
            return Dialog(
              backgroundColor: const Color(0xFF1E1E1E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: SizedBox(
                width: 400,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Ajouter un item à $menuName",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: nameCtrl,
                        decoration: const InputDecoration(
                          labelText: "Nom de l'item",
                          filled: true,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: priceCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: "Prix",
                          filled: true,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Annuler"),
                          ),
                          ElevatedButton(
                            onPressed: saving
                                ? null
                                : () async {
                                    final price = double.tryParse(
                                      priceCtrl.text,
                                    );
                                    if (price == null) return;

                                    setLocal(() => saving = true);

                                    final success =
                                        await SupabaseServiceMenu.insertItem(
                                          menuId: menuId,
                                          name: nameCtrl.text.trim(),
                                          price: price,
                                        );

                                    if (!mounted) return;

                                    Navigator.pop(context);

                                    if (success) {
                                      await loadMenus();
                                    }
                                  },
                            child: saving
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text("Ajouter"),
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

  Widget _menuCard({
    required int menuId,
    required String menuName,
    required String createdAt,
    required List<dynamic> items,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  menuName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.orange),
                    onPressed: onEdit,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: onDelete,
                  ),
                ],
              ),
            ],
          ),

          Text(
            "Créé le $createdAt",
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),

          const SizedBox(height: 8),

          Divider(color: Colors.grey.shade800),

          const SizedBox(height: 6),

          /// 🔥 LISTE ITEMS SCROLLABLE STABLE
          Expanded(
            child: items.isEmpty
                ? const Center(
                    child: Text(
                      "Aucun item",
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                item['item_name'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              formatGNF(item['price']),
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 4),
                            IconButton(
                              icon: const Icon(
                                Icons.edit,
                                size: 18,
                                color: Colors.orange,
                              ),
                              onPressed: () {
                                _openEditItemDialog(menuId, item);
                              },
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                size: 18,
                                color: AppColors.bacgroundRed,
                              ),
                              onPressed: () {
                                _confirmDeleteItem(item['id']);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),

          /// BOUTON AJOUT
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => _openItemsDialog(menuId, menuName),
              icon: const Icon(Icons.add, size: 18),
              label: const Text("Ajouter item"),
            ),
          ),
        ],
      ),
    );
  }

  /////////////////////////////////////
  Future<void> _openEditItemDialog(
    int menuId,
    Map<String, dynamic> item,
  ) async {
    final nameCtrl = TextEditingController(text: item['item_name']);
    final priceCtrl = TextEditingController(text: item['price'].toString());

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        bool saving = false;

        return StatefulBuilder(
          builder: (context, setLocal) {
            return AlertDialog(
              title: const Text("Modifier item"),
              content: saving
                  ? const SizedBox(
                      height: 80,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: nameCtrl,
                          decoration: const InputDecoration(labelText: "Nom"),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: priceCtrl,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(labelText: "Prix"),
                        ),
                      ],
                    ),
              actions: saving
                  ? []
                  : [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Annuler"),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          final price = double.tryParse(priceCtrl.text);
                          if (price == null) return;

                          setLocal(() => saving = true);

                          final success = await SupabaseServiceMenu.updateItem(
                            itemId: item['id'],
                            name: nameCtrl.text.trim(),
                            price: price,
                          );

                          if (!mounted) return;

                          Navigator.pop(context);

                          if (success) {
                            await loadMenus();
                          }
                        },
                        child: const Text("Valider"),
                      ),
                    ],
            );
          },
        );
      },
    );
  }

  /////////////////////////////////
  Future<void> _confirmDeleteItem(int itemId) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        bool deleting = false;

        return StatefulBuilder(
          builder: (context, setLocal) {
            return AlertDialog(
              title: const Text("Supprimer item ?"),
              content: deleting
                  ? const SizedBox(
                      height: 70,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : const Text("Cette action est irréversible."),
              actions: deleting
                  ? []
                  : [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Annuler"),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        onPressed: () async {
                          setLocal(() => deleting = true);

                          final success = await SupabaseServiceMenu.deleteItem(
                            itemId,
                          );

                          if (!mounted) return;

                          Navigator.pop(context);

                          if (success) {
                            await loadMenus();
                          }
                        },
                        child: const Text("Supprimer"),
                      ),
                    ],
            );
          },
        );
      },
    );
  }
}
