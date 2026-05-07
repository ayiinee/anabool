import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme.dart';
import '../../domain/entities/cat_activity.dart';

class ActivityTimeline extends StatelessWidget {
  const ActivityTimeline({
    super.key,
    required this.activities,
  });

  final List<CatActivity> activities;

  @override
  Widget build(BuildContext context) {
    if (activities.isEmpty) {
      return const Text(
        'Belum ada aktivitas.',
        style: TextStyle(
          color: AnaboolColors.brownSoft,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      );
    }

    return Column(
      children: [
        for (final activity in activities)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFF1EB),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _iconFor(activity.type),
                    color: AnaboolColors.brown,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity.label,
                        style: const TextStyle(
                          color: AnaboolColors.ink,
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        [
                          DateFormat('d MMM, HH:mm', 'id_ID')
                              .format(activity.recordedAt),
                          if (activity.notes.isNotEmpty) activity.notes,
                        ].join(' • '),
                        style: const TextStyle(
                          color: AnaboolColors.brownSoft,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  static IconData _iconFor(CatActivityType type) {
    switch (type) {
      case CatActivityType.pee:
        return Icons.water_drop_outlined;
      case CatActivityType.poop:
        return Icons.pets_rounded;
      case CatActivityType.clean:
        return Icons.cleaning_services_outlined;
      case CatActivityType.note:
        return Icons.edit_note_rounded;
    }
  }
}
