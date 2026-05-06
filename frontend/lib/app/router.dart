import 'package:flutter/material.dart';

import '../core/constants/route_constants.dart';
import '../features/auth/presentation/pages/auth_gate_page.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/signup_page.dart';
import '../features/home/presentation/pages/home_page.dart';
import '../features/chat/presentation/pages/chat_page.dart';
import '../features/education/presentation/pages/education_complete_page.dart';
import '../features/education/presentation/pages/education_detail_page.dart';
import '../features/education/presentation/pages/education_page.dart';
import '../features/pickup/presentation/controllers/pickup_controller.dart';
import '../features/pickup/presentation/pages/pickup_agents_page.dart';
import '../features/pickup/presentation/pages/pickup_category_page.dart';
import '../features/pickup/presentation/pages/pickup_tracking_page.dart';
import '../features/scan/domain/entities/scan_session.dart';
import '../features/scan/presentation/pages/scan_camera_page.dart';
import '../features/scan/presentation/pages/scan_preview_page.dart';
import '../features/scan/presentation/pages/scan_result_page.dart';
import '../features/marketplace/presentation/pages/marketplace_page.dart';
import '../features/marketplace/presentation/pages/marketplace_product_detail_page.dart';

class AppRouter {
  const AppRouter._();

  static const initialRoute = RouteConstants.authGate;

  static Map<String, WidgetBuilder> get routes {
    return {
      RouteConstants.authGate: (_) => const AuthGatePage(),
      RouteConstants.login: (_) => const LoginPage(),
      RouteConstants.signup: (_) => const SignupPage(),
      RouteConstants.home: (_) => const HomePage(),
      RouteConstants.chat: (context) {
        final arguments = ModalRoute.of(context)?.settings.arguments;
        if (arguments is ChatPageArguments) {
          return ChatPage(
            scanId: arguments.scanId,
            initialScanSession: arguments.scanSession,
            initialScanImageFile: arguments.imageFile,
          );
        }

        if (arguments is ScanSession && arguments.id.isNotEmpty) {
          return ChatPage(
            scanId: arguments.id,
            initialScanSession: arguments,
          );
        }

        if (arguments is String && arguments.trim().isNotEmpty) {
          return ChatPage(scanId: arguments.trim());
        }

        return const ChatPage();
      },
      RouteConstants.education: (_) => const EducationPage(),
      RouteConstants.educationDetail: (context) {
        final arguments = ModalRoute.of(context)?.settings.arguments;
        if (arguments is String) {
          return EducationDetailPage(contentId: arguments);
        }

        return const EducationPage();
      },
      RouteConstants.educationComplete: (context) {
        final arguments = ModalRoute.of(context)?.settings.arguments;
        if (arguments is EducationCompleteArguments) {
          return EducationCompletePage(arguments: arguments);
        }

        return const EducationPage();
      },
      RouteConstants.scanCamera: (_) => const ScanCameraPage(),
      RouteConstants.scanPreview: (context) {
        final arguments = ModalRoute.of(context)?.settings.arguments;
        if (arguments is ScanPreviewArguments) {
          return ScanPreviewPage(arguments: arguments);
        }

        return const ScanCameraPage();
      },
      RouteConstants.scanResult: (context) {
        final arguments = ModalRoute.of(context)?.settings.arguments;
        if (arguments is ScanSession) {
          return ScanResultPage(session: arguments);
        }

        return const ScanCameraPage();
      },
      RouteConstants.pickup: (_) => const PickupCategoryPage(),
      RouteConstants.pickupAgents: (context) {
        final arguments = ModalRoute.of(context)?.settings.arguments;
        if (arguments is PickupController) {
          return PickupAgentsPage(controller: arguments);
        }

        return const PickupCategoryPage();
      },
      RouteConstants.pickupTracking: (context) {
        final arguments = ModalRoute.of(context)?.settings.arguments;
        if (arguments is PickupController) {
          return PickupTrackingPage(controller: arguments);
        }

        return const PickupCategoryPage();
      },
      RouteConstants.marketplace: (_) => const MarketplacePage(),
      RouteConstants.marketplaceDetail: (context) {
        final arguments = ModalRoute.of(context)?.settings.arguments;
        if (arguments is String) {
          return MarketplaceProductDetailPage(productId: arguments);
        }

        return const MarketplacePage();
      },
    };
  }
}
