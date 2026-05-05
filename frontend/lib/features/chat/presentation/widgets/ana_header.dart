import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../core/constants/asset_constants.dart';

class AnaHeader extends StatelessWidget {
  const AnaHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      decoration: const BoxDecoration(
        color: AnaboolColors.brown,
        borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 4),
          IconButton(
            tooltip: 'Kembali',
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back_rounded),
            color: Colors.white,
            iconSize: 28,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 52, height: 56),
          ),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.asset(
              ChatAssets.anaProfile,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Ana',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const Spacer(),
          IconButton(
            tooltip: 'Opsi chat',
            onPressed: () {},
            icon: const Icon(Icons.more_vert_rounded),
            color: Colors.white,
            iconSize: 28,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 52, height: 56),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}
