import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/app/app.dart';
import 'package:frontend/core/constants/asset_constants.dart';

void main() {
  test('home assets are bundled', () async {
    TestWidgetsFlutterBinding.ensureInitialized();

    const assets = [
      HomeAssets.activityCat,
      HomeAssets.charlotteCat,
      HomeAssets.educationCat,
      HomeAssets.gamoraCat,
      HomeAssets.marketCat,
      HomeAssets.pickupCat,
      HomeAssets.posterCat,
      HomeAssets.profilePhoto,
      HomeAssets.homePoster,
      HomeAssets.homePoster3,
      HomeAssets.homePoster4,
      HomeAssets.homePoster5,
      HomeAssets.homePoster6,
      HomeAssets.product1,
      HomeAssets.product2,
      HomeAssets.product3,
      HomeAssets.product4,
      HomeAssets.product5,
      HomeAssets.product6,
      HomeAssets.product7,
      HomeAssets.scanIcon,
    ];

    for (final asset in assets) {
      final data = await rootBundle.load(asset);
      expect(data.lengthInBytes, greaterThan(0), reason: asset);
    }
  });

  test('home poster assets can be decoded as images', () async {
    TestWidgetsFlutterBinding.ensureInitialized();

    const posters = [
      HomeAssets.homePoster,
      HomeAssets.homePoster3,
      HomeAssets.homePoster4,
      HomeAssets.homePoster5,
      HomeAssets.homePoster6,
    ];

    for (final poster in posters) {
      final data = await rootBundle.load(poster);
      final buffer = await ui.ImmutableBuffer.fromUint8List(
        data.buffer.asUint8List(),
      );
      final descriptor = await ui.ImageDescriptor.encoded(buffer);
      final codec = await descriptor.instantiateCodec();
      final frame = await codec.getNextFrame();

      expect(data.lengthInBytes, greaterThan(0), reason: poster);
      expect(frame.image.width, greaterThan(0), reason: poster);
      expect(frame.image.height, greaterThan(0), reason: poster);

      frame.image.dispose();
      codec.dispose();
      descriptor.dispose();
      buffer.dispose();
    }
  });

  testWidgets('home page renders the iPhone 16 Plus reference sections',
      (tester) async {
    tester.view.physicalSize = const Size(430, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const AnaboolApp());
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Anabool'), findsOneWidget);
    expect(find.text('MeowPoints'), findsOneWidget);
    expect(find.text('Pintasan'), findsOneWidget);
    expect(find.text('Aktifitas'), findsOneWidget);
    expect(find.text('Modul'), findsNWidgets(2));
    expect(find.text('Pick-up'), findsOneWidget);
    expect(find.text('Produk'), findsNWidgets(2));
    expect(find.text('Konsultasi Sekarang!'), findsOneWidget);
    expect(
      find.text('Bingung dengan kondisi kotoran atau kotak pasir kucing Anda?'),
      findsOneWidget,
    );
    expect(find.text('Coba Sekarang'), findsOneWidget);
    expect(find.text('Status Anabul'), findsOneWidget);
    expect(find.text('Gamora'), findsOneWidget);
    expect(find.text('Charlotte'), findsOneWidget);
    expect(find.text('Rekomendasi Produk'), findsOneWidget);
    expect(find.text('14%'), findsNWidgets(4));
    expect(find.text('Bisa COD'), findsNWidgets(4));
    expect(find.text('Jakarta Utara'), findsNWidgets(4));
    expect(find.text('Lihat lainnya'), findsOneWidget);

    await tester.ensureVisible(find.text('Lihat lainnya'));
    await tester.tap(find.text('Lihat lainnya'));
    await tester.pumpAndSettle();

    expect(find.text('14%'), findsNWidgets(6));
    expect(find.text('Bisa COD'), findsNWidgets(6));
    expect(find.text('Jakarta Utara'), findsNWidgets(6));
    expect(find.text('Lihat lainnya'), findsNothing);
    expect(find.text('Beli Sekarang'), findsNothing);
    expect(find.text('Follow us on'), findsNothing);
    expect(find.text('Address'), findsNothing);
    expect(find.text('Contact'), findsNothing);
    expect(find.textContaining('Home  |  Education'), findsNothing);
    expect(find.text('Beranda'), findsOneWidget);
    expect(find.text('Profil'), findsOneWidget);
    expect(find.byIcon(Icons.home_rounded), findsOneWidget);
    expect(find.byIcon(Icons.school_rounded), findsOneWidget);
    expect(find.byIcon(Icons.storefront_rounded), findsOneWidget);
    expect(find.byIcon(Icons.person_rounded), findsOneWidget);
  });
}
