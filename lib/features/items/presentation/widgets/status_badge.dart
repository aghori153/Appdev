import 'package:flutter/material.dart';

Color statusColor(String status) {
  if (status == 'Lost') return const Color(0xFFC62828);
  if (status == 'Found') return const Color(0xFF2E7D32);
  return const Color(0xFF546E7A);
}

IconData statusIcon(String status) {
  if (status == 'Lost') return Icons.help_outline;
  if (status == 'Found') return Icons.location_on_outlined;
  return Icons.check_circle_outline;
}

IconData categoryIcon(String category) {
  switch (category) {
    case 'Bag':
      return Icons.backpack_outlined;
    case 'Accessory':
      return Icons.umbrella_outlined;
    case 'ID Card':
      return Icons.badge_outlined;
    case 'Electronics':
      return Icons.power_outlined;
    case 'Keys':
      return Icons.key_outlined;
    case 'Book':
      return Icons.menu_book_outlined;
    case 'Clothing':
      return Icons.checkroom_outlined;
    default:
      return Icons.category_outlined;
  }
}

class StatusBadge extends StatelessWidget {
  final String status;
  final bool large;

  const StatusBadge({super.key, required this.status, this.large = false});

  @override
  Widget build(BuildContext context) {
    final color = statusColor(status);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.symmetric(
        horizontal: large ? 14 : 10,
        vertical: large ? 7 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon(status), size: large ? 18 : 14, color: color),
          const SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: large ? 14 : 12,
            ),
          ),
        ],
      ),
    );
  }
}
