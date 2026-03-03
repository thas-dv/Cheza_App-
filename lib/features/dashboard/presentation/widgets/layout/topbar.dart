import 'package:flutter/material.dart';

class TopBar extends StatelessWidget {
  final bool isOpen;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final bool isStatusUpdating;
  final VoidCallback onToggleStatus;

  const TopBar({
    super.key,
    required this.isOpen,
    required this.selectedIndex,
    required this.onSelect,
    required this.onToggleStatus,
    required this.isStatusUpdating,
  });

  @override
  Widget build(BuildContext context) {
    const tabs = ['Dashboard', 'Clientèle', 'Notes', 'Posts'];

    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.05)),
        ),
      ),
      child: Row(
        children: [
          // Navigation
          Expanded(
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              children: List.generate(tabs.length, (index) {
                final isSelected = selectedIndex == index;
                return InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => onSelect(index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white.withOpacity(0.08)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      tabs[index],
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.white60,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),

          // Badge de Statut
          FilledButton.tonalIcon(
            onPressed: isStatusUpdating ? null : onToggleStatus,
            icon: isStatusUpdating
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(isOpen ? Icons.lock_outline : Icons.lock_open_outlined),
            style: FilledButton.styleFrom(
              backgroundColor: isOpen
                  ? Colors.red.withOpacity(0.15)
                  : Colors.green.withOpacity(0.15),
              side: BorderSide(
                color: isOpen
                    ? Colors.red.withOpacity(0.4)
                    : Colors.green.withOpacity(0.4),
              ),
            ),
            label: Text(
              isOpen ? 'Fermer' : 'Ouvrir',
              style: TextStyle(
                color: isOpen ? Colors.redAccent : Colors.greenAccent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
