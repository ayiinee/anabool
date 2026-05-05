import 'package:flutter/material.dart';

import '../../../../app/theme.dart';

class EducationCategoryChip extends StatelessWidget {
  const EducationCategoryChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      showCheckmark: false,
      visualDensity: VisualDensity.compact,
      labelStyle: TextStyle(
        color: selected ? Colors.white : AnaboolColors.brownDark,
        fontSize: 12,
        fontWeight: FontWeight.w900,
      ),
      selectedColor: AnaboolColors.brown,
      backgroundColor: Colors.white,
      side: BorderSide(
        color: selected ? AnaboolColors.brown : AnaboolColors.border,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}
