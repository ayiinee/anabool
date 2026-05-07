import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../core/constants/asset_constants.dart';
import '../../domain/entities/chat_cta_card.dart';

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
    final orderedCards = _orderedCards(cards);
    final pickupCard = orderedCards.where(_isPickup).firstOrNull;
    final processCard = orderedCards.where(_isProcess).firstOrNull;
    final disposeCard = orderedCards.where(_isDispose).firstOrNull;
    final topCards = [
      if (pickupCard != null) pickupCard,
      if (processCard != null) processCard,
      if (pickupCard == null || processCard == null)
        ...orderedCards.where(
          (card) =>
              card != disposeCard && card != pickupCard && card != processCard,
        ),
    ].take(2).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontalPadding = constraints.maxWidth >= 390 ? 50.0 : 20.0;
        final gap = constraints.maxWidth >= 360 ? 14.0 : 10.0;
        final contentWidth = constraints.maxWidth - (horizontalPadding * 2);
        final topCardWidth = (contentWidth - gap) / 2;

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  for (var i = 0; i < topCards.length; i++) ...[
                    Expanded(
                      child: _ReferenceActionCard(
                        card: topCards[i],
                        width: topCardWidth,
                        height: 190,
                        spec: _specFor(topCards[i]),
                        enabled: enabled,
                        onTap: () => onSelected(topCards[i]),
                      ),
                    ),
                    if (i != topCards.length - 1) SizedBox(width: gap),
                  ],
                ],
              ),
              if (disposeCard != null) ...[
                const SizedBox(height: 22),
                _ReferenceActionCard(
                  card: disposeCard,
                  width: contentWidth,
                  height: 162,
                  spec: _CtaCardSpec.dispose,
                  enabled: enabled,
                  onTap: () => onSelected(disposeCard),
                  wide: true,
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  List<ChatCtaCard> _orderedCards(List<ChatCtaCard> cards) {
    final ordered = <ChatCtaCard>[
      ...cards.where(_isPickup),
      ...cards.where(_isProcess),
      ...cards.where(_isDispose),
      ...cards.where(
          (card) => !_isPickup(card) && !_isProcess(card) && !_isDispose(card)),
    ];
    return ordered;
  }

  bool _isPickup(ChatCtaCard card) => card.cardType == 'pickup';
  bool _isProcess(ChatCtaCard card) => card.cardType == 'process';
  bool _isDispose(ChatCtaCard card) => card.cardType == 'dispose';

  _CtaCardSpec _specFor(ChatCtaCard card) {
    if (_isPickup(card)) return _CtaCardSpec.pickup;
    if (_isDispose(card)) return _CtaCardSpec.dispose;
    return _CtaCardSpec.process;
  }
}

class _ReferenceActionCard extends StatelessWidget {
  const _ReferenceActionCard({
    required this.card,
    required this.width,
    required this.height,
    required this.spec,
    required this.enabled,
    required this.onTap,
    this.wide = false,
  });

  final ChatCtaCard card;
  final double width;
  final double height;
  final _CtaCardSpec spec;
  final bool enabled;
  final VoidCallback onTap;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final title = card.title.trim().isEmpty ? spec.title : card.title;
    final description =
        card.description.trim().isEmpty ? spec.description : card.description;
    final ctaLabel = card.ctaLabel.trim().isEmpty
        ? (card.opensRoute ? 'Pelajari Selengkapnya' : 'Pilih')
        : card.ctaLabel;
    final headerHeight = wide ? 108.0 : 112.0;

    return SizedBox(
      width: width,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
              color: Color(0x26000000),
              blurRadius: 7,
              spreadRadius: -1,
              offset: Offset(2, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Material(
            color: Colors.white,
            child: InkWell(
              onTap: enabled ? onTap : null,
              child: Opacity(
                opacity: enabled ? 1 : 0.58,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      height: headerHeight,
                      child: _CardHero(
                        spec: spec,
                        title: title,
                        wide: wide,
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          wide ? 10 : 8,
                          wide ? 8 : 8,
                          wide ? 10 : 8,
                          5,
                        ),
                        child: Text(
                          description,
                          maxLines: wide ? 2 : 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AnaboolColors.ink.withValues(alpha: 0.72),
                            fontSize: wide ? 13 : 12,
                            fontWeight: FontWeight.w900,
                            height: 1.05,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        wide ? 10 : 8,
                        0,
                        wide ? 10 : 8,
                        wide ? 9 : 8,
                      ),
                      child: _CtaPill(
                        label: ctaLabel,
                        enabled: enabled,
                        opensRoute: card.opensRoute,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CtaPill extends StatelessWidget {
  const _CtaPill({
    required this.label,
    required this.enabled,
    required this.opensRoute,
  });

  final String label;
  final bool enabled;
  final bool opensRoute;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: enabled ? AnaboolColors.brown : AnaboolColors.brownSoft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              opensRoute
                  ? Icons.arrow_forward_rounded
                  : Icons.touch_app_rounded,
              color: Colors.white,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}

class _CardHero extends StatelessWidget {
  const _CardHero({
    required this.spec,
    required this.title,
    required this.wide,
  });

  final _CtaCardSpec spec;
  final String title;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final foregroundWidth = wide ? 112.0 : 84.0;
    final shadowWidth = wide ? 148.0 : 104.0;
    final foregroundRight = wide ? 30.0 : 10.0;
    final shadowRight = wide ? 42.0 : 28.0;

    return ClipRect(
      child: ColoredBox(
        color: AnaboolColors.brown,
        child: Stack(
          children: [
            Positioned(
              right: shadowRight,
              bottom: wide ? 0 : 9,
              child: Opacity(
                opacity: 0.12,
                child: Image.asset(
                  spec.imageAsset,
                  width: shadowWidth,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Positioned(
              left: wide ? 16 : 14,
              top: wide ? 12 : 15,
              right: wide ? 150 : 68,
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: wide ? 20 : 18,
                  fontWeight: FontWeight.w900,
                  height: 0.94,
                ),
              ),
            ),
            Positioned(
              right: foregroundRight,
              bottom: wide ? 0 : 4,
              child: Image.asset(
                spec.imageAsset,
                width: foregroundWidth,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CtaCardSpec {
  const _CtaCardSpec({
    required this.title,
    required this.description,
    required this.imageAsset,
  });

  final String title;
  final String description;
  final String imageAsset;

  static const pickup = _CtaCardSpec(
    title: 'Pick-up\nSafely',
    description: 'Get the waste collected by a trusted partner.',
    imageAsset: ChatAssets.catPickup,
  );

  static const process = _CtaCardSpec(
    title: 'Process\nwith Care',
    description: 'Learn safe handling steps based on the scan result.',
    imageAsset: ChatAssets.catProcess,
  );

  static const dispose = _CtaCardSpec(
    title: 'Throw It the\nRight Way',
    description:
        'Follow the correct disposal guide to seal, separate, and throw away the waste safely',
    imageAsset: ChatAssets.catThrow,
  );
}
