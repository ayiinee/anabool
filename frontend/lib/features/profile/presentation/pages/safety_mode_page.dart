import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../controllers/profile_controller.dart';
import '../widgets/safety_mode_card.dart';

class SafetyModePage extends StatefulWidget {
  const SafetyModePage({super.key});

  @override
  State<SafetyModePage> createState() => _SafetyModePageState();
}

class _SafetyModePageState extends State<SafetyModePage> {
  late final ProfileController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ProfileController.create()..load();
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
          'Safety Mode',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: SafeArea(
        top: false,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final profile = _controller.profile;
            if (_controller.isLoading && profile == null) {
              return const Center(
                child: CircularProgressIndicator(color: AnaboolColors.brown),
              );
            }

            if (profile == null) {
              return const Center(child: Text('Profil belum tersedia.'));
            }

            return ListView(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
              children: [
                SafetyModeCard(
                  enabled: profile.safetyModeEnabled,
                  onChanged: _controller.setSafetyMode,
                ),
                const SizedBox(height: 14),
                const _SafetyInfoTile(
                  icon: Icons.clean_hands_rounded,
                  title: 'Pengingat Sanitasi',
                  body:
                      'Notifikasi kebersihan muncul setelah aktivitas anabul dicatat.',
                ),
                const SizedBox(height: 9),
                const _SafetyInfoTile(
                  icon: Icons.warning_amber_rounded,
                  title: 'Deteksi Risiko',
                  body:
                      'Pola defecate dan urinate tidak biasa akan diberi tanda.',
                ),
                const SizedBox(height: 9),
                const _SafetyInfoTile(
                  icon: Icons.medical_information_outlined,
                  title: 'Catatan Kesehatan',
                  body:
                      'Saran tidak menggantikan konsultasi langsung dengan dokter hewan.',
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SafetyInfoTile extends StatelessWidget {
  const _SafetyInfoTile({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFF0C7B4)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AnaboolColors.brown, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AnaboolColors.ink,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: const TextStyle(
                    color: AnaboolColors.muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
