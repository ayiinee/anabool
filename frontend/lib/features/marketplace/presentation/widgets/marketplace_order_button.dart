import 'package:flutter/material.dart';

class MarketplaceOrderButton extends StatelessWidget {
  const MarketplaceOrderButton({
    super.key,
    required this.isOrdering,
    required this.onPressed,
  });

  final bool isOrdering;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 37,
      child: ElevatedButton(
        onPressed: isOrdering ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF9A4600),
          foregroundColor: Colors.white,
          disabledBackgroundColor:
              const Color(0xFF9A4600).withValues(alpha: 0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
        ),
        child: isOrdering
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Text(
                'Pesan sekarang',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
      ),
    );
  }
}
