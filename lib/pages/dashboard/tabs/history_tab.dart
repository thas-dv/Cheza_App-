import 'package:cheza_app/services/supabase_service_parties.dart';
import 'package:flutter/material.dart';

class HistoryTab extends StatefulWidget {
  final int? placeId;

  const HistoryTab({super.key, required this.placeId});

  @override
  State<HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab> {
  bool loading = true;
  List<Map<String, dynamic>> parties = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  // ================= LOAD HISTORY =================
  Future<void> _loadHistory() async {
    if (widget.placeId == null) {
      setState(() => loading = false);
      return;
    }

    try {
      setState(() => loading = true);

      final res =
          await SupabaseServiceParties.fetchClosedPartiesForPlace(
            widget.placeId!,
          );

      if (!mounted) return;

      setState(() {
        parties = res;
        loading = false;
      });
    } catch (e) {
      debugPrint("❌ History load error: $e");
      if (!mounted) return;
      setState(() => loading = false);
    }
  }

  // ================= FORMAT =================
  String _formatDate(DateTime dt) =>
      "${dt.day.toString().padLeft(2, '0')}/"
      "${dt.month.toString().padLeft(2, '0')}/"
      "${dt.year}";

  String _formatHour(DateTime dt) =>
      "${dt.hour.toString().padLeft(2, '0')}:"
      "${dt.minute.toString().padLeft(2, '0')}";

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (parties.isEmpty) {
      return const Center(
        child: Text(
          "Aucune fête dans l’historique",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: parties.length,
      itemBuilder: (_, i) {
        final p = parties[i];
        final open = DateTime.parse(p['date_started']).toLocal();
        final close = DateTime.parse(p['date_closed']).toLocal();

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                p['name_party'] ?? 'Fête',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Ouverture : ${_formatDate(open)} à ${_formatHour(open)}",
                style: const TextStyle(color: Colors.grey),
              ),
              Text(
                "Fermeture : ${_formatDate(close)} à ${_formatHour(close)}",
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        );
      },
    );
  }
}
