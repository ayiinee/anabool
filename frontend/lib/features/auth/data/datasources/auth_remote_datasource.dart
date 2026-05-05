import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/network/api_config.dart';
import '../../domain/entities/auth_exception.dart';
import '../../domain/entities/auth_sync_mode.dart';
import '../models/auth_user_model.dart';

abstract class AuthRemoteDatasource {
  Stream<AuthUserModel?> watchAuthState();
  Future<AuthUserModel> loginWithEmailPassword({
    required String email,
    required String password,
  });
  Future<AuthUserModel> signUpWithEmailPassword({
    required String email,
    required String password,
    String? displayName,
  });
  Future<AuthUserModel?> loginWithGoogle();
  Future<void> sendPasswordResetEmail(String email);
  Future<AuthUserModel> syncUserProfile(
    AuthUserModel user, {
    required AuthSyncMode mode,
  });
  Future<void> logout();
}

class FirebaseAuthRemoteDatasource implements AuthRemoteDatasource {
  FirebaseAuthRemoteDatasource({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
    Dio? dio,
  })  : _firebaseAuth = firebaseAuth,
        _googleSignIn = googleSignIn,
        _dio = dio ?? Dio();

  final FirebaseAuth? _firebaseAuth;
  final Dio _dio;
  GoogleSignIn? _googleSignIn;

  FirebaseAuth get _auth {
    if (_firebaseAuth != null) {
      return _firebaseAuth;
    }
    if (Firebase.apps.isEmpty) {
      throw Exception(
        'Firebase belum diinisialisasi. Jalankan Firebase.initializeApp() terlebih dahulu.',
      );
    }
    return FirebaseAuth.instance;
  }

  GoogleSignIn get _signIn {
    return _googleSignIn ??= GoogleSignIn();
  }

  @override
  Stream<AuthUserModel?> watchAuthState() {
    if (Firebase.apps.isEmpty) {
      return const Stream<AuthUserModel?>.empty();
    }

    return _auth.authStateChanges().map(
          (user) => user == null ? null : AuthUserModel.fromFirebaseUser(user),
        );
  }

  @override
  Future<AuthUserModel> loginWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw Exception('Login gagal. Coba lagi.');
      }
      return AuthUserModel.fromFirebaseUser(user);
    } on FirebaseAuthException catch (error) {
      throw Exception(_mapFirebaseAuthError(error));
    }
  }

  @override
  Future<AuthUserModel> signUpWithEmailPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw Exception('Pendaftaran gagal. Coba lagi.');
      }

      final trimmedDisplayName = displayName?.trim();
      if (trimmedDisplayName != null && trimmedDisplayName.isNotEmpty) {
        await user.updateDisplayName(trimmedDisplayName);
        await user.reload();
      }

      return AuthUserModel.fromFirebaseUser(
        _auth.currentUser ?? user,
      );
    } on FirebaseAuthException catch (error) {
      throw Exception(_mapFirebaseAuthError(error));
    }
  }

  @override
  Future<AuthUserModel?> loginWithGoogle() async {
    try {
      UserCredential credential;

      if (kIsWeb) {
        credential = await _auth.signInWithPopup(
          GoogleAuthProvider(),
        );
      } else {
        final googleUser = await _signIn.signIn();
        if (googleUser == null) {
          return null;
        }

        final googleAuth = await googleUser.authentication;
        final authCredential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        credential = await _auth.signInWithCredential(authCredential);
      }

      final user = credential.user;
      if (user == null) {
        throw Exception('Login Google gagal. Coba lagi.');
      }

      return AuthUserModel.fromFirebaseUser(user);
    } on FirebaseAuthException catch (error) {
      throw Exception(_mapFirebaseAuthError(error));
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (error) {
      throw Exception(_mapFirebaseAuthError(error));
    }
  }

  @override
  Future<AuthUserModel> syncUserProfile(
    AuthUserModel user, {
    required AuthSyncMode mode,
  }) async {
    final firebaseUser = _auth.currentUser;
    final idToken = await firebaseUser?.getIdToken();
    if (idToken == null || idToken.isEmpty) {
      throw Exception('Token login tidak tersedia. Silakan masuk ulang.');
    }

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '${ApiConfig.baseUrl}/api/v1/auth/sync-user',
        data: {
          'idToken': idToken,
          'mode': mode.name,
          'displayName': user.displayName,
          'photoUrl': user.photoUrl,
        },
      );

      final responseData = response.data;
      final data = responseData?['data'];
      if (data is! Map<String, dynamic>) {
        return user;
      }

      final userData = data['user'];
      if (userData is! Map<String, dynamic>) {
        return user;
      }

      return AuthUserModel.fromJson(userData);
    } on DioException catch (error) {
      final backendData = error.response?.data;
      final message = _extractBackendMessage(backendData);
      final data = _extractBackendData(backendData);
      if (data?['reason'] == 'registration_required') {
        await logout();
        throw AuthRegistrationRequiredException(message);
      }
      throw Exception(message);
    }
  }

  @override
  Future<void> logout() async {
    await _signIn.signOut();
    return _auth.signOut();
  }

  String _extractBackendMessage(Object? responseData) {
    if (responseData is Map<String, dynamic>) {
      final message = responseData['message'];
      if (message is String && message.isNotEmpty) {
        return message;
      }
    }
    return 'Autentikasi backend gagal. Coba lagi.';
  }

  Map<String, dynamic>? _extractBackendData(Object? responseData) {
    if (responseData is Map<String, dynamic>) {
      final data = responseData['data'];
      if (data is Map<String, dynamic>) {
        return data;
      }
    }
    return null;
  }

  String _mapFirebaseAuthError(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-email':
        return 'Format email tidak valid.';
      case 'invalid-credential':
        return 'Email atau kata sandi tidak sesuai.';
      case 'user-not-found':
        return 'Akun tidak ditemukan.';
      case 'wrong-password':
        return 'Email atau kata sandi tidak sesuai.';
      case 'email-already-in-use':
        return 'Email ini sudah terdaftar.';
      case 'weak-password':
        return 'Kata sandi terlalu lemah.';
      case 'user-disabled':
        return 'Akun ini dinonaktifkan.';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan login. Coba lagi nanti.';
      case 'network-request-failed':
        return 'Koneksi internet bermasalah. Coba lagi.';
      case 'account-exists-with-different-credential':
        return 'Akun ini sudah terhubung dengan metode login lain.';
      case 'popup-closed-by-user':
        return 'Login Google dibatalkan.';
      default:
        return error.message ?? 'Terjadi kesalahan autentikasi.';
    }
  }
}
