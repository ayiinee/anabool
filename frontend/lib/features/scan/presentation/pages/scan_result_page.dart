import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../core/constants/route_constants.dart';
import '../../domain/entities/scan_session.dart';
import '../widgets/scan_result_summary.dart';

class ScanResultPage extends StatelessWidget {
  const ScanResultPage({
    required this.session,
    super.key,
  });

  final ScanSession session;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AnaboolColors.canvas,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
                child: Row(
                  children: [
                    Material(
                      color: AnaboolColors.peach,
                      shape: const CircleBorder(),
                      child: InkResponse(
                        customBorder: const CircleBorder(),
                        onTap: () =>
                            Navigator.of(context).pushNamedAndRemoveUntil(
                          RouteConstants.home,
                          (route) => false,
                        ),
                        child: const SizedBox(
                          width: 38,
                          height: 38,
                          child: Icon(
                            Icons.close_rounded,
                            color: AnaboolColors.brownDark,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        'Scan result',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
              sliver: SliverToBoxAdapter(
                child: ScanResultSummary(session: session),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(18, 8, 18, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: session.id.isEmpty
                    ? null
                    : () => Navigator.of(context).pushNamed(
                          RouteConstants.chat,
                          arguments: session,
                        ),
                icon: const Icon(Icons.chat_bubble_rounded),
                label: const Text('Tanya Ana dari hasil scan'),
                style: FilledButton.styleFrom(
                  backgroundColor: AnaboolColors.brown,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
                  RouteConstants.scanCamera,
                  ModalRoute.withName(RouteConstants.home),
                ),
                icon: const Icon(Icons.camera_alt_rounded),
                label: const Text('Scan another photo'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AnaboolColors.brown,
                  side: const BorderSide(color: AnaboolColors.brown),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
