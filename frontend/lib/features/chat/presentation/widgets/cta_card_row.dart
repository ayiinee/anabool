import 'package:flutter/material.dart';

import '../../domain/entities/chat_cta_card.dart';
import 'dispose_cta_card.dart';
import 'pickup_cta_card.dart';
import 'process_cta_card.dart';

class CtaCardRow extends StatelessWidget {
  const CtaCardRow({
    super.key,
    required this.cards,
    required this.onSelected,
    this.enabled = true,
  });

  final List<ChatCtaCard> cards;
  final ValueChanged<ChatCtaCard> onSelected;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 128,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        itemCount: cards.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final card = cards[index];

          switch (card.cardType) {
            case 'pickup':
              return PickupCtaCard(
                card: card,
                onTap: () => onSelected(card),
                enabled: enabled,
              );
            case 'process':
              return ProcessCtaCard(
                card: card,
                onTap: () => onSelected(card),
                enabled: enabled,
              );
            case 'dispose':
              return DisposeCtaCard(
                card: card,
                onTap: () => onSelected(card),
                enabled: enabled,
              );
            default:
              return ProcessCtaCard(
                card: card,
                onTap: () => onSelected(card),
                enabled: enabled,
              );
          }
        },
      ),
    );
  }
}
