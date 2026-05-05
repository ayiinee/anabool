import 'package:flutter/material.dart';

import '../../../../app/theme.dart';

class ScanResultBubble extends StatelessWidget {
  const ScanResultBubble({
    super.key,
    required this.content,
  });

  final String content;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFFFFF7F1),
          border: Border.all(color: AnaboolColors.border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.document_scanner_rounded,
                color: AnaboolColors.brown,
                size: 18,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  content,
                  style: const TextStyle(
                    color: AnaboolColors.brownDark,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
