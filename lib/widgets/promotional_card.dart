
// class PromotionalCard extends StatelessWidget {
//   final String title;
//   final String actionText;
//   final VoidCallback onTap;

//   const _PromotionalCard({
//     required this.title,
//     required this.actionText,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: const Color(0xFFE0F7FA),
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               title,
//               style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade700),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               actionText,
//               style: GoogleFonts.poppins(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: const Color(0xFF23918C),
//               ),
//             ),
//             const SizedBox(height: 8),
//             const Icon(Icons.local_car_wash, size: 40, color: Color(0xFF23918C)),
//           ],
//         ),
//       ),
//     );
//   }
// }
