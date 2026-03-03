// import 'package:flutter/material.dart';

// class StatsRow extends StatelessWidget {
//   final int visitors;
//   final int posts;
//   final int notes;
//   final int engagement;

//   final VoidCallback onVisitorsTap;
//   final VoidCallback onPostsTap;
//   final VoidCallback onNotesTap;
//   final VoidCallback onEngagementTap;

//   const StatsRow({
//     super.key,
//     required this.visitors,
//     required this.posts,
//     required this.notes,
//     required this.engagement,
//     required this.onVisitorsTap,
//     required this.onPostsTap,
//     required this.onNotesTap,
//     required this.onEngagementTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         int crossAxisCount = 1;

//         if (constraints.maxWidth > 1200) {
//           crossAxisCount = 4;
//         } else if (constraints.maxWidth > 800) {
//           crossAxisCount = 2;
//         }

//         return GridView.count(
//           crossAxisCount: crossAxisCount,
//           shrinkWrap: true,
//           physics: const NeverScrollableScrollPhysics(),
//           crossAxisSpacing: 16,
//           mainAxisSpacing: 16,
//           childAspectRatio: 1.8,
//           children: [
//             _card(
//               "Visiteurs",
//               visitors,
//               Icons.group,
//               Colors.blue,
//               onVisitorsTap,
//             ),
//             _card("Posts", posts, Icons.photo, Colors.purple, onPostsTap),
//             _card("Notes", notes, Icons.star, Colors.orange, onNotesTap),
//             _card(
//               "Engagement",
//               engagement,
//               Icons.show_chart,
//               Colors.green,
//               onEngagementTap,
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Widget _card(
//     String title,
//     int value,
//     IconData icon,
//     Color color,
//     VoidCallback onTap,
//   ) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(20),
//       child: Container(
//         padding: const EdgeInsets.all(20),
//         decoration: BoxDecoration(
//           color: const Color(0xFF1C1F26),
//           borderRadius: BorderRadius.circular(20),
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(icon, size: 36, color: color),
//             const SizedBox(height: 10),
//             Text(
//               value.toString(),
//               style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 4),
//             Text(title, style: const TextStyle(color: Colors.grey)),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';

class StatsRow extends StatelessWidget {
  final double revenue;
  final int bookings;

  const StatsRow({
    super.key, 
    required this.revenue, 
    required this.bookings
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _buildCard("Revenus", "${revenue.toStringAsFixed(2)} €", Icons.euro, Colors.red)),
        const SizedBox(width: 15),
        Expanded(child: _buildCard("Réservations", bookings.toString(), Icons.book_online, Colors.blueAccent)),
      ],
    );
  }

  Widget _buildCard(String title, String val, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(val, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          Text(title, style: const TextStyle(color: Colors.white54, fontSize: 13)),
        ],
      ),
    );
  }
}