import 'package:flutter/material.dart';

import '../../../../app/theme.dart';

class ScanSuccessDialog extends StatelessWidget {
  const ScanSuccessDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 44),
      backgroundColor: const Color(0xFFE9F8EE),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _SuccessIcon(),
            SizedBox(height: 14),
            Text(
              'Scan completed\nsuccessfully!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF087335),
                fontSize: 21,
                fontWeight: FontWeight.w900,
                height: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuccessIcon extends StatelessWidget {
  const _SuccessIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AnaboolColors.green, width: 1.4),
      ),
      child: const Icon(
        Icons.check_rounded,
        color: AnaboolColors.green,
        size: 34,
      ),
    );
  }
}
