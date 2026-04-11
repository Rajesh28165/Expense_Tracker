import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../data/models/user_model.dart';
import '../../util/logger.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final log = logger(AuthCubit);

  bool _isRegistering = false;

  AuthCubit(this._auth) : super(AuthInitial()) {
    _listenAuthChanges();
  }

  void resetState() => emit(AuthInitial());

  void _listenAuthChanges() {
    _auth.idTokenChanges().listen((user) async {

      if (_isRegistering) return;

      if (user == null) {
        if (state is! AuthUnauthenticated) {
          emit(AuthUnauthenticated());
        }
        return;
      }

      final isGoogleUser = user.providerData.any((p) => p.providerId == 'google.com');

      // ✅ Check Firestore FIRST before anything else
      try {
        final docRef = _firestore.collection('users').doc(user.uid);
        final doc = await docRef.get(const GetOptions(source: Source.server));

        if (!doc.exists) {
          log.d('user is deleted');
          final source = isGoogleUser ? 'google' : 'login';
          emit(AuthError('User not registered', source: source));
          await Future.delayed(const Duration(milliseconds: 500));
          try {
            await user.delete();
          } catch (_) {
            await _auth.signOut();
          }
          return;
        }

        final data = doc.data()!;

        // ✅ THEN check email verification
        if (!user.emailVerified && !isGoogleUser) {
          if (state is! AuthEmailUnverified) {
            // In stream when email not verified
            emit(AuthEmailUnverified(email: user.email ?? '', source: 'stream')); // ✅
          }
          return;
        }

        // ✅ User exists in Firestore and email is verified
        if (state is! AuthAuthenticated) {
          emit(AuthAuthenticated(
            uid: user.uid,
            securityQuestionSelected: data['securityQuestionSelected'] ?? false,
          ));
        }

      } catch (_) {
        emit(AuthError('Failed to load user data'));
      }
    });
  }


  Future<void> login(String email, String password) async {
    emit(AuthLoading(source: 'login'));
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.toLowerCase(), 
        password: password
      );
    } on FirebaseAuthException catch (e) {
      emit(AuthError(_mapFirebaseError(e), source: 'login'));
    } catch (_) {
      emit(AuthError('Something went wrong', source: 'login'));
    }
  }

  Future<void> register({
    required String email, 
    required String password
  }) async {
    emit(AuthLoading(source: 'register'));
    _isRegistering = true;
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = result.user!;

      try {
        await user.sendEmailVerification();
      } catch (e) {
        await user.delete();
        emit(AuthError('Could not send verification email.', source: 'register'));
        return;
      }

      final appUser = AppUser(
        uid: user.uid,
        email: email,
        authProvider: 'email',
        hasAppPassword: true,
        securityQuestionSelected: false,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(user.uid).set(appUser.toMap());

      emit(AuthEmailUnverified(email: email, source: 'register'));

    } on FirebaseAuthException catch (e) {
      emit(AuthError(_mapFirebaseError(e), source: 'register'));
    } catch (_) {
      emit(AuthError('Registration failed', source: 'register'));
    } finally {
      _isRegistering = false; // ✅ reset flag
    }
  }

  Future<void> signInWithGoogle() async {
    emit(AuthLoading(source: 'google'));
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) { 
        emit(AuthInitial());
        return; 
      }
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken, 
        idToken: googleAuth.idToken
      );
      await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      emit(AuthError(_mapFirebaseError(e), source: 'google'));
    } catch (_) {
      emit(AuthError('Google sign-in failed', source: 'google'));
    }
  }


  Future<void> checkEmailVerified() async {
    emit(AuthLoading(source: 'verify'));

    try {
      final user = _auth.currentUser;

      if (user == null) {
        emit(AuthUnauthenticated());
        return;
      }

      await user.reload();
      final refreshedUser = _auth.currentUser;

      if (refreshedUser == null) {
        emit(AuthUnauthenticated());
        return;
      }

      if (!refreshedUser.emailVerified) {
        emit(AuthEmailUnverified(email: refreshedUser.email ?? '', source: 'verify'));
        return;
      }

      final doc = await _firestore
          .collection('users')
          .doc(refreshedUser.uid)
          .get();

      if (!doc.exists) {
        emit(AuthError('User data not found', source: 'verify'));
        return;
      }

      final data = doc.data()!;

      emit(AuthAuthenticated(
        uid: refreshedUser.uid,
        securityQuestionSelected: data['securityQuestionSelected'] ?? false,
      ));

    } catch (_) {
      emit(AuthError('Something went wrong', source: 'verify'));
    }
  }


  Future<String?> resendVerificationEmail() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return 'User not found';
      await user.sendEmailVerification();
      return null;
    } catch (_) {
      return 'Failed to resend verification email';
    }
  }
  
  /// UPDATE PASSWORD
  Future<String?> updatePassword({
    required String newPassword,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return 'User not logged in';
      }
      await user.updatePassword(newPassword);
      return null; //  success
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        return 'Please login again to continue';
      }
      return 'Password update failed';
    } catch (_) {
      return 'Something went wrong';
    }
  }


  /// UPDATE SECURITY QUESTION
  Future<String?> updateSecurityQuestion({
    required String email,
    required String securityQuestion,
    required String securityAnswer,
  }) async {
    try {
      final query = await _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

      if (query.docs.isEmpty) {
        return 'User not found';
      }

      final docId = query.docs.first.id;

      await _firestore.collection('users').doc(docId).update({
        'securityQuestion': securityQuestion,
        'securityAnswer': securityAnswer,
        'securityQuestionSelected': true,
      });

      return null; //  success
    } catch (_) {
      return 'Failed to update security question';
    }
  }


  /// CHECK EMAIL EXISTS
  Future<bool> isEmailRegistered(String email) async {
    final methods = await _auth.fetchSignInMethodsForEmail(email);
    return methods.isNotEmpty;
  }


  /// LOGOUT
  Future<void> logout() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  /// VERIFY PASSWORD
  Future<String?> verifyPassword({
    required String email,
    required String password,
  }) async {
    try {
      final user = _auth.currentUser;

      if (user == null) {
        return 'User not logged in';
      }

      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );

      await user.reauthenticateWithCredential(credential);

      return null; //  success
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        return 'Incorrect password';
      }
      if (e.code == 'user-mismatch') {
        return 'Invalid user';
      }
      return 'Password verification failed';
    } catch (_) {
      return 'Something went wrong';
    }
  }

  /// VERIFY SECURITY QUESTION
  Future<String?> verifySecurityQuestion({
    required String email,
    required String securityQuestion,
    required String securityAnswer,
  }) async {
    try {
      final query = await _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

      if (query.docs.isEmpty) {
        return 'User not found';
      }

      final data = query.docs.first.data();

      if (data['securityQuestion'] != securityQuestion) {
        return 'Incorrect security question';
      }

      if (data['securityAnswer'] != securityAnswer) {
        return 'Incorrect security answer';
      }

      return null; //  success
    } catch (_) {
      return 'Failed to verify security question';
    }
  }


  /// FORGOT PASSWORD (EMAIL RESET)
  Future<String?> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null; // success
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email') {
        return 'Invalid email address';
      }
      return 'Failed to send reset email';
    } catch (e) {
      return 'Something went wrong';
    }
  }


  /// ERROR MAPPING
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
      case 'invalid-credential':
        return 'Incorrect email or password';
      case 'user-disabled':
        return 'This account has been disabled';
      default:
        return 'Authentication failed';
    }
  }
}
