import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/usecases/login_with_email_password.dart';
import '../../domain/usecases/login_with_google.dart';
import '../../domain/usecases/logout.dart';
import '../../domain/usecases/send_password_reset_email.dart';
import '../../domain/usecases/sign_up_with_email_password.dart';
import '../../domain/usecases/sync_user_profile.dart';
import '../../domain/usecases/watch_auth_state.dart';

class AuthController extends ChangeNotifier {
  AuthController({
    required WatchAuthState watchAuthState,
    required LoginWithEmailPassword loginWithEmailPassword,
    required LoginWithGoogle loginWithGoogle,
    required SignUpWithEmailPassword signUpWithEmailPassword,
    required SendPasswordResetEmail sendPasswordResetEmail,
    required SyncUserProfile syncUserProfile,
    required Logout logout,
  })  : _watchAuthState = watchAuthState,
        _loginWithEmailPassword = loginWithEmailPassword,
        _loginWithGoogle = loginWithGoogle,
        _signUpWithEmailPassword = signUpWithEmailPassword,
        _sendPasswordResetEmail = sendPasswordResetEmail,
        _syncUserProfile = syncUserProfile,
        _logout = logout {
    _bindAuthState();
  }

  factory AuthController.createDefault() {
    final repository = AuthRepositoryImpl(FirebaseAuthRemoteDatasource());
    return AuthController(
      watchAuthState: WatchAuthState(repository),
      loginWithEmailPassword: LoginWithEmailPassword(repository),
      loginWithGoogle: LoginWithGoogle(repository),
      signUpWithEmailPassword: SignUpWithEmailPassword(repository),
      sendPasswordResetEmail: SendPasswordResetEmail(repository),
      syncUserProfile: SyncUserProfile(repository),
      logout: Logout(repository),
    );
  }

  final WatchAuthState _watchAuthState;
  final LoginWithEmailPassword _loginWithEmailPassword;
  final LoginWithGoogle _loginWithGoogle;
  final SignUpWithEmailPassword _signUpWithEmailPassword;
  final SendPasswordResetEmail _sendPasswordResetEmail;
  final SyncUserProfile _syncUserProfile;
  final Logout _logout;
  StreamSubscription<AuthUser?>? _authStateSubscription;

  AuthUser? currentUser;
  String? errorMessage;
  String? statusMessage;
  bool isLoading = false;
  bool isReady = false;

  void _bindAuthState() {
    if (Firebase.apps.isEmpty) {
      isReady = true;
      return;
    }

    _authStateSubscription = _watchAuthState().listen(
      (user) {
        currentUser = user;
        isReady = true;
        notifyListeners();
      },
      onError: (_) {
        isReady = true;
        notifyListeners();
      },
    );
  }

  Future<void> loginWithEmailPassword({
    required String email,
    required String password,
  }) async {
    await _run(() async {
      currentUser = await _loginWithEmailPassword(
        email: email,
        password: password,
      );
      currentUser = await _syncUserProfile(currentUser!);
    });
  }

  Future<void> loginWithGoogle() async {
    await _run(() async {
      currentUser = await _loginWithGoogle();
      if (currentUser != null) {
        currentUser = await _syncUserProfile(currentUser!);
      }
    });
  }

  Future<void> signUpWithEmailPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    await _run(() async {
      currentUser = await _signUpWithEmailPassword(
        email: email,
        password: password,
        displayName: displayName,
      );
      currentUser = await _syncUserProfile(currentUser!);
    });
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _run(() async {
      await _sendPasswordResetEmail(email);
      statusMessage = 'Tautan reset kata sandi sudah dikirim ke email Anda.';
    });
  }

  Future<void> logout() async {
    await _run(() async {
      await _logout();
      currentUser = null;
    });
  }

  void clearMessages() {
    errorMessage = null;
    statusMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() action) async {
    isLoading = true;
    errorMessage = null;
    statusMessage = null;
    notifyListeners();

    try {
      await action();
    } catch (error) {
      errorMessage = error.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
