import 'package:flutter/material.dart';

import '../../../../app/theme.dart';

class SafetyModeCard extends StatelessWidget {
  const SafetyModeCard({
    super.key,
    required this.enabled,
    required this.onChanged,
    this.compact = false,
  });

  final bool enabled;
  final ValueChanged<bool> onChanged;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(compact ? 13 : 16),
      decoration: BoxDecoration(
        color: enabled ? const Color(0xFFFFF7F1) : Colors.white,
        border: Border.all(color: const Color(0xFFF0C7B4)),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: compact ? 38 : 46,
            height: compact ? 38 : 46,
            decoration: BoxDecoration(
              color: enabled ? AnaboolColors.brown : const Color(0xFFE7E5E4),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              enabled ? Icons.health_and_safety_rounded : Icons.shield_outlined,
              color: enabled ? Colors.white : AnaboolColors.muted,
              size: compact ? 22 : 26,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Safety Mode',
                  style: TextStyle(
                    color: AnaboolColors.ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  enabled
                      ? 'Peringatan kesehatan dan sanitasi aktif.'
                      : 'Aktifkan untuk pengingat risiko kotoran anabul.',
                  maxLines: compact ? 1 : 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AnaboolColors.muted,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: enabled,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: AnaboolColors.brown,
            inactiveTrackColor: const Color(0xFFE7E5E4),
            inactiveThumbColor: Colors.white,
          ),
        ],
      ),
    );
  }
}
