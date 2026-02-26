// lib/widgets/stat_card.dart

import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  final String label;
  final String value;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1F1F1F),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: Colors.grey.shade400)),
        ],
      ),
    );
  }
}
