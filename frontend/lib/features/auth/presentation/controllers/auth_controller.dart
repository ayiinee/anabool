import 'package:flutter/foundation.dart';

import '../../domain/entities/auth_user.dart';
import '../../domain/usecases/login_with_google.dart';
import '../../domain/usecases/logout.dart';
import '../../domain/usecases/sync_user_profile.dart';

class AuthController extends ChangeNotifier {
  AuthController({
    required LoginWithGoogle loginWithGoogle,
    required SyncUserProfile syncUserProfile,
    required Logout logout,
  })  : _loginWithGoogle = loginWithGoogle,
        _syncUserProfile = syncUserProfile,
        _logout = logout;

  final LoginWithGoogle _loginWithGoogle;
  final SyncUserProfile _syncUserProfile;
  final Logout _logout;

  AuthUser? currentUser;
  String? errorMessage;
  bool isLoading = false;

  Future<void> loginWithGoogle() async {
    await _run(() async {
      currentUser = await _loginWithGoogle();
      if (currentUser != null) {
        currentUser = await _syncUserProfile(currentUser!);
      }
    });
  }

  Future<void> logout() async {
    await _run(() async {
      await _logout();
      currentUser = null;
    });
  }

  Future<void> _run(Future<void> Function() action) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await action();
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
