import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kharchasutra/util/logging.dart';
import '../../../data/models/user_model.dart';
import '../../../services/app_services.dart';
import 'auth_state.dart';

/// Carries a user-facing message out of helper code to [_run].
class _AuthMessage implements Exception {
  final String message;
  _AuthMessage(this.message);
}

class AuthCubit extends Cubit<AuthState> {
  final log = logger(AuthCubit);
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  bool _isRegistering = false;
  StreamSubscription? _authSub;

  AuthCubit(this._auth) : super(AuthInitial()) {
    _listenAuthChanges();
  }

  void resetState() => emit(AuthInitial());


  // ───────────────────────── Helpers ─────────────────────────
  CollectionReference<Map<String, dynamic>> get _users => _firestore.collection('users');

  bool _hasProvider(User user, String id) => user.providerData.any((p) => p.providerId == id);

  User _requireUser() => _auth.currentUser ?? (throw _AuthMessage('User not logged in'));

  /// Returns null if the user cancels the Google picker.
  Future<AuthCredential?> _googleCredential() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;
    final auth = await googleUser.authentication;
    return GoogleAuthProvider.credential(
      accessToken: auth.accessToken,
      idToken: auth.idToken,
    );
  }

  Future<void> _reauthWithPassword(
    User user, 
    String email, 
    String password
  ) => user.reauthenticateWithCredential(
    EmailAuthProvider.credential(email: email, password: password),
  );

  Future<DocumentReference<Map<String, dynamic>>> _userRefByEmail(String email) async {
    final query = await _users
                          .where('email', isEqualTo: email)
                          .limit(1)
                          .get();
    if (query.docs.isEmpty) throw _AuthMessage('User not found');
    return query.docs.first.reference;
  }

  Future<void> _createUserDoc(
    String uid, 
    String email, 
    String provider
  ) => _users.doc(uid).set(
    AppUser(
      uid: uid,
      email: email,
      authProvider: provider,
      hasAppPassword: provider == 'email',
      securityQuestionSelected: false,
      createdAt: DateTime.now(),
    ).toMap()
  );

  /// Runs [action] and converts any failure into a user-facing message.
  /// Returns null on success.
  Future<String?> _run(
    Future<void> Function() action, {
    Map<String, String> errors = const {},
    String? onAuthError,
    String onError = 'Something went wrong',
  }) async {
    try {
      await action();
      return null;
    } on _AuthMessage catch (e) {
      return e.message;
    } on FirebaseAuthException catch (e) {
      return errors[e.code] ?? onAuthError ?? onError;
    } catch (_) {
      return onError;
    }
  }


  // ───────────────────────── Auth listener ─────────────────────────
  void _listenAuthChanges() {
    _authSub = _auth.idTokenChanges().listen((user) async {
      if (_isRegistering) return;

      if (user == null) {
        sessionService.cancel();
        if (state is! AuthUnauthenticated) emit(AuthUnauthenticated());
        return;
      }

      final isGoogleUser = _hasProvider(user, 'google.com');

      try {
        final doc = await _users
          .doc(user.uid)
          .get(const GetOptions(source: Source.server));

        if (!doc.exists) {
          if (isGoogleUser) {
            await _createUserDoc(user.uid, user.email ?? '', 'google');
            emit(AuthAuthenticated(
              uid: user.uid,
              securityQuestionSelected: false,
            ));
          } else {
            emit(AuthError('User not registered'));
            await Future.delayed(const Duration(milliseconds: 500));
            try {
              await user.delete();
            } catch (_) {
              await _auth.signOut();
            }
          }
          return;
        }

        if (!user.emailVerified && !isGoogleUser) {
          if (state is! AuthEmailUnverified) {
            emit(AuthEmailUnverified(email: user.email ?? ''));
          }
          return;
        }

        if (state is! AuthAuthenticated) {
          emit(AuthAuthenticated(
            uid: user.uid,
            securityQuestionSelected: doc.data()?['securityQuestionSelected'] ?? false,
          ));
        }
      } catch (_) {
        emit(AuthError('Failed to load user data'));
      }
    });
  }


  // ───────────────────────── Sign in / up ─────────────────────────
  Future<void> login(
    String email, 
    String password
  ) async {
    emit(LoginLoading());
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.toLowerCase(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      emit(LoginError(_mapFirebaseError(e)));
    } catch (_) {
      emit(LoginError('Something went wrong'));
    }
  }


  // ───────────────────────── Register ─────────────────────────
  Future<void> register({
    required String email, 
    required String password
  }) async {
    emit(RegisterLoading());
    _isRegistering = true;
    try {
      final user = (
        await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        )
      ).user!;

      try {
        await user.sendEmailVerification();
      } catch (_) {
        await user.delete();
        emit(RegisterError('Could not send verification email.'));
        return;
      }
      await _createUserDoc(user.uid, email, 'email');
      emit(RegisterSuccess(email: email));
    } on FirebaseAuthException catch (e) {
      emit(RegisterError(_mapFirebaseError(e)));
    } catch (_) {
      emit(RegisterError('Registration failed'));
    } finally {
      _isRegistering = false;
    }
  }


  // ───────────────────────── Sign in with Google ─────────────────────────
  Future<void> signInWithGoogle() async {
    emit(GoogleSignInLoading());
    try {
      final credential = await _googleCredential();
      if (credential == null) {
        emit(AuthInitial());
        return;
      }
      await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      emit(GoogleSignInError(_mapFirebaseError(e)));
    } catch (_) {
      emit(GoogleSignInError('Google sign-in failed'));
    }
  }


  // ───────────────────────── Check Email Verification ─────────────────────────
  Future<void> checkEmailVerified() async {
    emit(VerifyLoading());
    try {
      await _auth.currentUser?.reload();
      final user = _auth.currentUser;
      if (user == null) {
        emit(AuthUnauthenticated());
        return;
      }

      if (!user.emailVerified) {
        emit(VerifyEmailUnverified(email: user.email ?? ''));
        return;
      }

      final doc = await _users.doc(user.uid).get();
      if (!doc.exists) {
        emit(VerifyError('User data not found'));
        return;
      }

      emit(VerifySuccess(
        uid: user.uid,
        securityQuestionSelected: doc.data()!['securityQuestionSelected'] ?? false,
      ));
    } catch (_) {
      emit(VerifyError('Something went wrong'));
    }
  }


  // ───────────────────────── Account management ─────────────────────────
  Future<String?> deleteAccount({
    String? email, 
    String? password
  }) => _run(
    () async {
      final user = _requireUser();

      if (_hasProvider(user, 'google.com')) {
        try {
          final credential = await _googleCredential();
          if (credential == null) {
            throw _AuthMessage('Re-authentication cancelled');
          }
          await user.reauthenticateWithCredential(credential);
        } on _AuthMessage {
          rethrow;
        } catch (_) {
          throw _AuthMessage('Re-authentication failed. Please try again');
        }
      }

      if (_hasProvider(user, 'password')) {
        if (email == null || password == null) {
          throw _AuthMessage('Please enter your password to confirm account deletion');
        }
        try {
          await _reauthWithPassword(user, email, password);
        } on FirebaseAuthException catch (e) {
          throw _AuthMessage(e.code == 'wrong-password' ? 'Incorrect password' : 'Re-authentication failed');
        }
      }

      await _users.doc(user.uid).delete();
      await user.delete();
      await _googleSignIn.signOut();
    },
    errors: {
      'requires-recent-login': 'Please login again before deleting your account',
    },
    onAuthError: 'Failed to delete account',
  );


  // ───────────────────────── Resend Verification Email ─────────────────────────
  Future<String?> resendVerificationEmail() => _run(
    () async {
      final user = _auth.currentUser;
      if (user == null) throw _AuthMessage('User not found');
      await user.sendEmailVerification();
    },
    onError: 'Failed to resend verification email',
  );


  // ───────────────────────── Update Password ─────────────────────────
  Future<String?> updatePassword({required String newPassword}) => _run(
    () => _requireUser().updatePassword(newPassword),
    errors: {'requires-recent-login': 'Please login again to continue'},
    onAuthError: 'Password update failed',
  );


  // ───────────────────────── Update Security Question ─────────────────────────
  Future<String?> updateSecurityQuestion({
    required String email,
    required String securityQuestion,
    required String securityAnswer,
  }) => _run(
    () async {
      final ref = await _userRefByEmail(email);
      await ref.update({
        'securityQuestion': securityQuestion,
        'securityAnswer': securityAnswer,
        'securityQuestionSelected': true,
      });
    },
    onError: 'Failed to update security question',
  );


  // ───────────────────────── Verify Password ─────────────────────────
  Future<String?> verifyPassword({
    required String email,
    required String password,
  }) => _run(
    () => _reauthWithPassword(_requireUser(), email, password),
    errors: {
      'wrong-password': 'Incorrect password',
      'user-mismatch': 'Invalid user',
    },
    onAuthError: 'Password verification failed',
  );


  // ───────────────────────── Verify Security Question ─────────────────────────
  Future<String?> verifySecurityQuestion({
    required String email,
    required String securityQuestion,
    required String securityAnswer,
  }) => _run(
    () async {
      final data = (await (await _userRefByEmail(email)).get()).data()!;
      if (data['securityQuestion'] != securityQuestion) {
        throw _AuthMessage('Incorrect security question');
      }
      if (data['securityAnswer'] != securityAnswer) {
        throw _AuthMessage('Incorrect security answer');
      }
    },
    onError: 'Failed to verify security question',
  );


  // ───────────────────────── Send Password Reset Email ─────────────────────────
  Future<String?> sendPasswordResetEmail(String email) => _run(
    () => _auth.sendPasswordResetEmail(email: email),
    errors: {'invalid-email': 'Invalid email address'},
    onAuthError: 'Failed to send reset email',
  );


  // ───────────────────────── Email Registration Check ─────────────────────────
  Future<bool> isEmailRegistered(String email) async => (await _auth.fetchSignInMethodsForEmail(email)).isNotEmpty;


  // ───────────────────────── Session ─────────────────────────
  void sessionExpired() {
    sessionService.cancel();
    emit(AuthSessionTimeout());
  }


  // ───────────────────────── Logout ─────────────────────────
  Future<void> logout() async {
    sessionService.cancel();
    await _googleSignIn.signOut();
    await _auth.signOut();
    emit(AuthUnauthenticated());
  }


  // ───────────────────────── Error mapping ─────────────────────────
  static const _errorMessages = {
    'email-already-in-use': 'This email is already registered',
    'invalid-email': 'Invalid email address',
    'weak-password': 'Password is too weak',
    'user-not-found': 'User not found',
    'wrong-password': 'Incorrect password',
    'requires-recent-login': 'Please login again to continue',
    'invalid-credential': 'Incorrect email or password',
    'user-disabled': 'This account has been disabled',
  };

  String _mapFirebaseError(FirebaseAuthException e) => _errorMessages[e.code] ?? 'Authentication failed';

  @override
  Future<void> close() {
    _authSub?.cancel();
    return super.close();
  }
}