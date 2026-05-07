import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../core/constants/route_constants.dart';
import '../controllers/cat_controller.dart';
import '../widgets/activity_timeline.dart';
import '../widgets/cat_profile_card.dart';
import '../widgets/litter_box_status_card.dart';

class CatDetailPage extends StatefulWidget {
  const CatDetailPage({
    super.key,
    required this.catId,
  });

  final String catId;

  @override
  State<CatDetailPage> createState() => _CatDetailPageState();
}

class _CatDetailPageState extends State<CatDetailPage> {
  late final CatController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CatController.create()..load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AnaboolColors.canvas,
      appBar: AppBar(
        backgroundColor: AnaboolColors.canvas,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Detail Kucing',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: SafeArea(
        top: false,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            if (_controller.isLoading && _controller.cats.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(color: AnaboolColors.brown),
              );
            }

            final profile = _controller.findCat(widget.catId);
            if (profile == null) {
              return const Center(
                  child: Text('Profil kucing tidak ditemukan.'));
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 12, 22, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CatProfileCard(profile: profile),
                  const SizedBox(height: 12),
                  LitterBoxStatusCard(profile: profile),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: FilledButton.icon(
                      onPressed: () async {
                        await Navigator.of(context).pushNamed(
                          RouteConstants.recordCatActivity,
                          arguments: profile.cat.id,
                        );
                        await _controller.load();
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: AnaboolColors.brown,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(Icons.edit_note_rounded),
                      label: const Text(
                        'Catat Aktivitas',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Aktivitas Terakhir',
                    style: TextStyle(
                      color: AnaboolColors.ink,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ActivityTimeline(activities: profile.activities),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
