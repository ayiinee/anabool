import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../domain/entities/scan_session.dart';

class ScanResultSummary extends StatelessWidget {
  const ScanResultSummary({
    required this.session,
    super.key,
  });

  final ScanSession session;

  @override
  Widget build(BuildContext context) {
    final quality = session.detection.photoQuality ?? 'Not provided';
    final signs = session.detection.visualSigns;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SummaryCard(
          children: [
            Text(
              session.wasteClass.displayName,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Visual indicator result only. This scan does not diagnose disease or detect microscopic parasites.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AnaboolColors.ink.withValues(alpha: 0.64),
                  ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _MetricTile(
                    label: 'Confidence',
                    value: '${session.confidencePercent}%',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricTile(
                    label: 'Photo quality',
                    value: _titleCase(quality),
                  ),
                ),
              ],
            ),
            if (session.wasteClass.riskLevel != null) ...[
              const SizedBox(height: 12),
              _MetricTile(
                label: 'Backend risk label',
                value: _titleCase(session.wasteClass.riskLevel!),
              ),
            ],
          ],
        ),
        const SizedBox(height: 18),
        _SummaryCard(
          children: [
            Text(
              'Detected visual signs',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            if (signs.isEmpty)
              Text(
                'No visual signs returned by backend yet.',
                style: Theme.of(context).textTheme.bodyMedium,
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: signs
                    .map(
                      (sign) => Chip(
                        label: Text(_titleCase(sign)),
                        backgroundColor: AnaboolColors.peach,
                        side: BorderSide.none,
                        labelStyle: const TextStyle(
                          color: AnaboolColors.brownDark,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    )
                    .toList(growable: false),
              ),
          ],
        ),
        const SizedBox(height: 18),
        _SummaryCard(
          children: [
            Row(
              children: [
                const Icon(Icons.data_object_rounded,
                    color: AnaboolColors.brown),
                const SizedBox(width: 8),
                Text(
                  'Raw backend payload',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF171717),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                const JsonEncoder.withIndent('  ').convert(session.rawPayload),
                style: const TextStyle(
                  color: Color(0xFFEDEDED),
                  fontSize: 12,
                  height: 1.35,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  static String _titleCase(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return '-';
    }

    return trimmed
        .split(RegExp(r'[_\-\s]+'))
        .where((part) => part.isNotEmpty)
        .map((part) => part[0].toUpperCase() + part.substring(1))
        .join(' ');
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: AnaboolColors.shadow,
            blurRadius: 14,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AnaboolColors.canvas,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              maxLines: 1,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ],
      ),
    );
  }
}
