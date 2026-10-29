import 'package:flutter/material.dart';

class StatusChip extends StatelessWidget {
  final String status;

  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color text;
    Color dot;

    switch (status) {
      case 'Checked In':
        bg = const Color(0xFFDCFCE7);
        text = const Color(0xFF15803D);
        dot = const Color(0xFF16A34A);
        break;
      case 'Checked Out':
        bg = const Color(0xFFF1F5F9);
        text = const Color(0xFF475569);
        dot = const Color(0xFF94A3B8);
        break;
      case 'Registered':
      default:
        bg = const Color(0xFFFEF3C7);
        text = const Color(0xFFB45309);
        dot = const Color(0xFFF59E0B);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: dot.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: dot,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            status,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: text,
            ),
          ),
        ],
      ),
    );
  }
}
