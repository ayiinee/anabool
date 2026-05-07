import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../shared/widgets/app_bottom_navigation.dart';
import '../../../home/presentation/widgets/design_image.dart';
import '../../domain/entities/user_profile.dart';
import '../controllers/profile_controller.dart';
import '../controllers/profile_session.dart';
import '../widgets/address_card.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_menu_item.dart';
import '../widgets/safety_mode_card.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final ProfileController _controller;

  @override
  void initState() {
    super.initState();
    _controller = profileSessionController..load();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _openEditProfile() async {
    final updated = await Navigator.of(context).pushNamed(
      RouteConstants.editProfile,
    );

    if (!mounted || updated != true) {
      return;
    }

    await _controller.load(force: true);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                if (_controller.isLoading && _controller.profile == null) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AnaboolColors.brown,
                    ),
                  );
                }

                final profile = _controller.profile;
                if (profile == null) {
                  return const _ProfileErrorState();
                }

                return SingleChildScrollView(
                  padding: EdgeInsets.only(bottom: 122 + bottomInset),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ProfileHeader(
                        profile: profile,
                        onEditProfile: _openEditProfile,
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Expanded(
                                  child: Text(
                                    'Consultation',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                                TextButton.icon(
                                  onPressed: () {},
                                  style: TextButton.styleFrom(
                                    foregroundColor: AnaboolColors.brownDark,
                                    padding: EdgeInsets.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    minimumSize: Size.zero,
                                  ),
                                  icon: const Icon(Icons.add_rounded, size: 13),
                                  label: const Text(
                                    'Tambah Hewan',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 7),
                            _PetGrid(pets: profile.pets),
                            const SizedBox(height: 18),
                            SafetyModeCard(
                              enabled: profile.safetyModeEnabled,
                              compact: true,
                              onChanged: _controller.setSafetyMode,
                            ),
                            const SizedBox(height: 10),
                            if (profile.primaryAddress != null) ...[
                              AddressCard(address: profile.primaryAddress!),
                              const SizedBox(height: 10),
                            ],
                            ProfileMenuItem(
                              icon: Icons.person_outline_rounded,
                              title: 'Edit Profil',
                              subtitle: 'Nama, email, telepon, dan lokasi',
                              onTap: _openEditProfile,
                            ),
                            const SizedBox(height: 9),
                            ProfileMenuItem(
                              icon: Icons.health_and_safety_outlined,
                              title: 'Safety Mode',
                              subtitle: 'Kelola peringatan kesehatan anabul',
                              onTap: () => Navigator.of(context).pushNamed(
                                RouteConstants.safetyMode,
                              ),
                            ),
                            const SizedBox(height: 9),
                            ProfileMenuItem(
                              icon: Icons.location_on_outlined,
                              title: 'Alamat',
                              subtitle: 'Alamat pickup dan pengiriman',
                              onTap: () => Navigator.of(context).pushNamed(
                                RouteConstants.address,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const Align(
              alignment: Alignment.bottomCenter,
              child: AppBottomNavigation(
                activeDestination: AppBottomNavigationDestination.profile,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PetGrid extends StatelessWidget {
  const _PetGrid({required this.pets});

  final List<PetProfile> pets;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 18.0;
        final width = ((constraints.maxWidth - spacing) / 2).clamp(0.0, 168.0);

        return Wrap(
          spacing: spacing,
          runSpacing: 12,
          children: [
            for (final pet in pets)
              SizedBox(
                width: width,
                child: _PetCard(pet: pet),
              ),
          ],
        );
      },
    );
  }
}

class _PetCard extends StatelessWidget {
  const _PetCard({required this.pet});

  final PetProfile pet;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 145,
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFF0C7B4)),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x21000000),
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -7,
            top: -5,
            child: IconButton(
              tooltip: 'Opsi ${pet.name}',
              onPressed: () {},
              visualDensity: VisualDensity.compact,
              icon: const Icon(
                Icons.more_vert_rounded,
                color: AnaboolColors.brown,
                size: 20,
              ),
            ),
          ),
          Column(
            children: [
              Container(
                width: 76,
                height: 76,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: AnaboolColors.brown, width: 3),
                ),
                child: ClipOval(
                  child: DesignImage(
                    asset: pet.imageAsset,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                pet.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: _PetActivityPill(
                      label: 'Defecate',
                      value: pet.defecateCount,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _PetActivityPill(
                      label: 'Urinate',
                      value: pet.urinateCount,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PetActivityPill extends StatelessWidget {
  const _PetActivityPill({
    required this.label,
    required this.value,
  });

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 31,
      decoration: BoxDecoration(
        color: AnaboolColors.brown,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 7.5,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileErrorState extends StatelessWidget {
  const _ProfileErrorState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Profil belum tersedia.',
        style: TextStyle(
          color: AnaboolColors.brownDark,
          fontSize: 13,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
