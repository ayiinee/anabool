import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../domain/entities/marketplace_category.dart';

class MarketplaceCategoryFilter extends StatelessWidget {
  const MarketplaceCategoryFilter({
    super.key,
    required this.categories,
    required this.selectedCategorySlug,
    required this.onCategorySelected,
  });

  final List<MarketplaceCategory> categories;
  final String selectedCategorySlug;
  final ValueChanged<String> onCategorySelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Row(
        children: categories.map((category) {
          final isSelected = selectedCategorySlug == category.slug;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () => onCategorySelected(category.slug),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color:
                      isSelected ? const Color(0xFF9A4600) : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF9A4600)
                        : const Color(0xFFE0C0AF),
                  ),
                ),
                child: Text(
                  category.name,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AnaboolColors.brownDark,
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
