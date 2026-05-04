import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../core/constants/asset_constants.dart';

class ScanQrisButton extends StatelessWidget {
  const ScanQrisButton({
    required this.onPressed,
    this.isLoading = false,
    super.key,
  });

  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Ambil foto scan',
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkResponse(
          customBorder: const CircleBorder(),
          onTap: isLoading ? null : onPressed,
          child: Container(
            width: 78,
            height: 78,
            decoration: BoxDecoration(
              color: AnaboolColors.brown,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x55000000),
                  blurRadius: 11,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      width: 30,
                      height: 30,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: Colors.white,
                      ),
                    )
                  : Image.asset(
                      HomeAssets.scanIcon,
                      width: 52,
                      height: 52,
                      fit: BoxFit.contain,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
