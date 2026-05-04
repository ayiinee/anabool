import 'package:flutter/material.dart';

import '../../../../app/theme.dart';

class AuthSocialButton extends StatelessWidget {
  const AuthSocialButton({
    super.key,
    required this.asset,
    required this.label,
    required this.onPressed,
  });

  final String asset;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: const Color(0xFFFFFAF7),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: AnaboolColors.border),
        ),
        elevation: 0,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onPressed,
          child: SizedBox(
            width: 54,
            height: 46,
            child: Center(
              child: Image.asset(
                asset,
                width: 24,
                height: 24,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
