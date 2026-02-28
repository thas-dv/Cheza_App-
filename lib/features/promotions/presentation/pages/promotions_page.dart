import 'package:cheza_app/features/promotions/domain/entities/promotion_entity.dart';
import 'package:cheza_app/features/promotions/presentation/providers/promotions_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    if (activePartyId == null || placeId == null) {
      return const Center(
        child: Text(
          'Aucune party active pour gérer les promotions.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    final promotionsAsync = ref.watch(promotionsByPartyProvider(activePartyId!));
    final actionState = ref.watch(promotionsActionProvider);

    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset('assets/images/fondprincipal.png', fit: BoxFit.cover),
        ),
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

                    return ListView.separated(
                      itemCount: promotions.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final promo = promotions[index];
                        return _PromotionCard(
                          promotion: promo,
                          onAddItem: () => _openAddPromoItemDialog(
                            context,
                            ref,
                            promo.id,
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
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

  Future<void> _openCreatePromoDialog(BuildContext context, WidgetRef ref) async {
    final formKey = GlobalKey<FormState>();
    final descCtrl = TextEditingController();
    final limitCtrl = TextEditingController();
    bool forEveryone = true;
    DateTime startDate = DateTime.now();
    DateTime endDate = DateTime.now().add(const Duration(days: 7));

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            Future<void> pickDate({required bool isStart}) async {
              final picked = await showDatePicker(
                context: context,
                initialDate: isStart ? startDate : endDate,
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
              );
              if (picked == null) return;
              setStateDialog(() {
                if (isStart) {
                  startDate = DateTime(
                    picked.year,
                    picked.month,
                    picked.day,
                    startDate.hour,
                    startDate.minute,
                  );
                } else {
                  endDate = DateTime(
                    picked.year,
                    picked.month,
                    picked.day,
                    endDate.hour,
                    endDate.minute,
                  );
                }
              });
            }

            return AlertDialog(
              backgroundColor: const Color(0xFF1E1E1E),
              title: const Text('Créer une promo', style: TextStyle(color: Colors.white)),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: descCtrl,
                      decoration: const InputDecoration(labelText: 'Description'),
                      validator: (value) => (value == null || value.trim().isEmpty)
                          ? 'Description requise'
                          : null,
                    ),
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
                        decoration: const InputDecoration(labelText: 'Limite'),
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
                    ListTile(
                      title: const Text('Date début'),
                      subtitle: Text(startDate.toString()),
                      trailing: const Icon(Icons.calendar_month),
                      onTap: () => pickDate(isStart: true),
                    ),
                    ListTile(
                      title: const Text('Date fin'),
                      subtitle: Text(endDate.toString()),
                      trailing: const Icon(Icons.calendar_month),
                      onTap: () => pickDate(isStart: false),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    if (endDate.isBefore(startDate)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('date_end doit être après date_start')),
                      );
                      return;
                    }

                    final partyId = activePartyId;
                    if (partyId == null) return;

                    try {
                      final promoId = await ref
                          .read(promotionsActionProvider.notifier)
                          .createAndAttachPromo(
                            description: descCtrl.text.trim(),
                            unlimited: forEveryone,
                            limit: forEveryone ? null : int.tryParse(limitCtrl.text),
                            dateStart: startDate,
                            dateEnd: endDate,
                            partyId: partyId,
                          );
                      if (!context.mounted) return;
                      Navigator.pop(dialogContext);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Promo créée.'),
                          action: SnackBarAction(
                            label: 'Ajouter articles',
                            onPressed: () =>
                                _openAddPromoItemDialog(context, ref, promoId),
                          ),
                        ),
                      );
                    } catch (_) {}
                  },
                  child: const Text('Enregistrer'),
                ),
              ],
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

    final items = await ref.read(menuItemsByPlaceProvider(place).future);
    if (!context.mounted) return;

    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aucun article disponible dans le menu.')),
      );
      return;
    }

    MenuItemOptionEntity? selectedItem = items.first;
    bool isFreeOffer = true;
    String discountType = 'percentage';
    final valueCtrl = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E1E1E),
              title: const Text('Ajouter article', style: TextStyle(color: Colors.white)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<MenuItemOptionEntity>(
                    value: selectedItem,
                    items: items
                        .map(
                          (item) => DropdownMenuItem(
                            value: item,
                            child: Text('${item.name} (${item.price.toStringAsFixed(2)})'),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => setStateDialog(() => selectedItem = value),
                    decoration: const InputDecoration(labelText: 'Article du menu'),
                  ),
                  CheckboxListTile(
                    value: isFreeOffer,
                    title: const Text('Offre gratuite'),
                    onChanged: (value) => setStateDialog(() {
                      isFreeOffer = value ?? true;
                    }),
                  ),
                  if (!isFreeOffer) ...[
                    DropdownButtonFormField<String>(
                      value: discountType,
                      items: const [
                        DropdownMenuItem(value: 'percentage', child: Text('Pourcentage')),
                        DropdownMenuItem(value: 'amount', child: Text('Montant')),
                      ],
                      onChanged: (value) =>
                          setStateDialog(() => discountType = value ?? 'percentage'),
                      decoration: const InputDecoration(labelText: 'Type réduction'),
                    ),
                    TextField(
                      controller: valueCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Valeur réduction'),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final selected = selectedItem;
                    if (selected == null) return;
                    final discountValue = double.tryParse(valueCtrl.text.replaceAll(',', '.'));
                    if (!isFreeOffer && (discountValue == null || discountValue <= 0)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Valeur réduction invalide.')),
                      );
                      return;
                    }

                    try {
                      await ref.read(promotionsActionProvider.notifier).addItemToPromo(
                        promoId: promoId,
                        itemId: selected.id,
                        isFreeOffer: isFreeOffer,
                        discountType: isFreeOffer ? null : discountType,
                        discountValue: isFreeOffer ? null : discountValue,
                      );
                      if (!context.mounted) return;
                      Navigator.pop(dialogContext);
                    } catch (_) {}
                  },
                  child: const Text('Ajouter'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _PromotionCard extends StatelessWidget {
  const _PromotionCard({required this.promotion, required this.onAddItem});

  final PromotionEntity promotion;
  final VoidCallback onAddItem;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(14),
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
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              OutlinedButton.icon(
                onPressed: onAddItem,
                icon: const Icon(Icons.add_shopping_cart),
                label: const Text('Ajouter articles'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            promotion.forEveryone
                ? 'Pour tout le monde'
                : 'Limite: ${promotion.limit ?? 0}',
            style: const TextStyle(color: Colors.white70),
          ),
          Text(
            'Du ${promotion.dateStart.toLocal()} au ${promotion.dateEnd.toLocal()}',
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 8),
          if (promotion.items.isEmpty)
            const Text('Aucun article lié.', style: TextStyle(color: Colors.grey))
          else
            ...promotion.items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  item.isFreeOffer
                      ? '• ${item.itemName} gratuit'
                      : '• ${item.itemName} - ${item.discountType} ${item.discountValue}',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
