import 'package:flutter/material.dart';
import '../models/listing_model.dart';

class CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onPressed;

  const CategoryChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onPressed(),
      avatar: label != 'All'
          ? Icon(
              ListingCategory.getCategoryIcon(label),
              size: 18,
            )
          : null,
      showCheckmark: isSelected,
      side: label == 'All'
          ? const BorderSide(color: Color(0xFF005A9C), width: 1)
          : null,
    );
  }
}
