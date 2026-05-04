import 'package:flutter/material.dart';

import '../../../../app/theme.dart';

class AuthFooterLink extends StatelessWidget {
  const AuthFooterLink({
    super.key,
    required this.prefix,
    required this.action,
    required this.onTap,
  });

  final String prefix;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 4,
      children: [
        Text(
          prefix,
          style: const TextStyle(
            color: AnaboolColors.brownSoft,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
        InkWell(
          onTap: onTap,
          child: Text(
            action,
            style: const TextStyle(
              color: AnaboolColors.brown,
              fontSize: 12,
              fontWeight: FontWeight.w900,
              decoration: TextDecoration.underline,
              decorationColor: AnaboolColors.brown,
            ),
          ),
        ),
      ],
    );
  }
}
