import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class CurrentUserIdentity {
  const CurrentUserIdentity._();

  static const fallbackName = 'Anabool';
  static const fallbackEmail = 'anabool@example.com';
  static const fallbackUserId = 'local-user';

  static User? get firebaseUser {
    try {
      if (Firebase.apps.isEmpty) {
        return null;
      }

      return FirebaseAuth.instance.currentUser;
    } catch (_) {
      return null;
    }
  }

  static String displayName({String fallback = fallbackName}) {
    final user = firebaseUser;
    final displayName = user?.displayName?.trim();
    if (displayName != null && displayName.isNotEmpty) {
      return displayName;
    }

    final email = user?.email?.trim();
    if (email != null && email.isNotEmpty) {
      return email.split('@').first;
    }

    return fallback;
  }

  static String email({String fallback = fallbackEmail}) {
    final email = firebaseUser?.email?.trim();
    if (email != null && email.isNotEmpty) {
      return email;
    }

    return fallback;
  }

  static String userId({String fallback = fallbackUserId}) {
    final uid = firebaseUser?.uid.trim();
    if (uid != null && uid.isNotEmpty) {
      return uid;
    }

    return fallback;
  }

  static Future<void> updateDisplayName(String displayName) async {
    final trimmedName = displayName.trim();
    if (trimmedName.isEmpty) {
      return;
    }

    try {
      final user = firebaseUser;
      if (user == null || user.displayName?.trim() == trimmedName) {
        return;
      }

      await user.updateDisplayName(trimmedName);
      await user.reload();
    } catch (_) {
      return;
    }
  }
}
