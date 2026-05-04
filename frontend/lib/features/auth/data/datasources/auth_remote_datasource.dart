import 'package:firebase_auth/firebase_auth.dart';

import '../models/auth_user_model.dart';

abstract class AuthRemoteDatasource {
  Future<AuthUserModel?> loginWithGoogle();
  Future<AuthUserModel> syncUserProfile(AuthUserModel user);
  Future<void> logout();
}

class FirebaseAuthRemoteDatasource implements AuthRemoteDatasource {
  FirebaseAuthRemoteDatasource({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseAuth _firebaseAuth;

  @override
  Future<AuthUserModel?> loginWithGoogle() async {
    final user = _firebaseAuth.currentUser;
    return user == null ? null : AuthUserModel.fromFirebaseUser(user);
  }

  @override
  Future<AuthUserModel> syncUserProfile(AuthUserModel user) async {
    return user;
  }

  @override
  Future<void> logout() {
    return _firebaseAuth.signOut();
  }
}
