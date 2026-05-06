import 'dart:async';
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../core/constants/asset_constants.dart';
import 'design_image.dart';
import 'home_components.dart';

class HeroHeader extends StatelessWidget {
  const HeroHeader({super.key});

  static const _posterAspectRatio = 1138 / 512;
  static const _headerBorderRadius = BorderRadius.only(
    bottomLeft: Radius.circular(18),
    bottomRight: Radius.circular(18),
  );

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.sizeOf(context).width;
        final availableWidth =
            constraints.hasBoundedWidth ? constraints.maxWidth : screenWidth;
        final posterWidth =
            availableWidth - (HomeMetrics.horizontalPadding * 2);
        final posterHeight =
            (posterWidth / _posterAspectRatio).clamp(142.0, 174.0).toDouble();
        const headerHeight = 266.0;
        final overlap = posterHeight * 0.42;

        return SizedBox(
          height: headerHeight + posterHeight - overlap,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              const SizedBox(
                height: headerHeight,
                width: double.infinity,
                child: ClipRRect(
                  borderRadius: _headerBorderRadius,
                  child: Stack(
                    children: [
                      Positioned.fill(child: _HeroBackground()),
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          HomeMetrics.horizontalPadding,
                          20,
                          HomeMetrics.horizontalPadding,
                          0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: _HeroGreeting(),
                                ),
                                SizedBox(width: 12),
                                _HeaderActions(),
                              ],
                            ),
                            SizedBox(height: 10),
                            _UserPill(),
                            SizedBox(height: 14),
                            _MeowPointsPill(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: HomeMetrics.horizontalPadding,
                right: HomeMetrics.horizontalPadding,
                top: headerHeight - overlap,
                child: _PosterCard(height: posterHeight),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HeroBackground extends StatelessWidget {
  const _HeroBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFFFA258),
                Color(0xFFFFBA80),
                Color(0xFFFFD6B8),
              ],
              stops: [0, 0.58, 1],
            ),
          ),
        ),
        Positioned.fill(
          child: Transform.translate(
            offset: const Offset(0, 32),
            child: const Opacity(
              opacity: 1,
              child: ColorFiltered(
                colorFilter: ColorFilter.mode(
                  Color(0xFF8E430F),
                  BlendMode.srcIn,
                ),
                child: DesignImage(
                  asset: HomeAssets.heroBackground,
                  fit: BoxFit.cover,
                  alignment: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
        ),
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x00FFFFFF),
                  Color(0x17FFFFFF),
                  Color(0x45FFF2E8),
                ],
                stops: [0, 0.62, 1],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HeroGreeting extends StatelessWidget {
  const _HeroGreeting();

  @override
  Widget build(BuildContext context) {
    final userName = _currentUserName();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Halo, $userName',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _wibGreeting(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _HeaderActions extends StatelessWidget {
  const _HeaderActions();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _HeaderIconButton(
          icon: Icons.notifications_none_rounded,
          tooltip: 'Notifikasi',
        ),
        SizedBox(width: 8),
        _HeaderIconButton(
          icon: Icons.settings_outlined,
          tooltip: 'Pengaturan',
        ),
      ],
    );
  }
}

class _HelpdeskButton extends StatelessWidget {
  const _HelpdeskButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: TextButton.icon(
        onPressed: () {},
        style: HomeButtonStyles.filled(
          backgroundColor: AnaboolColors.brown,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.only(left: 11, right: 13),
          radius: HomeMetrics.tileRadius,
        ),
        icon: const Icon(
          Icons.support_agent_rounded,
          size: 21,
        ),
        label: const Text(
          'Helpdesk',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.tooltip,
  });

  final IconData icon;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 44,
      child: IconButton(
        tooltip: tooltip,
        onPressed: () {},
        style: HomeButtonStyles.headerIcon(),
        icon: Icon(icon, size: 24),
      ),
    );
  }
}

class _UserPill extends StatelessWidget {
  const _UserPill();

  @override
  Widget build(BuildContext context) {
    final userName = _currentUserName();

    return Container(
      height: 30,
      padding: const EdgeInsets.fromLTRB(4, 3, 12, 3),
      decoration: BoxDecoration(
        color: AnaboolColors.brown,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const ClipOval(
            child: DesignImage(
              asset: HomeAssets.profilePhoto,
              width: 24,
              height: 24,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              userName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _currentUserName() {
  final user = FirebaseAuth.instance.currentUser;
  final displayName = user?.displayName?.trim();
  if (displayName != null && displayName.isNotEmpty) {
    return displayName;
  }

  final email = user?.email?.trim();
  if (email != null && email.isNotEmpty) {
    return email.split('@').first;
  }

  return 'Pengguna';
}

String _wibGreeting() {
  final wibTime = DateTime.now().toUtc().add(const Duration(hours: 7));
  final hour = wibTime.hour;

  if (hour >= 4 && hour < 11) {
    return 'Selamat pagi';
  }
  if (hour >= 11 && hour < 15) {
    return 'Selamat siang';
  }
  if (hour >= 15 && hour < 18) {
    return 'Selamat sore';
  }
  return 'Selamat malam';
}

class _MeowPointsPill extends StatelessWidget {
  const _MeowPointsPill();

  @override
  Widget build(BuildContext context) {
    const radius = BorderRadius.all(Radius.circular(15));

    return DecoratedBox(
      decoration: const BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: Color(0x187A3400),
            blurRadius: 16,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: const SizedBox(
            height: 44,
            width: double.infinity,
            child: Stack(
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Color(0x36FFF8F0),
                      border: Border.fromBorderSide(
                        BorderSide(color: Color(0x5CFFFFFF), width: 1),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  top: 7,
                  bottom: 7,
                  child: DecoratedBox(
                    decoration: BoxDecoration(color: Color(0x8CFFFFFF)),
                    child: SizedBox(width: 1.4),
                  ),
                ),
                Positioned(
                  right: 0,
                  top: 8,
                  bottom: 8,
                  child: DecoratedBox(
                    decoration: BoxDecoration(color: Color(0x33A64700)),
                    child: SizedBox(width: 1),
                  ),
                ),
                Positioned(
                  right: 0,
                  left: 0,
                  bottom: 0,
                  child: DecoratedBox(
                    decoration: BoxDecoration(color: Color(0x24A64700)),
                    child: SizedBox(height: 1),
                  ),
                ),
                Positioned.fill(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14),
                    child: Row(
                      children: [
                        Text(
                          'MeowPoints',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Spacer(),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(
                                radius: 9,
                                backgroundColor: AnaboolColors.brown,
                                child: Icon(
                                  Icons.star_rounded,
                                  color: Colors.white,
                                  size: 13,
                                ),
                              ),
                              SizedBox(width: 6),
                              Text(
                                '194,589 XP',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PosterCard extends StatefulWidget {
  const _PosterCard({required this.height});

  final double height;

  @override
  State<_PosterCard> createState() => _PosterCardState();
}

class _PosterCardState extends State<_PosterCard> {
  static const _autoPlayDelay = Duration(seconds: 4);
  static const _posterHorizontalCropScale = 1.055;
  static const _posters = [
    HomeAssets.homePoster,
    HomeAssets.homePoster3,
    HomeAssets.homePoster4,
    HomeAssets.homePoster5,
    HomeAssets.homePoster6,
  ];

  late final PageController _pageController;
  Timer? _autoPlayTimer;
  int _currentPoster = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startAutoPlay();
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoPlay() {
    _autoPlayTimer?.cancel();
    if (_posters.length < 2) {
      return;
    }

    _autoPlayTimer = Timer.periodic(_autoPlayDelay, (_) {
      if (!mounted || !_pageController.hasClients) {
        return;
      }

      final nextPoster = (_currentPoster + 1) % _posters.length;
      _pageController.animateToPage(
        nextPoster,
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
      );
    });
  }

  void _pauseAutoPlay() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = null;
  }

  void _moveToPoster(int index) {
    if (index == _currentPoster || !_pageController.hasClients) {
      return;
    }

    _pauseAutoPlay();
    _pageController
        .animateToPage(
      index,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    )
        .whenComplete(() {
      if (mounted) {
        _startAutoPlay();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(HomeMetrics.cardRadius),
            boxShadow: const [
              BoxShadow(
                color: Color(0x26000000),
                blurRadius: 12,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(HomeMetrics.cardRadius),
            child: SizedBox(
              width: double.infinity,
              height: widget.height,
              child: NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (notification is ScrollStartNotification &&
                      notification.dragDetails != null) {
                    _pauseAutoPlay();
                  } else if (notification is ScrollEndNotification) {
                    _startAutoPlay();
                  }

                  return false;
                },
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _posters.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPoster = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.diagonal3Values(
                        _posterHorizontalCropScale,
                        1,
                        1,
                      ),
                      child: DesignImage(
                        asset: _posters[index],
                        width: double.infinity,
                        height: widget.height,
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 10,
          child: _PosterIndicator(
            count: _posters.length,
            currentIndex: _currentPoster,
            onSelected: _moveToPoster,
          ),
        ),
      ],
    );
  }
}

class _PosterIndicator extends StatelessWidget {
  const _PosterIndicator({
    required this.count,
    required this.currentIndex,
    required this.onSelected,
  });

  final int count;
  final int currentIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.94),
          borderRadius: BorderRadius.circular(999),
          boxShadow: const [
            BoxShadow(
              color: Color(0x26000000),
              blurRadius: 18,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              count,
              (index) => _PosterDot(
                active: index == currentIndex,
                onTap: () => onSelected(index),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PosterDot extends StatelessWidget {
  const _PosterDot({
    required this.active,
    required this.onTap,
  });

  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          width: 6,
          height: 7,
          decoration: BoxDecoration(
            color: active ? AnaboolColors.brown : Colors.white,
            shape: BoxShape.circle,
            boxShadow: const [
              BoxShadow(
                color: Color(0x26000000),
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
