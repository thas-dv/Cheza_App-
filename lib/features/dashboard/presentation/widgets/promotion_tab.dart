import 'package:cheza_app/services/supabase_service_promos.dart';
import 'package:flutter/material.dart';

class PromotionPage extends StatefulWidget {
  final int? placeId;
  final int? activePartyId;
  final String placeName;

  const PromotionPage({
    super.key,
    required this.placeId,
    required this.activePartyId,
    required this.placeName,
  });

  @override
  State<PromotionPage> createState() => _PromotionPageState();
}

class _PromotionPageState extends State<PromotionPage> {
  final TextEditingController descriptionCtrl = TextEditingController();
  final TextEditingController expirationCtrl = TextEditingController();

  final TextEditingController partyCtrl = TextEditingController(
    text: "Soirée Cabaret",
  );
  List<Map<String, dynamic>> promotions = [];
  bool loading = true;

  Future<void> _loadPromotions() async {
    if (widget.activePartyId == null) return;

    setState(() => loading = true);

    final data = await SupabaseServicePromotion.fetchPromotionsByParty(
      widget.activePartyId!,
    );
    if (!mounted) return;
    setState(() {
      promotions = data;
      loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadPromotions();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width > 1100
        ? 3
        : width > 700
        ? 2
        : 1;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/images/fondprincipal.png",
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(color: const Color(0xFF0B1120).withOpacity(0.85)),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// HEADER
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Nos Promotions",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _openAddPromotionDialog,
                        child: const Text("Ajouter"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  /// BODY
                  if (loading)
                    Expanded(
                      child: promotions.isEmpty
                          ? GridView.builder(
                              itemCount: promotions.length,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: crossAxisCount,
                                    crossAxisSpacing: 20,
                                    mainAxisSpacing: 20,
                                    childAspectRatio: 0.78,
                                  ),
                              itemBuilder: (context, index) {
                                final promo = promotions[index];
                                return _promotionCard(promo);
                              },
                            )
                          : _emptyPromotionState(),
                    )
                  else
                    Expanded(
                      child: GridView.builder(
                        itemCount: promotions.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 20,
                          childAspectRatio: 0.78,
                        ),
                        itemBuilder: (context, index) {
                          final promo = promotions[index];
                          return _promotionCard(promo);
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  ////////////////////////////////////
  Widget _emptyPromotionState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.local_offer_outlined, size: 70, color: Colors.grey),
          const SizedBox(height: 20),
          const Text(
            "Aucune promotion pour le moment",
            style: TextStyle(color: Colors.grey, fontSize: 18),
          ),
          const SizedBox(height: 10),
          const Text(
            "Créez votre première promotion pour attirer plus de clients.",
            style: TextStyle(color: Colors.grey, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 25),
          ElevatedButton(
            onPressed: _openAddPromotionDialog,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6A5AE0),
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text("Créer une promotion"),
          ),
        ],
      ),
    );
  }

  /////////////////////////////////////////////
  void _confirmDeletePromotion(Map promo) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text("Supprimer ?", style: TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () async {
              final promoData = promo['promos'];
              if (promoData == null) return;

              await SupabaseServicePromotion.deletePromotion(promoData['id']);
              if (!mounted || !context.mounted) return;
              Navigator.pop(context);
              _loadPromotions();
            },
            child: const Text("Supprimer"),
          ),
        ],
      ),
    );
  }
  //////////////////////////////////////

  // ================= FORM =================

  // ================= PREVIEW =================

  //////////////////////////
  Widget _promotionCard(Map<String, dynamic> promo) {
    final promoData = promo['promos'] as Map<String, dynamic>?;

    final String description =
        promoData?['promo_desc']?.toString() ?? "Sans description";

    final int limite = promoData?['limite'] ?? 0;

    DateTime? expiration;
    if (promo['date_expire'] != null) {
      expiration = DateTime.tryParse(promo['date_expire'].toString());
    }

    final bool isExpired =
        expiration != null && expiration.isBefore(DateTime.now());

    final bool isSoon =
        expiration != null &&
        !isExpired &&
        expiration.difference(DateTime.now()).inDays <= 2;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isExpired
              ? Colors.red.withOpacity(0.4)
              : Colors.white.withOpacity(0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// HEADER
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.edit,
                        color: Colors.orange,
                        size: 20,
                      ),
                      onPressed: promoData == null
                          ? null
                          : () => _openEditPromotionDialog(promo),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.red,
                        size: 20,
                      ),
                      onPressed: promoData == null
                          ? null
                          : () => _confirmDeletePromotion(promo),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                if (expiration != null)
                  Row(
                    children: [
                      Text(
                        "Expire le ${expiration.toString().split(' ')[0]}",
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isExpired
                              ? Colors.red
                              : isSoon
                              ? Colors.orange
                              : Colors.green,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isExpired
                              ? "EXPIRÉ"
                              : isSoon
                              ? "Bientôt"
                              : "ACTIVE",
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),

                const SizedBox(height: 10),
                Divider(color: Colors.white.withOpacity(0.1)),
                const SizedBox(height: 10),

                Text(
                  description,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),

          /// IMAGE + BADGE %
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(18),
                    bottomRight: Radius.circular(18),
                  ),
                  child: Image.asset(
                    // ✅ FIX
                    "assets/images/fondprincipal.png",
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),

                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6A5AE0), Color(0xFFB44CFF)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "$limite%",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  ///////////////////////////
  void _openEditPromotionDialog(Map<String, dynamic> promo) {
    final promoData = promo['promos']; // 👈 car jointure
    final descCtrl = TextEditingController(text: promoData['promo_desc']);
    final limiteCtrl = TextEditingController(
      text: promoData['limite'].toString(),
    );

    bool saving = false;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setLocalState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1E1E1E),
            title: const Text(
              "Modifier la promotion",
              style: TextStyle(color: Colors.white),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: descCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(labelText: "Description"),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: limiteCtrl,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: "Limite / % réduction",
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: saving ? null : () => Navigator.pop(context),
                child: const Text("Annuler"),
              ),
              ElevatedButton(
                onPressed: saving
                    ? null
                    : () async {
                        if (descCtrl.text.isEmpty || limiteCtrl.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Tous les champs sont requis."),
                            ),
                          );
                          return;
                        }

                        setLocalState(() => saving = true);

                        await SupabaseServicePromotion.updatePromotion(
                          promoId: promoData['id'],
                          description: descCtrl.text.trim(),
                          limite:
                              int.tryParse(
                                limiteCtrl.text.replaceAll("%", "").trim(),
                              ) ??
                              0,
                        );
                        if (!mounted || !context.mounted) return;
                        Navigator.pop(context);
                        _loadPromotions(); // 🔄 refresh UI
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
                    : const Text("Modifier"),
              ),
            ],
          );
        },
      ),
    );
  }
  ////////////////////////////////
  // void _confirmDeletePromotion(Map promo) {
  //   showDialog(
  //     context: context,
  //     builder: (_) => AlertDialog(
  //       backgroundColor: const Color(0xFF1E1E1E),
  //       title: const Text(
  //         "Supprimer cette promotion ?",
  //         style: TextStyle(color: Colors.white),
  //       ),
  //       content: const Text(
  //         "Cette action est irréversible.",
  //         style: TextStyle(color: Colors.grey),
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: const Text("Annuler"),
  //         ),
  //         ElevatedButton(
  //           style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
  //           onPressed: () {
  //             setState(() {
  //               promotions.remove(promo);
  //             });
  //             Navigator.pop(context);
  //           },
  //           child: const Text("Supprimer"),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // ================= BUTTON =================

  void _openAddPromotionDialog() {
    if (widget.activePartyId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Aucune fête active.")));
      return;
    }

    final descCtrl = TextEditingController();
    final limiteCtrl = TextEditingController();
    DateTime? expireDate;
    bool saving = false;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setLocalState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1E1E1E),
            title: const Text(
              "Ajouter une promotion",
              style: TextStyle(color: Colors.white),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: descCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(labelText: "Description"),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: limiteCtrl,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: "Limite / % réduction",
                    ),
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (!mounted || !context.mounted) return;
                      if (picked != null) {
                        expireDate = picked;
                        setLocalState(() {});
                      }
                    },
                    child: Text(
                      expireDate == null
                          ? "Choisir date expiration"
                          : "Expire le ${expireDate!.toString().split(' ')[0]}",
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: saving ? null : () => Navigator.pop(context),
                child: const Text("Annuler"),
              ),
              ElevatedButton(
                onPressed: saving
                    ? null
                    : () async {
                        if (descCtrl.text.isEmpty ||
                            limiteCtrl.text.isEmpty ||
                            expireDate == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Tous les champs sont requis."),
                            ),
                          );
                          return;
                        }

                        setLocalState(() => saving = true);

                        final success =
                            await SupabaseServicePromotion.insertPromotion(
                              partyId: widget.activePartyId!,
                              description: descCtrl.text.trim(),
                              limite:
                                  int.tryParse(
                                    limiteCtrl.text.replaceAll("%", "").trim(),
                                  ) ??
                                  0,
                              expireDate: expireDate!,
                            );
                        if (!mounted || !context.mounted) return;
                        if (!success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Erreur réseau. Réessayez."),
                            ),
                          );
                        }

                        Navigator.pop(context);
                        _loadPromotions(); // 🔄 refresh UI
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
                    : const Text("Créer"),
              ),
            ],
          );
        },
      ),
    );
  }
}
