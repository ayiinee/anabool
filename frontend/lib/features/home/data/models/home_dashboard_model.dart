import 'package:flutter/material.dart';

class UserSummary {
  const UserSummary({
    required this.name,
    required this.meowPoints,
    required this.initials,
  });

  final String name;
  final String meowPoints;
  final String initials;
}

class CatStatus {
  const CatStatus({
    required this.name,
    required this.avatarColor,
    required this.peeCount,
    required this.poopCount,
    this.missedActivity,
  });

  final String name;
  final Color avatarColor;
  final int peeCount;
  final int poopCount;
  final String? missedActivity;
}

class ChecklistItem {
  const ChecklistItem({
    required this.title,
    required this.subtitle,
    this.isComplete = false,
  });

  final String title;
  final String subtitle;
  final bool isComplete;
}

class QuickAction {
  const QuickAction({
    required this.label,
    required this.icon,
  });

  final String label;
  final IconData icon;
}

class ImpactMetric {
  const ImpactMetric({
    required this.value,
    required this.label,
    required this.icon,
  });

  final String value;
  final String label;
  final IconData icon;
}
