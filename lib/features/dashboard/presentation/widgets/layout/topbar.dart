import 'package:flutter/material.dart';

class TopBar extends StatelessWidget {
  final bool isOpen;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const TopBar({
    super.key,
    required this.isOpen,
    required this.selectedIndex,
    required this.onSelect,
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
          FilledButton.tonal(
            onPressed: () {},
            style: FilledButton.styleFrom(
              backgroundColor: isOpen
                  ? Colors.green.withOpacity(0.15)
                  : Colors.red.withOpacity(0.15),
              side: BorderSide(
                color: isOpen
                    ? Colors.green.withOpacity(0.4)
                    : Colors.red.withOpacity(0.4),
              ),
            ),
            child: Text(
              isOpen ? 'Ouvert' : 'Fermé',
              style: TextStyle(
                color: isOpen ? Colors.greenAccent : Colors.redAccent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
