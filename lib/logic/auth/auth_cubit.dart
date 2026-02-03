import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  AuthCubit(this._auth) : super(AuthInitial()) {
    _listenAuthChanges();
  }

  /// 🔁 LISTEN AUTH STATE (app start / auto-login)
  void _listenAuthChanges() {
    _auth.authStateChanges().listen((user) async {
      if (user == null) {
        emit(AuthUnauthenticated());
        return;
      }

      try {
        final doc =
            await _firestore.collection('users').doc(user.uid).get();

        if (!doc.exists) {
          emit(AuthUnauthenticated());
          return;
        }

        final data = doc.data()!;

        emit(
          AuthAuthenticated(
            uid: user.uid,
            securityQuestionSelected:
                data['securityQuestionSelected'] ?? false,
          ),
        );
      } catch (_) {
        emit(AuthError('Failed to load user data'));
      }
    });
  }

  /// 📧 EMAIL LOGIN
  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _emitAuthenticated(result.user!.uid);
    } on FirebaseAuthException catch (e) {
      emit(AuthError(_mapFirebaseError(e)));
    } catch (_) {
      emit(AuthError('Something went wrong'));
    }
  }

  /// 📝 EMAIL REGISTER
  Future<void> register(String email, String password) async {
    emit(AuthLoading());
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 🔑 After registration, user will NOT have security question yet
      emit(
        AuthAuthenticated(
          uid: result.user!.uid,
          securityQuestionSelected: false,
        ),
      );
    } on FirebaseAuthException catch (e) {
      emit(AuthError(_mapFirebaseError(e)));
    } catch (_) {
      emit(AuthError('Something went wrong'));
    }
  }

  /// 🔐 GOOGLE SIGN-IN
  Future<void> signInWithGoogle() async {
    emit(AuthLoading());

    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        emit(AuthUnauthenticated());
        return;
      }

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final result = await _auth.signInWithCredential(credential);
      await _emitAuthenticated(result.user!.uid);
    } on FirebaseAuthException catch (e) {
      emit(AuthError(_mapFirebaseError(e)));
    } catch (_) {
      emit(AuthError('Google sign-in failed'));
    }
  }

  /// 🔄 UPDATE PASSWORD
  Future<void> updatePassword({
    required String email,
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final credential = EmailAuthProvider.credential(
        email: email,
        password: oldPassword,
      );

      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      emit(AuthError(_mapFirebaseError(e)));
    }
  }

  /// 🔍 CHECK EMAIL EXISTS
  Future<bool> isEmailRegistered(String email) async {
    final methods = await _auth.fetchSignInMethodsForEmail(email);
    return methods.isNotEmpty;
  }

  /// 🚪 LOGOUT
  Future<void> logout() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
    emit(AuthUnauthenticated());
  }

  /// 🧠 SHARED AUTH EMITTER
  Future<void> _emitAuthenticated(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();

    final data = doc.data();

    emit(
      AuthAuthenticated(
        uid: uid,
        securityQuestionSelected:
            data?['securityQuestionSelected'] ?? false,
      ),
    );
  }

  /// ❌ ERROR MAPPING
  String _mapFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'This email is already registered';
      case 'invalid-email':
        return 'Invalid email address';
      case 'weak-password':
        return 'Password is too weak';
      case 'user-not-found':
        return 'User not found';
      case 'wrong-password':
        return 'Incorrect password';
      case 'requires-recent-login':
        return 'Please login again to continue';
      default:
        return 'Authentication failed';
    }
  }
}
