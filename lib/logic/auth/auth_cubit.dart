import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../data/models/user_model.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  bool _isRegistering = false;

  AuthCubit(this._auth) : super(AuthInitial()) {
    _listenAuthChanges();
  }

  void resetState() => emit(AuthInitial());

  void _listenAuthChanges() {
    _auth.idTokenChanges().listen((user) async {
      if (_isRegistering) return;

      if (user == null) {
        if (state is! AuthUnauthenticated) emit(AuthUnauthenticated());
        return;
      }

      final isGoogleUser = user.providerData.any((p) => p.providerId == 'google.com');

      try {
        final docRef = _firestore.collection('users').doc(user.uid);
        final doc = await docRef.get(const GetOptions(source: Source.server));

        if (!doc.exists) {
          if (isGoogleUser) {
            final appUser = AppUser(
              uid: user.uid,
              email: user.email ?? '',
              authProvider: 'google',
              hasAppPassword: false,
              securityQuestionSelected: false,
              createdAt: DateTime.now(),
            );
            await docRef.set(appUser.toMap());

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

        final data = doc.data()!;

        if (!user.emailVerified && !isGoogleUser) {
          if (state is! AuthEmailUnverified) {
            emit(AuthEmailUnverified(email: user.email ?? ''));
          }
          return;
        }

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

  Future<void> register({required String email, required String password}) async {
    emit(RegisterLoading());
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
        emit(RegisterError('Could not send verification email.'));
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
      emit(RegisterSuccess(email: email));

    } on FirebaseAuthException catch (e) {
      emit(RegisterError(_mapFirebaseError(e)));
    } catch (_) {
      emit(RegisterError('Registration failed'));
    } finally {
      _isRegistering = false;
    }
  }

  Future<void> signInWithGoogle() async {
    emit(GoogleSignInLoading());
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        emit(AuthInitial());
        return;
      }
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      emit(GoogleSignInError(_mapFirebaseError(e)));
    } catch (_) {
      emit(GoogleSignInError('Google sign-in failed'));
    }
  }

  Future<void> checkEmailVerified() async {
    emit(VerifyLoading());
    try {
      final user = _auth.currentUser;
      if (user == null) { emit(AuthUnauthenticated()); return; }

      await user.reload();
      final refreshedUser = _auth.currentUser;
      if (refreshedUser == null) { emit(AuthUnauthenticated()); return; }

      if (!refreshedUser.emailVerified) {
        emit(VerifyEmailUnverified(email: refreshedUser.email ?? ''));
        return;
      }

      final doc = await _firestore.collection('users').doc(refreshedUser.uid).get();
      if (!doc.exists) { emit(VerifyError('User data not found')); return; }

      final data = doc.data()!;
      emit(VerifySuccess(
        uid: refreshedUser.uid,
        securityQuestionSelected: data['securityQuestionSelected'] ?? false,
      ));
    } catch (_) {
      emit(VerifyError('Something went wrong'));
    }
  }

  Future<String?> deleteAccount({
    String? email, 
    String? password
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return 'User not logged in';

      final uid = user.uid;

      final isGoogleUser = user.providerData
          .any((p) => p.providerId == 'google.com');

      final isEmailUser = user.providerData
          .any((p) => p.providerId == 'password');

      if (isGoogleUser) {
        try {
          final googleUser = await _googleSignIn.signIn();
          if (googleUser == null) {
            return 'Re-authentication cancelled';
          }

          final googleAuth = await googleUser.authentication;

          final credential = GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken,
          );

          await user.reauthenticateWithCredential(credential);
        } catch (_) {
          return 'Re-authentication failed. Please try again';
        }
      }

      if (isEmailUser) {
        if (email == null || password == null) {
          return 'Please enter your password to confirm account deletion';
        }

        try {
          final credential = EmailAuthProvider.credential(
            email: email,
            password: password,
          );

          await user.reauthenticateWithCredential(credential);
        } on FirebaseAuthException catch (e) {
          if (e.code == 'wrong-password') {
            return 'Incorrect password';
          }
          return 'Re-authentication failed';
        }
      }
      await _firestore.collection('users').doc(uid).delete();
      await user.delete();
      await _googleSignIn.signOut();

      return null;

    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        return 'Please login again before deleting your account';
      }
      return 'Failed to delete account';
    } catch (e) {
      return 'Something went wrong';
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
