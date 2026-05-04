import 'package:flutter/material.dart';

import '../../../../app/theme.dart';

class AuthPrimaryButton extends StatelessWidget {
  const AuthPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AnaboolColors.brown,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AnaboolColors.border,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(7),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w900,
          ),
          elevation: 0,
        ),
        child: Text(label),
      ),
    );
  }
}
