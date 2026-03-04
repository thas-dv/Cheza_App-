// import 'package:flutter/material.dart';

// class TopBar extends StatelessWidget {
//   final bool isOpen;
//   final int selectedIndex;
//   final ValueChanged<int> onSelect;
//   final bool isStatusUpdating;
//   final VoidCallback onToggleStatus;
//   final bool isLargeScreen;
//   final VoidCallback? onMenuPressed;
//   const TopBar({
//     super.key,
//     required this.isLargeScreen,
//     this.onMenuPressed,
//     required this.isOpen,
//     required this.selectedIndex,
//     required this.onSelect,
//     required this.onToggleStatus,
//     required this.isStatusUpdating,
//   });

//   @override
//   Widget build(BuildContext context) {
//     const tabs = ['Dashboard', 'Clientèle', 'Notes', 'Posts'];
//     final horizontalPadding = isLargeScreen ? 24.0 : 12.0;
// return SafeArea(
//       bottom: false,
//       child: Container(
//         height: isLargeScreen ? 80 : 72,
//         padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
//         decoration: BoxDecoration(
//           color: const Color(0xFF0F172A),
//           border: Border(
//             bottom: BorderSide(color: Colors.white.withOpacity(0.05)),
//           ),
//         ),
//       ),
//       child: Row(
//           children: [
//             if (!isLargeScreen) ...[
//               Builder(
//                 builder: (context) => IconButton(
//                   icon: const Icon(Icons.menu, color: Colors.white),
//                   onPressed:
//                       onMenuPressed ?? () => Scaffold.of(context).openDrawer(),
//                 ),
//               ),
//                  const SizedBox(width: 4),
//               const Expanded(
//                 child: Text(
//                   'Dashboard',
//                   overflow: TextOverflow.ellipsis,
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.w700,
//                     fontSize: 18,
//                   ),
//                 ),
//               ),
//             ] else
//               Expanded(
//                 child: Wrap(
//                   spacing: 8,
//                   runSpacing: 4,
//                   children: List.generate(tabs.length, (index) {
//                     final isSelected = selectedIndex == index;
//                     return InkWell(
//                       borderRadius: BorderRadius.circular(12),
//                       onTap: () => onSelect(index),
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 14,
//                           vertical: 10,
//                         ),
//                         decoration: BoxDecoration(
//                           color: isSelected
//                               ? Colors.white.withOpacity(0.08)
//                               : Colors.transparent,
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: Text(
//                           tabs[index],
//                           style: TextStyle(
//                             color: isSelected ? Colors.white : Colors.white60,
//                             fontWeight: isSelected
//                                 ? FontWeight.w700
//                                 : FontWeight.w500,
//                           ),
//                         ),
//                       ),
//                     );
//                   }),
//                 ),
//               ),
//             )

//            // Badge de Statut
//             FilledButton.tonalIcon(
//               onPressed: isStatusUpdating ? null : onToggleStatus,
//               icon: isStatusUpdating
//                   ? const SizedBox(
//                       width: 16,
//                       height: 16,
//                       child: CircularProgressIndicator(strokeWidth: 2),
//                     )
//                   : Icon(isOpen ? Icons.lock_outline : Icons.lock_open_outlined),
//                style: FilledButton.styleFrom(
//                 padding: EdgeInsets.symmetric(
//                   horizontal: isLargeScreen ? 16 : 10,
//                   vertical: isLargeScreen ? 10 : 8,
//                 ),
//                 backgroundColor: isOpen
//                     ? Colors.red.withOpacity(0.15)
//                     : Colors.green.withOpacity(0.15),
//                 side: BorderSide(
//                   color: isOpen
//                       ? Colors.red.withOpacity(0.4)
//                       : Colors.green.withOpacity(0.4),
//                ) ),

//              label: Text(
//                 isOpen ? 'Fermer' : 'Ouvrir',
//                 style: TextStyle(
//                   color: isOpen ? Colors.redAccent : Colors.greenAccent,
//                   fontWeight: FontWeight.w700,
//             ))
//          )
//         );
//   }
// }
import 'package:flutter/material.dart';

class TopBar extends StatelessWidget {
  final bool isOpen;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final bool isStatusUpdating;
  final VoidCallback onToggleStatus;
  final bool isLargeScreen;
  final VoidCallback? onMenuPressed;

  const TopBar({
    super.key,
    required this.isLargeScreen,
    this.onMenuPressed,
    required this.isOpen,
    required this.selectedIndex,
    required this.onSelect,
    required this.onToggleStatus,
    required this.isStatusUpdating,
  });

  @override
  Widget build(BuildContext context) {
    const tabs = ['Dashboard', 'Clientèle', 'Notes', 'Posts'];
    final horizontalPadding = isLargeScreen ? 24.0 : 12.0;

    return SafeArea(
      bottom: false,
      child: Container(
        height: isLargeScreen ? 80 : 72,
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          border: Border(
            bottom: BorderSide(color: Colors.white.withOpacity(0.05)),
          ),
        ),
        child: Row(
          children: [
            /// Menu mobile
            if (!isLargeScreen) ...[
              Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white),
                  onPressed:
                      onMenuPressed ?? () => Scaffold.of(context).openDrawer(),
                ),
              ),
              const SizedBox(width: 4),
              const Expanded(
                child: Text(
                  'Dashboard',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
              ),
            ]
            /// Onglets desktop
            else
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isOpen
                    ? Colors.green.withOpacity(0.15)
                    : Colors.red.withOpacity(0.15),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                isOpen ? 'Ouvert' : 'Fermé',
                style: TextStyle(
                  color: isOpen ? Colors.greenAccent : Colors.redAccent,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 10),

            /// Bouton ouvrir / fermer
            FilledButton.tonalIcon(
              onPressed: isStatusUpdating ? null : onToggleStatus,
              icon: isStatusUpdating
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      isOpen ? Icons.lock_outline : Icons.lock_open_outlined,
                    ),
              style: FilledButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: isLargeScreen ? 16 : 10,
                  vertical: isLargeScreen ? 10 : 8,
                ),
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
      ),
    );
  }
}
