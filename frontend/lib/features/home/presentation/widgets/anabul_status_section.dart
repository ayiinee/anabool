import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../core/constants/asset_constants.dart';
import 'design_image.dart';
import 'home_components.dart';

class AnabulStatusSection extends StatelessWidget {
  const AnabulStatusSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(
        HomeMetrics.horizontalPadding,
        18,
        HomeMetrics.horizontalPadding,
        22,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HomeSectionTitle('Status Anabul'),
          SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _CatStatusCard(
                  name: 'Gamora',
                  image: HomeAssets.gamoraCat,
                  buangAirBesar: 2,
                  buangAirKecil: 4,
                ),
              ),
              SizedBox(width: 18),
              Expanded(
                child: _CatStatusCard(
                  name: 'Charlotte',
                  image: HomeAssets.charlotteCat,
                  buangAirBesar: 2,
                  buangAirKecil: 4,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CatStatusCard extends StatelessWidget {
  const _CatStatusCard({
    required this.name,
    required this.image,
    required this.buangAirBesar,
    required this.buangAirKecil,
  });

  final String name;
  final String image;
  final int buangAirBesar;
  final int buangAirKecil;

  @override
  Widget build(BuildContext context) {
    return HomeSurface(
      height: 184,
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
      shadows: HomeShadows.raisedCard,
      child: Stack(
        children: [
          Positioned(
            top: -7,
            right: -10,
            child: IconButton(
              tooltip: 'Opsi $name',
              onPressed: () {},
              color: AnaboolColors.brown,
              iconSize: 24,
              icon: const Icon(Icons.more_vert_rounded),
            ),
          ),
          Column(
            children: [
              Container(
                width: 76,
                height: 76,
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  color: AnaboolColors.brown,
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child: DesignImage(asset: image, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _ActivityCount(
                      label: 'BAB',
                      value: buangAirBesar,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _ActivityCount(
                      label: 'BAK',
                      value: buangAirKecil,
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

class _ActivityCount extends StatelessWidget {
  const _ActivityCount({
    required this.label,
    required this.value,
  });

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: AnaboolColors.brown,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 4,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '$value kali',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}
