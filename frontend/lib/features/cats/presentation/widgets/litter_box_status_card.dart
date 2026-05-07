import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../domain/entities/cat_profile.dart';

class LitterBoxStatusCard extends StatelessWidget {
  const LitterBoxStatusCard({
    super.key,
    required this.profile,
  });

  final CatProfile profile;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFF0C7B4)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.inventory_2_outlined,
                color: AnaboolColors.brown,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Kotak Pasir ${profile.cat.name}',
                  style: const TextStyle(
                    color: AnaboolColors.ink,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              _StatusBadge(status: profile.status.cleanlinessStatus),
            ],
          ),
          const SizedBox(height: 12),
          _InfoLine(
            icon: Icons.place_outlined,
            label:
                '${profile.litterBox.locationLabel} • ${profile.litterBox.boxCount} box',
          ),
          const SizedBox(height: 8),
          _InfoLine(
            icon: Icons.category_outlined,
            label:
                '${profile.litterBox.boxType} • ${profile.litterBox.litterType}',
          ),
          const SizedBox(height: 8),
          _InfoLine(
            icon: Icons.cleaning_services_outlined,
            label:
                '${profile.litterBox.cleaningFrequency}, terakhir ${profile.litterBox.lastCleanedLabel.toLowerCase()}',
          ),
          if (profile.status.alertMessage != null) ...[
            const SizedBox(height: 12),
            Text(
              profile.status.alertMessage!,
              style: const TextStyle(
                color: AnaboolColors.red,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final isUrgent = status.toLowerCase().contains('perlu');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: isUrgent ? const Color(0xFFFFE3E9) : const Color(0xFFEAF7EE),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: isUrgent ? AnaboolColors.red : AnaboolColors.green,
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AnaboolColors.brownSoft, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: AnaboolColors.brownDark,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              height: 1.25,
            ),
          ),
        ),
      ],
    );
  }
}
