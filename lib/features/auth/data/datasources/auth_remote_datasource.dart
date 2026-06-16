import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/error/exceptions.dart';
import '../models/user_model.dart';

abstract interface class AuthRemoteDataSource {
  Future<UserModel> signInWithEmail(String email, String password);
  Future<UserModel> signUpWithEmail(String name, String email, String password);
  Future<UserModel> signInWithGoogle();
  Future<void> signOut();
  Future<void> forgotPassword(String email);
  UserModel? getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  const AuthRemoteDataSourceImpl({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
  }) : _auth = auth,
       _firestore = firestore;

  // ── Sign In ──────────────────────────────────────────────────
  @override
  Future<UserModel> signInWithEmail(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return await _fetchOrCreateUser(cred.user!);
    } on FirebaseAuthException catch (e) {
      throw AuthException(message: _mapFirebaseError(e.code), code: e.code);
    }
  }

  // ── Sign Up ──────────────────────────────────────────────────
  @override
  Future<UserModel> signUpWithEmail(
    String name,
    String email,
    String password,
  ) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await cred.user!.updateDisplayName(name);
      final model = UserModel(
        uid: cred.user!.uid,
        email: email,
        name: name,
        photoUrl: '',
        isPremium: false,
      );
      await _firestore
          .collection('users')
          .doc(cred.user!.uid)
          .set(model.toMap());
      return model;
    } on FirebaseAuthException catch (e) {
      throw AuthException(message: _mapFirebaseError(e.code), code: e.code);
    }
  }

  // ── Google Sign In (v7 API) ──────────────────────────────────
  // @override
  // Future<UserModel> signInWithGoogle() async {
  //   try {
  //     // v7 — singleton, authenticate() replaces signIn()
  //     final response = await GoogleSignIn.instance.authenticate();

  //     final credential = GoogleAuthProvider.credential(
  //       accessToken: response.authentication.accessToken,
  //       idToken: response.authentication.idToken,
  //     );

  //     final cred = await _auth.signInWithCredential(credential);
  //     return await _fetchOrCreateUser(cred.user!);
  //   } on GoogleSignInException catch (e) {
  //     if (e.code == GoogleSignInExceptionCode.canceled) {
  //       throw const AuthException(message: 'Google sign-in cancelled.');
  //     }
  //     throw AuthException(message: e.toString());
  //   } on FirebaseAuthException catch (e) {
  //     throw AuthException(message: _mapFirebaseError(e.code), code: e.code);
  //   } catch (e) {
  //     throw AuthException(message: e.toString());
  //   }
  // }

  // ── Google Sign In (v7 API) ──────────────────────────────────
  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      // Step 1 — Authentication (identity — who the user is)
      final googleUser = await GoogleSignIn.instance.authenticate();

      // Step 2 — Authorization (get accessToken via scopes)
      final clientAuth = await googleUser.authorizationClient.authorizeScopes([
        'email',
        'profile',
      ]);

      // Step 3 — Firebase credential
      final credential = GoogleAuthProvider.credential(
        idToken: googleUser.authentication.idToken,
        accessToken: clientAuth.accessToken,
      );

      // Step 4 — Firebase sign in
      final cred = await _auth.signInWithCredential(credential);
      return await _fetchOrCreateUser(cred.user!);
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        throw const AuthException(message: 'Google sign-in cancelled.');
      }
      throw AuthException(message: e.toString());
    } on FirebaseAuthException catch (e) {
      throw AuthException(message: _mapFirebaseError(e.code), code: e.code);
    } catch (e) {
      throw AuthException(message: e.toString());
    }
  }

  // ── Sign Out ─────────────────────────────────────────────────
  @override
  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      GoogleSignIn.instance.signOut(), // v7 singleton
    ]);
  }

  // ── Forgot Password ──────────────────────────────────────────
  @override
  Future<void> forgotPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthException(message: _mapFirebaseError(e.code), code: e.code);
    }
  }

  // ── Current User ─────────────────────────────────────────────
  @override
  UserModel? getCurrentUser() {
    final user = _auth.currentUser;
    if (user == null) return null;
    return UserModel(
      uid: user.uid,
      email: user.email ?? '',
      name: user.displayName ?? '',
      photoUrl: user.photoURL ?? '',
      isPremium: false,
    );
  }

  // ── Private Helpers ──────────────────────────────────────────

  Future<UserModel> _fetchOrCreateUser(User firebaseUser) async {
    final doc = await _firestore
        .collection('users')
        .doc(firebaseUser.uid)
        .get();

    if (doc.exists) {
      return UserModel.fromMap(doc.data()!);
    }

    final model = UserModel(
      uid: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      name: firebaseUser.displayName ?? '',
      photoUrl: firebaseUser.photoURL ?? '',
      isPremium: false,
    );
    await _firestore
        .collection('users')
        .doc(firebaseUser.uid)
        .set(model.toMap());
    return model;
  }

  String _mapFirebaseError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'Enter a valid email address.';
      case 'weak-password':
        return 'Password must be at least 8 characters.';
      case 'too-many-requests':
        return 'Too many attempts. Try again later.';
      case 'network-request-failed':
        return 'No internet connection.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}
