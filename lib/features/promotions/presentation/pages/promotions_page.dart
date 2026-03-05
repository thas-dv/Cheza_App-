import 'package:cheza_app/features/promotions/domain/entities/promotion_entity.dart';
import 'package:cheza_app/features/promotions/presentation/providers/promotions_providers.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cheza_app/features/menus/domain/entities/menu_entity.dart';
import 'package:cheza_app/themes/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cheza_app/widgets/inline_page_loader.dart';
class PromotionsPage extends ConsumerWidget {
  const PromotionsPage({
    required this.placeId,
    required this.activePartyId,
    required this.placeName,
    super.key,
  });

  final int? placeId;
  final int? activePartyId;
  final String placeName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (placeId == null) {
      return const Center(
        child: Text('Lieu introuvable', style: TextStyle(color: Colors.grey)),
      );
    }

    final promotionsAsync = ref.watch(promotionsProvider(placeId!));
    final actionState = ref.watch(promotionsActionProvider);

    return Stack(
      children: [
        // Positioned.fill(
        //   child: Image.asset(
        //     'assets/images/fondprincipal.png',
        //     fit: BoxFit.cover,
        //   ),
        // ),
        Positioned.fill(
          child: Container(color: const Color(0xFF0B1120).withOpacity(0.85)),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  const Text(
                    'Promotions',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: actionState.isLoading
                        ? null
                        : () => _openCreatePromoDialog(context, ref),
                    icon: const Icon(Icons.add),
                    label: const Text('Créer une promo'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: promotionsAsync.when(
                  data: (promotions) {
                    if (promotions.isEmpty) {
                      return const Center(
                        child: Text(
                          'Aucune promotion disponible.',
                          style: TextStyle(color: Colors.white70),
                        ),
                      );
                    }

                    final width = MediaQuery.of(context).size.width;
                    final crossAxisCount = width < 700
                        ? 1
                        : width < 1100
                        ? 2
                        : 3;

                    return GridView.builder(
                      itemCount: promotions.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 1,
                      ),
                      itemBuilder: (context, index) {
                        final promo = promotions[index];
                        return _PromotionCard(
                          promotion: promo,
                          onAddItem: () =>
                              _openAddPromoItemDialog(context, ref, promo.id),
                          onEdit: () =>
                              _openEditPromoDialog(context, ref, promo),
                          onDelete: () =>
                              _confirmDeletePromo(context, ref, promo),
                          onAssing: () =>
                              _linkPromoToActiveParty(context, ref, promo.id),
                        );
                      },
                    );
                  },
                  loading: () =>
                      const InlinePageLoader(message: 'Chargement des promotions...'),
                  error: (error, _) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Erreur chargement promotions: $error',
                          style: const TextStyle(color: Colors.redAccent),
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton(
                          onPressed: () => ref
                              .read(promotionsRefreshTickProvider.notifier)
                              .state++,
                          child: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (actionState.hasError)
                Text(
                  'Action impossible: ${actionState.error}',
                  style: const TextStyle(color: Colors.redAccent),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _linkPromoToActiveParty(
    BuildContext context,
    WidgetRef ref,
    int promoId,
  ) async {
    if (activePartyId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aucune fête active à lier.')),
      );
      return;
    }
    try {
      await ref
          .read(promotionsActionProvider.notifier)
          .linkPromoToParty(promoId: promoId, partyId: activePartyId!);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Promotion liée à la fête active.')),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible de lier cette promotion.')),
      );
    }
  }

  String formatDiscount(String type, double value) {
    if (type == 'Pourcentage') {
      return '-${value.toStringAsFixed(0)} %';
    } else if (type == 'Montant') {
      return '-${value.toStringAsFixed(0)} GNF';
    } else {
      return '';
    }
  }

  Future<void> _openEditPromoDialog(
    BuildContext context,
    WidgetRef ref,
    PromotionEntity promotion,
  ) async {
    final formKey = GlobalKey<FormState>();
    final descCtrl = TextEditingController(text: promotion.description);
    final limitCtrl = TextEditingController(
      text: promotion.limit?.toString() ?? '',
    );

    bool forEveryone = promotion.forEveryone;
    DateTime startDate = promotion.dateStart;
    DateTime endDate = promotion.dateEnd;
    bool isEditing = false;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            Future<void> pickDateTime({required bool isStart}) async {
              final initial = isStart ? startDate : endDate;

              final pickedDate = await showDatePicker(
                context: dialogContext,
                initialDate: initial,
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
              );

              if (pickedDate == null) return;

              final pickedTime = await showTimePicker(
                // ignore: use_build_context_synchronously
                context: dialogContext,
                initialTime: TimeOfDay.fromDateTime(initial),
              );

              if (pickedTime == null) return;

              final combined = DateTime(
                pickedDate.year,
                pickedDate.month,
                pickedDate.day,
                pickedTime.hour,
                pickedTime.minute,
              );

              setStateDialog(() {
                if (isStart) {
                  startDate = combined;
                } else {
                  endDate = combined;
                }
              });
            }

            return Dialog(
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 24,
              ),
              backgroundColor: AppColors.background,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 600,
                  maxHeight: MediaQuery.of(dialogContext).size.height * 0.85,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Modifier la promo',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () => Navigator.pop(dialogContext),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      /// 🔥 FORM SCROLLABLE
                      Expanded(
                        child: SingleChildScrollView(
                          child: Form(
                            key: formKey,
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: descCtrl,
                                  decoration: const InputDecoration(
                                    labelText: 'Description',
                                  ),
                                  validator: (value) =>
                                      (value == null || value.trim().isEmpty)
                                      ? 'Description requise'
                                      : null,
                                ),

                                const SizedBox(height: 12),

                                CheckboxListTile(
                                  value: forEveryone,
                                  title: const Text('Pour tout le monde'),
                                  onChanged: (value) => setStateDialog(
                                    () => forEveryone = value ?? true,
                                  ),
                                ),

                                if (!forEveryone)
                                  TextFormField(
                                    controller: limitCtrl,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      labelText: 'Limite',
                                    ),
                                    validator: (value) {
                                      if (forEveryone) return null;
                                      final parsed = int.tryParse(value ?? '');
                                      if (parsed == null || parsed <= 0) {
                                        return 'Limite invalide';
                                      }
                                      return null;
                                    },
                                  ),

                                const SizedBox(height: 16),

                                ListTile(
                                  title: const Text('Date début'),
                                  subtitle: Text(
                                    DateFormat(
                                      'dd/MM/yyyy HH:mm',
                                    ).format(startDate),
                                  ),
                                  trailing: const Icon(Icons.schedule),
                                  onTap: () => pickDateTime(isStart: true),
                                ),

                                ListTile(
                                  title: const Text('Date fin'),
                                  subtitle: Text(
                                    DateFormat(
                                      'dd/MM/yyyy HH:mm',
                                    ).format(endDate),
                                  ),
                                  trailing: const Icon(Icons.schedule),
                                  onTap: () => pickDateTime(isStart: false),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      /// 🔥 ACTIONS FIXES
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(dialogContext),
                            child: const Text('Annuler'),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: isEditing
                                ? null
                                : () async {
                                    if (!formKey.currentState!.validate())
                                      return;

                                    if (endDate.isBefore(startDate)) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'date_end doit être après date_start',
                                          ),
                                        ),
                                      );
                                      return;
                                    }
                                    setStateDialog(() {
                                      isEditing = true;
                                    });
                                    try {
                                      await ref
                                          .read(
                                            promotionsActionProvider.notifier,
                                          )
                                          .updatePromo(
                                            promoId: promotion.id,
                                            description: descCtrl.text.trim(),
                                            unlimited: forEveryone,
                                            limit: forEveryone
                                                ? null
                                                : int.tryParse(limitCtrl.text),
                                            dateStart: startDate,
                                            dateEnd: endDate,
                                          );

                                      if (!context.mounted) return;

                                      Navigator.pop(dialogContext);
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Promotion modifiée avec succès.',
                                          ),
                                        ),
                                      );
                                    } catch (e) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Erreur lors de la modification.',
                                          ),
                                        ),
                                      );
                                    } finally {
                                      setStateDialog(() {
                                        isEditing = false;
                                      });
                                    }
                                  },
                            child: isEditing
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text('Enregistrer'),
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

  Future<void> _confirmDeletePromo(
    BuildContext context,
    WidgetRef ref,
    PromotionEntity promotion,
  ) async {
    bool isDelete = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E1E1E),
              title: const Text(
                'Supprimer la promo ?',
                style: TextStyle(color: Colors.white),
              ),
              content: Text(
                'Voulez-vous supprimer "${promotion.description}" ?',
                style: const TextStyle(color: Colors.white70),
              ),
              actions: [
                TextButton(
                  onPressed: isDelete
                      ? null
                      : () => Navigator.pop(dialogContext),
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: isDelete
                      ? null
                      : () async {
                          setStateDialog(() {
                            isDelete = true;
                          });

                          try {
                            await ref
                                .read(promotionsActionProvider.notifier)
                                .deletePromo(promoId: promotion.id);

                            Navigator.pop(dialogContext);

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Promotion supprimée avec succès.',
                                ),
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Erreur lors de la suppression.'),
                              ),
                            );

                            setStateDialog(() {
                              isDelete = false;
                            });
                          }
                        },
                  child: isDelete
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Supprimer'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _openCreatePromoDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final formKey = GlobalKey<FormState>();
    final descCtrl = TextEditingController();
    final limitCtrl = TextEditingController();
    bool linkToActiveParty = activePartyId != null;
    bool forEveryone = true;
    bool isSaving = false;
    DateTime startDate = DateTime.now();
    DateTime endDate = DateTime.now().add(const Duration(days: 7));

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            Future<void> pickDateTime({required bool isStart}) async {
              final initialDate = isStart ? startDate : endDate;

              final pickedDate = await showDatePicker(
                context: dialogContext,
                initialDate: initialDate,
                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
              );

              if (pickedDate == null) return;

              final pickedTime = await showTimePicker(
                context: dialogContext,
                initialTime: TimeOfDay.fromDateTime(initialDate),
              );

              if (pickedTime == null) return;

              final combined = DateTime(
                pickedDate.year,
                pickedDate.month,
                pickedDate.day,
                pickedTime.hour,
                pickedTime.minute,
              );

              setStateDialog(() {
                if (isStart) {
                  startDate = combined;
                } else {
                  endDate = combined;
                }
              });
            }

            return Dialog(
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 24,
              ),
              backgroundColor: const Color(0xFF1E1E1E),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 600,
                  maxHeight: MediaQuery.of(dialogContext).size.height * 0.85,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Créer une promo',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () => Navigator.pop(dialogContext),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      /// 🔥 FORM SCROLLABLE
                      Expanded(
                        child: SingleChildScrollView(
                          child: Form(
                            key: formKey,
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: descCtrl,
                                  decoration: const InputDecoration(
                                    labelText: 'Description',
                                  ),
                                  validator: (value) =>
                                      (value == null || value.trim().isEmpty)
                                      ? 'Description requise'
                                      : null,
                                ),

                                const SizedBox(height: 12),

                                CheckboxListTile(
                                  value: forEveryone,
                                  title: const Text('Pour tout le monde'),
                                  onChanged: (value) => setStateDialog(() {
                                    forEveryone = value ?? true;
                                  }),
                                ),

                                if (!forEveryone)
                                  TextFormField(
                                    controller: limitCtrl,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      labelText: 'Limite',
                                    ),
                                    validator: (value) {
                                      if (forEveryone) return null;
                                      final parsed = int.tryParse(value ?? '');
                                      if (parsed == null || parsed <= 0) {
                                        return 'Limite invalide';
                                      }
                                      return null;
                                    },
                                  ),
                                const SizedBox(height: 8),
                                SwitchListTile(
                                  value: linkToActiveParty,
                                  onChanged: activePartyId == null
                                      ? null
                                      : (value) => setStateDialog(() {
                                          linkToActiveParty = value;
                                        }),
                                  title: const Text('Lié à la fête'),
                                  subtitle: Text(
                                    activePartyId == null
                                        ? 'Aucune fête active disponible'
                                        : 'Associer cette promotion à la fête active',
                                  ),
                                ),
                                const SizedBox(height: 16),

                                ListTile(
                                  title: const Text('Date début'),
                                  subtitle: Text(
                                    DateFormat(
                                      'dd/MM/yyyy HH:mm',
                                    ).format(startDate),
                                  ),
                                  trailing: const Icon(Icons.schedule),
                                  onTap: () => pickDateTime(isStart: true),
                                ),

                                ListTile(
                                  title: const Text('Date fin'),
                                  subtitle: Text(
                                    DateFormat(
                                      'dd/MM/yyyy HH:mm',
                                    ).format(endDate),
                                  ),
                                  trailing: const Icon(Icons.schedule),
                                  onTap: () => pickDateTime(isStart: false),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      /// 🔥 ACTIONS FIXES EN BAS
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(dialogContext),
                            child: const Text('Annuler'),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: isSaving
                                ? null
                                : () async {
                                    if (!formKey.currentState!.validate())
                                      return;

                                    if (endDate.isBefore(startDate)) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'date_end doit être après date_start',
                                          ),
                                        ),
                                      );
                                      return;
                                    }

                                    final partyId = activePartyId;

                                    setStateDialog(() {
                                      isSaving = true;
                                    });

                                    try {
                                      await ref
                                          .read(
                                            promotionsActionProvider.notifier,
                                          )
                                          .createPromo(
                                            description: descCtrl.text.trim(),
                                            unlimited: forEveryone,
                                            placeId: placeId!,
                                            limit: forEveryone
                                                ? null
                                                : int.tryParse(limitCtrl.text),
                                            dateStart: startDate,
                                            dateEnd: endDate,
                                            partyId: partyId,
                                          );

                                      if (!context.mounted) return;

                                      Navigator.pop(dialogContext);

                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Promotion créée avec succès.',
                                          ),
                                        ),
                                      );
                                    } catch (e) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Erreur lors de la création',
                                          ),
                                        ),
                                      );
                                    } finally {
                                      setStateDialog(() {
                                        isSaving = false;
                                      });
                                    }
                                  },
                            child: isSaving
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('Enregistrer'),
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

  Future<void> _openAddPromoItemDialog(
    BuildContext context,
    WidgetRef ref,
    int promoId,
  ) async {
    final place = placeId;
    if (place == null) return;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 24,
          ),
          backgroundColor: AppColors.background,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 600,
              maxHeight: MediaQuery.of(dialogContext).size.height * 0.85,
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: FutureBuilder(
                future: ref.read(menusByPlaceProvider(place).future),
                builder: (context, menuSnapshot) {
                  if (menuSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (menuSnapshot.hasError) {
                    return Center(
                      child: Text(
                        'Erreur chargement menus: ${menuSnapshot.error}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  final menus = menuSnapshot.data ?? [];

                  if (menus.isEmpty) {
                    return const Center(
                      child: Text(
                        'Aucun menu disponible.',
                        style: TextStyle(color: Colors.white70),
                      ),
                    );
                  }

                  return _AddPromoItemContent(
                    menus: menus,
                    promoId: promoId,
                    ref: ref,
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AddPromoItemContent extends ConsumerStatefulWidget {
  const _AddPromoItemContent({
    required this.menus,
    required this.promoId,
    required this.ref,
  });

  final List<MenuEntity> menus;
  final int promoId;
  final WidgetRef ref;

  @override
  ConsumerState<_AddPromoItemContent> createState() =>
      _AddPromoItemContentState();
}

class _AddPromoItemContentState extends ConsumerState<_AddPromoItemContent> {
  MenuEntity? selectedMenu;
  MenuItemOptionEntity? selectedItem;
  bool isFreeOffer = true;
  String discountType = 'Pourcentage';
  final valueCtrl = TextEditingController();
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    selectedMenu = widget.menus.first;
    selectedItem = null;
    valueCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final itemsAsync = selectedMenu == null
        ? null
        : ref.watch(menuItemsByMenuProvider(selectedMenu!.id));

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Ajouter article',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),

        const SizedBox(height: 16),

        /// MENU
        DropdownButtonFormField<MenuEntity>(
          dropdownColor: AppColors.backgroundDark,
          value: selectedMenu,
          items: widget.menus
              .map(
                (menu) => DropdownMenuItem(value: menu, child: Text(menu.name)),
              )
              .toList(),
          onChanged: (value) {
            setState(() {
              selectedMenu = value;
              selectedItem = null;
            });
          },
          decoration: const InputDecoration(labelText: 'Menu'),
        ),

        const SizedBox(height: 12),

        /// ITEMS
        if (itemsAsync != null)
          itemsAsync.when(
            loading: () => const CircularProgressIndicator(),
            error: (e, _) =>
                Text('Erreur: $e', style: const TextStyle(color: Colors.red)),
            data: (items) {
              if (items.isEmpty) {
                return const Text(
                  'Aucun article',
                  style: TextStyle(color: Colors.white70),
                );
              }

              selectedItem ??= items.first;

              return DropdownButtonFormField<MenuItemOptionEntity>(
                dropdownColor: AppColors.backgroundDark,
                value: selectedItem,
                items: items
                    .map(
                      (item) => DropdownMenuItem(
                        value: item,
                        child: Text(
                          '${item.name} (${item.price.toStringAsFixed(0)})',
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => selectedItem = value),
                decoration: const InputDecoration(labelText: 'Article'),
              );
            },
          ),

        const SizedBox(height: 12),

        CheckboxListTile(
          value: isFreeOffer,
          title: const Text('Offre gratuite'),
          onChanged: (value) => setState(() => isFreeOffer = value ?? true),
        ),
        const SizedBox(height: 10),
        if (!isFreeOffer) ...[
          DropdownButtonFormField<String>(
            dropdownColor: AppColors.backgroundDark,
            value: discountType,
            items: const [
              DropdownMenuItem(
                value: 'Pourcentage',
                child: Text('Pourcentage'),
              ),
              DropdownMenuItem(value: 'Montant', child: Text('Montant')),
            ],
            onChanged: (value) => setState(() => discountType = value!),
            decoration: const InputDecoration(labelText: 'Type réduction'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: valueCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Valeur réduction'),
          ),
        ],

        const Spacer(),

        ElevatedButton(
          onPressed: isLoading
              ? null
              : () async {
                  if (selectedItem == null) return;

                  final discountValue = double.tryParse(
                    valueCtrl.text.replaceAll(',', '.'),
                  );

                  if (!isFreeOffer &&
                      (discountValue == null || discountValue <= 0)) {
                    return;
                  }

                  setState(() {
                    isLoading = true;
                  });

                  try {
                    await widget.ref
                        .read(promotionsActionProvider.notifier)
                        .addItemToPromo(
                          promoId: widget.promoId,
                          itemId: selectedItem!.id,
                          isFreeOffer: isFreeOffer,
                          discountType: isFreeOffer ? null : discountType,
                          discountValue: isFreeOffer ? null : discountValue,
                        );

                    if (!context.mounted) return;
                    Navigator.pop(context);
                  } finally {
                    if (mounted) {
                      setState(() {
                        isLoading = false;
                      });
                    }
                  }
                },
          child: isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Ajouter'),
        ),
      ],
    );
  }
}

class _PromotionCard extends StatelessWidget {
  const _PromotionCard({
    required this.promotion,
    required this.onAddItem,
    required this.onEdit,
    required this.onDelete,
    required this.onAssing,
  });

  final PromotionEntity promotion;
  final VoidCallback onAddItem;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onAssing;
  String _formatGNF(double value) {
    final formatter = NumberFormat('#,###', 'fr_FR');
    return '${formatter.format(value)} GNF';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.deepIndigo.withOpacity(0.8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  promotion.description,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),

              Wrap(
                spacing: 6,
                children: [
                  IconButton(
                    tooltip: 'Modifier',
                    onPressed: onEdit,
                    icon: const Icon(
                      Icons.edit,
                      color: Colors.orange,
                      size: 20,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Supprimer',
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            promotion.forEveryone
                ? 'Pour tout le monde'
                : 'Limite: ${promotion.limit ?? 0}',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          Text(
            'Du ${DateFormat('dd/MM/yyyy').format(promotion.dateStart.toLocal())} au ${DateFormat('dd/MM/yyyy').format(promotion.dateEnd.toLocal())}',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          if (promotion.items.isEmpty)
            const Text(
              'Aucun article lié.',
              style: TextStyle(color: Colors.grey),
            )
          else
            SizedBox(
              height: 130, // 🔥 hauteur zone scroll
              child: ListView.builder(
                itemCount: promotion.items.length,
                itemBuilder: (context, index) {
                  final item = promotion.items[index];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundDark,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.local_offer_rounded,
                            color: AppColors.neonPurple,
                            size: 18,
                          ),
                          const SizedBox(width: 8),

                          Expanded(
                            child: Text(
                              item.itemName,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                          const SizedBox(width: 10),

                          Text(
                            item.isFreeOffer
                                ? 'Gratuit'
                                : item.discountType == 'Pourcentage'
                                ? '-${item.discountValue?.toStringAsFixed(0) ?? '0'}%'
                                // ignore: unnecessary_string_interpolations
                                : '${_formatGNF(item.discountValue ?? 0)}',
                            style: const TextStyle(
                              color: AppColors.neonBlue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          if (!item.isFreeOffer) ...[
                            const SizedBox(width: 10),
                            Text(
                              _formatGNF(item.itemPrice),
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              TextButton.icon(
                onPressed: onAddItem,
                icon: const Icon(Icons.add_shopping_cart, size: 18),
                label: const Text('Ajouter article'),
              ),
              TextButton.icon(
                onPressed: onAssing,
                icon: const Icon(Icons.celebration, size: 18),
                label: const Text('Lier à la fête'),
              ),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.emoji_events, size: 18),
                label: const Text('Vainqueurs'),
              ),
            ],
          ),
          // Row(
          //   children: [
          //     TextButton.icon(
          //       onPressed: onAddItem,
          //       icon: const Icon(Icons.add_shopping_cart, size: 18),
          //       label: const Text('Ajouter article'),
          //     ),
          //     SizedBox(width: 5),
          //     TextButton.icon(
          //       onPressed: () => {},
          //       label: Text("Lier à la fête"),
          //       icon: const Icon(Icons.abc),
          //     ),

          //     SizedBox(width: 5),
          //     TextButton.icon(
          //       onPressed: onAssing,
          //       icon: const Icon(Icons.attribution, size: 18),
          //       label: const Text('Vainqueurs'),
          //     ),
          //   ],
          // ),
        ],
      ),
    );
  }
}
