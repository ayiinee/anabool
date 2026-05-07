import 'package:flutter/material.dart';

import '../../../../app/theme.dart';

class MarketplaceSearchHeader extends StatelessWidget {
  const MarketplaceSearchHeader({
    super.key,
    required this.onSearchChanged,
    required this.onFilterPressed,
  });

  final ValueChanged<String> onSearchChanged;
  final VoidCallback onFilterPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 15, 20, 10),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 36,
              child: TextField(
                onChanged: onSearchChanged,
                textInputAction: TextInputAction.search,
                style: const TextStyle(
                  color: AnaboolColors.brownDark,
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                ),
                decoration: InputDecoration(
                  hintText: 'Vitamin kucing yang anda dibutuhkan',
                  hintStyle: const TextStyle(
                    fontSize: 11,
                    color: Color(0x405C2700),
                    fontWeight: FontWeight.w400,
                  ),
                  suffixIcon: const Icon(
                    Icons.search_rounded,
                    color: Color(0x407A3400),
                    size: 21,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 0,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(21),
                    borderSide: const BorderSide(
                      color: Color(0xFFE0C0AF),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(21),
                    borderSide: const BorderSide(
                      color: Color(0xFFE0C0AF),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(21),
                    borderSide: const BorderSide(
                      color: AnaboolColors.brown,
                      width: 1.4,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 44,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: const Color(0xFFE0C0AF)),
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(
                Icons.tune_rounded,
                color: Color(0xFF9A4600),
                size: 22,
              ),
              onPressed: onFilterPressed,
            ),
          ),
        ],
      ),
    );
  }
}
