import 'package:cheza_app/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HistoryTab extends ConsumerWidget {
  const HistoryTab({super.key, required this.placeId});

  final int? placeId;

  String _formatDate(DateTime dt) =>
      "${dt.day.toString().padLeft(2, '0')}/"
      "${dt.month.toString().padLeft(2, '0')}/"
      "${dt.year}";

  String _formatHour(DateTime dt) =>
      "${dt.hour.toString().padLeft(2, '0')}:"
      "${dt.minute.toString().padLeft(2, '0')}";

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (placeId == null) {
      return const Center(child: Text('Lieu introuvable'));
    }

    final partiesAsync = ref.watch(closedPartiesProvider(placeId!));

    return partiesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Center(
        child: Text(
          'Erreur de chargement de l\'historique',
          style: TextStyle(color: Colors.grey),
        ),
      ),
      data: (parties) {
        if (parties.isEmpty) {
          return const Center(
            child: Text(
              'Aucune fête dans l’historique',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: parties.length,
          itemBuilder: (_, i) {
            final p = parties[i];

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
                    p.name.isEmpty ? 'Fête' : p.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ouverture : ${_formatDate(p.dateStarted)} à ${_formatHour(p.dateStarted)}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  Text(
                    'Fermeture : ${_formatDate(p.dateClosed)} à ${_formatHour(p.dateClosed)}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
