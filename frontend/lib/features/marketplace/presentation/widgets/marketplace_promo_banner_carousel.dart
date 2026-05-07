import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../core/constants/asset_constants.dart';

class MarketplacePromoBannerCarousel extends StatefulWidget {
  const MarketplacePromoBannerCarousel({super.key});

  @override
  State<MarketplacePromoBannerCarousel> createState() =>
      _MarketplacePromoBannerCarouselState();
}

class _MarketplacePromoBannerCarouselState
    extends State<MarketplacePromoBannerCarousel> {
  static const _pageCount = 3;
  late final PageController _pageController;
  int _activePage = 1;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _activePage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int index) {
    if (!_pageController.hasClients) return;
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: SizedBox(
        height: 178,
        child: Stack(
          children: [
            Container(
              height: 164,
              decoration: BoxDecoration(
                color: const Color(0xFF9A4600),
                borderRadius: BorderRadius.circular(15),
              ),
              clipBehavior: Clip.hardEdge,
              child: Stack(
                children: [
                  PageView.builder(
                    controller: _pageController,
                    itemCount: _pageCount,
                    onPageChanged: (value) =>
                        setState(() => _activePage = value),
                    itemBuilder: (context, index) =>
                        const _MarketplacePromoBanner(),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: _BannerNavButton(
                        icon: Icons.chevron_left_rounded,
                        onTap: () => _goToPage(
                          (_activePage - 1).clamp(0, _pageCount - 1),
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: _BannerNavButton(
                        icon: Icons.chevron_right_rounded,
                        onTap: () => _goToPage(
                          (_activePage + 1).clamp(0, _pageCount - 1),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_pageCount, (i) {
                  final active = i == _activePage;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOutCubic,
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: active
                          ? AnaboolColors.brownDark
                          : const Color(0xFFE8CDB9),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MarketplacePromoBanner extends StatelessWidget {
  const _MarketplacePromoBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 164,
      decoration: BoxDecoration(
        color: const Color(0xFF9A4600),
        borderRadius: BorderRadius.circular(15),
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          Positioned(
            left: -70,
            top: 14,
            child: Container(
              width: 190,
              height: 190,
              decoration: BoxDecoration(
                color: const Color(0xFF8B3C05).withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(120),
              ),
            ),
          ),
          Positioned(
            right: -90,
            bottom: -90,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                color: const Color(0xFF5F2800).withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(140),
              ),
            ),
          ),
          Positioned(
            left: -40,
            bottom: -120,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                color: const Color(0xFF6E2E00).withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(140),
              ),
            ),
          ),
          Positioned(
            right: -18,
            bottom: -6,
            child: Image.asset(
              HomeAssets.marketCat,
              width: 164,
              height: 164,
              fit: BoxFit.contain,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(13, 10, 13, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  width: 228,
                  child: Text(
                    'Dapatkan perlengkapan kebersihan yang terpercaya untuk kucing Anda',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      height: 1.26,
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF2ED),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x40000000),
                        blurRadius: 4,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Text(
                    'Beli Sekarang',
                    style: TextStyle(
                      color: AnaboolColors.brownDark,
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                    ),
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

class _BannerNavButton extends StatelessWidget {
  const _BannerNavButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkResponse(
        onTap: onTap,
        radius: 22,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.20),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}
