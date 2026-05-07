import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/app/app.dart';
import 'package:frontend/core/constants/route_constants.dart';
import 'package:frontend/core/constants/asset_constants.dart';
import 'package:frontend/features/cats/presentation/pages/add_cat_page.dart';
import 'package:frontend/features/education/presentation/controllers/education_controller.dart';
import 'package:frontend/features/education/presentation/pages/education_page.dart';
import 'package:frontend/features/home/presentation/pages/home_page.dart';
import 'package:frontend/features/profile/presentation/pages/profile_page.dart';

void main() {
  tearDown(() {
    EducationController.resetSharedStateForTests();
  });

  Future<void> pumpEducationUi(WidgetTester tester) async {
    await tester.pump();
    for (var i = 0; i < 6; i += 1) {
      await tester.pump(const Duration(milliseconds: 500));
    }
  }

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
      HomeAssets.homeIcon,
      HomeAssets.educationIcon,
      HomeAssets.marketIcon,
      HomeAssets.profileIcon,
      AuthAssets.loginCat,
      AuthAssets.signupCat,
      AuthAssets.facebookIcon,
      AuthAssets.googleIcon,
      AuthAssets.xIcon,
      ChatAssets.anaProfile,
      CatAssets.personalizationMascot,
      EducationAssets.heroBackground,
      EducationAssets.moduleCat,
      EducationAssets.moduleThinkingCat,
      EducationAssets.moduleMaterial,
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

  test('education image assets can be decoded as images', () async {
    TestWidgetsFlutterBinding.ensureInitialized();

    const images = [
      EducationAssets.heroBackground,
      EducationAssets.moduleCat,
      EducationAssets.moduleThinkingCat,
    ];

    for (final image in images) {
      final data = await rootBundle.load(image);
      final buffer = await ui.ImmutableBuffer.fromUint8List(
        data.buffer.asUint8List(),
      );
      final descriptor = await ui.ImageDescriptor.encoded(buffer);
      final codec = await descriptor.instantiateCodec();
      final frame = await codec.getNextFrame();

      expect(data.lengthInBytes, greaterThan(0), reason: image);
      expect(frame.image.width, greaterThan(0), reason: image);
      expect(frame.image.height, greaterThan(0), reason: image);

      frame.image.dispose();
      codec.dispose();
      descriptor.dispose();
      buffer.dispose();
    }
  });

  test('cat personalization asset can be decoded as an image', () async {
    TestWidgetsFlutterBinding.ensureInitialized();

    final data = await rootBundle.load(CatAssets.personalizationMascot);
    final buffer = await ui.ImmutableBuffer.fromUint8List(
      data.buffer.asUint8List(),
    );
    final descriptor = await ui.ImageDescriptor.encoded(buffer);
    final codec = await descriptor.instantiateCodec();
    final frame = await codec.getNextFrame();

    expect(data.lengthInBytes, greaterThan(0));
    expect(frame.image.width, greaterThan(0));
    expect(frame.image.height, greaterThan(0));

    frame.image.dispose();
    codec.dispose();
    descriptor.dispose();
    buffer.dispose();
  });

  testWidgets('add cat page renders sections and validates required name',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AddCatPage(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Tambah Kucing'), findsOneWidget);
    expect(find.text('Profil Kucing'), findsOneWidget);
    expect(find.text('Kotak Pasir'), findsOneWidget);
    expect(find.text('Rutinitas Harian'), findsOneWidget);
    expect(find.byKey(const ValueKey('cat-save-button')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('cat-save-button')));
    await tester.pump();

    expect(find.text('Nama kucing wajib diisi.'), findsOneWidget);
  });

  testWidgets('add cat page saves a valid cat profile', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AddCatPage(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('cat-name-field')),
      'Mochi',
    );
    await tester.tap(find.byKey(const ValueKey('cat-save-button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Profil kucing berhasil disimpan.'), findsOneWidget);
  });

  testWidgets('profile add pet button opens add cat page', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        initialRoute: RouteConstants.profile,
        routes: {
          RouteConstants.profile: (_) => const ProfilePage(),
          RouteConstants.addCat: (_) => const AddCatPage(),
          RouteConstants.editProfile: (_) => const SizedBox.shrink(),
          RouteConstants.safetyMode: (_) => const SizedBox.shrink(),
          RouteConstants.address: (_) => const SizedBox.shrink(),
          RouteConstants.home: (_) => const SizedBox.shrink(),
          RouteConstants.education: (_) => const SizedBox.shrink(),
          RouteConstants.marketplace: (_) => const SizedBox.shrink(),
          RouteConstants.scanCamera: (_) => const SizedBox.shrink(),
        },
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Tambah Hewan'));
    await tester.pumpAndSettle();

    expect(find.text('Tambah Kucing'), findsOneWidget);
  });

  testWidgets('cat onboarding skip dismisses dialog on home', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        onGenerateInitialRoutes: (_) => [
          MaterialPageRoute<void>(
            settings: const RouteSettings(
              name: RouteConstants.home,
              arguments: HomePageArguments(showCatOnboarding: true),
            ),
            builder: (_) => const HomePage(),
          ),
        ],
        routes: {
          RouteConstants.addCat: (_) => const AddCatPage(),
        },
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Lengkapi Profil Kucing'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('cat-onboarding-skip')));
    await tester.pumpAndSettle();

    expect(find.text('Lengkapi Profil Kucing'), findsNothing);
    expect(find.text('Anabool'), findsOneWidget);
  });

  testWidgets('cat onboarding start opens add cat page', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        onGenerateInitialRoutes: (_) => [
          MaterialPageRoute<void>(
            settings: const RouteSettings(
              name: RouteConstants.home,
              arguments: HomePageArguments(showCatOnboarding: true),
            ),
            builder: (_) => const HomePage(),
          ),
        ],
        routes: {
          RouteConstants.addCat: (_) => const AddCatPage(),
        },
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('cat-onboarding-start')));
    await tester.pumpAndSettle();

    expect(find.text('Tambah Kucing'), findsOneWidget);
  });

  testWidgets('app starts on login and login fields accept input',
      (tester) async {
    await tester.pumpWidget(const AnaboolApp());
    await tester.pump();

    expect(find.text('Masuk ke akun Anda'), findsOneWidget);
    expect(find.text('Buat Akun Anda'), findsNothing);

    await tester.enterText(
      find.byKey(const ValueKey('auth-field-email')),
      'alvin@example.com',
    );
    await tester.enterText(
      find.byKey(const ValueKey('auth-field-password')),
      'secret123',
    );

    expect(find.text('alvin@example.com'), findsOneWidget);
    expect(
      tester
          .widget<EditableText>(
            find.descendant(
              of: find.byKey(const ValueKey('auth-field-password')),
              matching: find.byType(EditableText),
            ),
          )
          .obscureText,
      isTrue,
    );

    await tester.tap(find.byKey(const ValueKey('auth-visibility-password')));
    await tester.pump();

    expect(
      tester
          .widget<EditableText>(
            find.descendant(
              of: find.byKey(const ValueKey('auth-field-password')),
              matching: find.byType(EditableText),
            ),
          )
          .obscureText,
      isFalse,
    );
  });

  testWidgets('auth links navigate between login and signup', (tester) async {
    await tester.pumpWidget(const AnaboolApp());
    await tester.pump();

    await tester.ensureVisible(find.text('Mendaftar'));
    await tester.tap(find.text('Mendaftar'));
    await tester.pumpAndSettle();

    expect(find.text('Buat Akun Anda'), findsOneWidget);
    expect(find.text('Masuk ke akun Anda'), findsNothing);

    await tester.ensureVisible(find.text('Masuk'));
    await tester.tap(find.text('Masuk'));
    await tester.pumpAndSettle();

    expect(find.text('Masuk ke akun Anda'), findsOneWidget);
    expect(find.text('Buat Akun Anda'), findsNothing);
  });

  testWidgets('signup fields accept input', (tester) async {
    await tester.pumpWidget(const AnaboolApp());
    await tester.pump();

    await tester.ensureVisible(find.text('Mendaftar'));
    await tester.tap(find.text('Mendaftar'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('auth-field-email')),
      'new@example.com',
    );
    await tester.enterText(
      find.byKey(const ValueKey('auth-field-username')),
      'putu_alvin',
    );
    await tester.enterText(
      find.byKey(const ValueKey('auth-field-password')),
      'secret123',
    );
    await tester.enterText(
      find.byKey(const ValueKey('auth-field-confirm-password')),
      'secret123',
    );

    expect(find.text('new@example.com'), findsOneWidget);
    expect(find.text('putu_alvin'), findsOneWidget);
  });

  testWidgets('home page renders the iPhone 16 Plus reference sections',
      (tester) async {
    tester.view.physicalSize = const Size(430, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: HomePage(),
      ),
    );
    await tester.pumpAndSettle();
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

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });

  testWidgets('bottom navigation modules tab opens education page',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        initialRoute: RouteConstants.home,
        routes: {
          RouteConstants.home: (_) => const HomePage(),
          RouteConstants.education: (_) => const Scaffold(
                body: Center(
                  child: Text('Lanjut belajar'),
                ),
              ),
        },
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.school_rounded));
    await pumpEducationUi(tester);

    final educationException = tester.takeException();
    expect(educationException, isNull);
    expect(find.text('Lanjut belajar'), findsOneWidget);
  });

  testWidgets('education page renders and filters modules', (tester) async {
    EducationController.resetSharedStateForTests();
    await tester.pumpWidget(
      MaterialApp(
        key: UniqueKey(),
        home: const EducationPage(),
      ),
    );
    await pumpEducationUi(tester);

    expect(find.text('Lanjut belajar'), findsOneWidget);
    expect(find.text('Daftar Modul'), findsOneWidget);
    expect(find.textContaining('modul belum selesai'), findsOneWidget);
    expect(find.text('Semua'), findsOneWidget);
    expect(find.byKey(const ValueKey('education-category-safety')),
        findsOneWidget);
    expect(find.byKey(const ValueKey('education-category-tutorial')),
        findsOneWidget);
    expect(find.text('Memahami Toxoplasma gondii'), findsWidgets);
    expect(find.text('33%'), findsWidgets);
    final progressBars = tester.widgetList<LinearProgressIndicator>(
      find.byType(LinearProgressIndicator),
    );
    expect(
      progressBars
          .any((bar) => (bar.value ?? 0) > 0.32 && (bar.value ?? 0) < 0.34),
      isTrue,
    );

    await tester.enterText(
      find.byKey(const ValueKey('education-search-field')),
      'hamil',
    );
    await tester.pump();

    expect(find.text('Memahami Toxoplasma gondii'), findsWidgets);

    await tester.enterText(
      find.byKey(const ValueKey('education-search-field')),
      '',
    );
    await tester.tap(find.byKey(const ValueKey('education-category-tutorial')));
    await tester.pump();

    expect(find.text('Modul tidak ditemukan.'), findsOneWidget);
  });
}
