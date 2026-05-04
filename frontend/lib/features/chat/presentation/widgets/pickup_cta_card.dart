import 'package:flutter/material.dart';

import '../../domain/entities/chat_cta_card.dart';
import 'process_cta_card.dart';

class PickupCtaCard extends StatelessWidget {
  const PickupCtaCard({
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
      icon: Icons.local_shipping_rounded,
      onTap: onTap,
      enabled: enabled,
    );
  }
}
