import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../core/constants/asset_constants.dart';
import 'design_image.dart';

class HeroHeader extends StatelessWidget {
  const HeroHeader({super.key});

  static const _horizontalPadding = 22.0;
  static const _posterAspectRatio = 1138 / 512;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.sizeOf(context).width;
        final availableWidth =
            constraints.hasBoundedWidth ? constraints.maxWidth : screenWidth;
        final posterWidth = availableWidth - (_horizontalPadding * 2);
        final posterHeight =
            (posterWidth / _posterAspectRatio).clamp(142.0, 174.0).toDouble();
        const headerHeight = 266.0;
        final overlap = posterHeight * 0.42;

        return SizedBox(
          height: headerHeight + posterHeight - overlap,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: headerHeight,
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(22, 20, 22, 0),
                decoration: const BoxDecoration(
                  color: AnaboolColors.header,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(18),
                    bottomRight: Radius.circular(18),
                  ),
                ),
                child: const Column(
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
              Positioned(
                left: _horizontalPadding,
                right: _horizontalPadding,
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

class _HeroGreeting extends StatelessWidget {
  const _HeroGreeting();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Anabool',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Selamat siang, Alvin',
          style: TextStyle(
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
        _HelpdeskButton(),
        SizedBox(width: 8),
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
        style: TextButton.styleFrom(
          backgroundColor: AnaboolColors.brown,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.only(left: 11, right: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          minimumSize: Size.zero,
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
        style: IconButton.styleFrom(
          backgroundColor: AnaboolColors.brown,
          foregroundColor: Colors.white,
          padding: EdgeInsets.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        icon: Icon(icon, size: 24),
      ),
    );
  }
}

class _UserPill extends StatelessWidget {
  const _UserPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      padding: const EdgeInsets.fromLTRB(4, 3, 12, 3),
      decoration: BoxDecoration(
        color: AnaboolColors.brown,
        borderRadius: BorderRadius.circular(999),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipOval(
            child: DesignImage(
              asset: HomeAssets.profilePhoto,
              width: 24,
              height: 24,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: 6),
          Text(
            'Putu Alvin',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _MeowPointsPill extends StatelessWidget {
  const _MeowPointsPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 13),
      decoration: BoxDecoration(
        color: const Color(0xFFEBA968),
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x17000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: const Row(
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
          CircleAvatar(
            radius: 9,
            backgroundColor: AnaboolColors.brown,
            child: Icon(Icons.star_rounded, color: Colors.white, size: 13),
          ),
          SizedBox(width: 6),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(
                '194,589 XP',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PosterCard extends StatelessWidget {
  const _PosterCard({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color(0x26000000),
                blurRadius: 12,
                offset: Offset(0, 5),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: const DesignImage(
            asset: HomeAssets.homePoster,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        const Positioned(
          left: 10,
          top: 0,
          bottom: 0,
          child: _PosterArrow(icon: Icons.chevron_left_rounded),
        ),
        const Positioned(
          right: 10,
          top: 0,
          bottom: 0,
          child: _PosterArrow(icon: Icons.chevron_right_rounded),
        ),
        const Positioned(
          left: 0,
          right: 0,
          bottom: 10,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _PosterDot(active: true),
              SizedBox(width: 5),
              _PosterDot(),
              SizedBox(width: 5),
              _PosterDot(),
            ],
          ),
        ),
      ],
    );
  }
}

class _PosterArrow extends StatelessWidget {
  const _PosterArrow({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.44),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 26,
        ),
      ),
    );
  }
}

class _PosterDot extends StatelessWidget {
  const _PosterDot({this.active = false});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: active ? 16 : 6,
      height: 6,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: active ? 0.95 : 0.58),
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}
