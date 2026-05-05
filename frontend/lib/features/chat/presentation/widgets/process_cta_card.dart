import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../domain/entities/chat_cta_card.dart';

class ProcessCtaCard extends StatelessWidget {
  const ProcessCtaCard({
    super.key,
    required this.card,
    required this.onTap,
    this.enabled = true,
  });

  final ChatCtaCard card;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return ChatActionCard(
      card: card,
      icon: Icons.recycling_rounded,
      onTap: onTap,
      enabled: enabled,
    );
  }
}

class ChatActionCard extends StatelessWidget {
  const ChatActionCard({
    super.key,
    required this.card,
    required this.icon,
    required this.onTap,
    this.enabled = true,
  });

  final ChatCtaCard card;
  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 142,
      child: Material(
        color: enabled ? Colors.white : const Color(0xFFF5E9E2),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: enabled ? onTap : null,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(color: AnaboolColors.border),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: AnaboolColors.brown, size: 20),
                const SizedBox(height: 8),
                Text(
                  card.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AnaboolColors.ink,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  card.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AnaboolColors.brownDark,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
