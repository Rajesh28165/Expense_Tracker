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
        final doc = await _firestore.collection('users').doc(user.uid).get();

        if (!doc.exists) {
          emit(AuthUnauthenticated());
          return;
        }

        final data = doc.data()!;

        emit(
          AuthAuthenticated(
            uid: user.uid,
            securityQuestionSelected: data['securityQuestionSelected'] ?? false,
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
      await _auth.signInWithEmailAndPassword(
        email: email.toLowerCase(),
        password: password,
      );

    } on FirebaseAuthException catch (e) {
      emit(AuthError(_mapFirebaseError(e)));
    } catch (_) {
      emit(AuthError('Something went wrong'));
    }
  }

  /// 📝 EMAIL REGISTER
  Future<void> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    emit(AuthLoading());

    try {
      // 1️⃣ Create Firebase Auth account
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = result.user!;
      final uid = user.uid;

      // 2️⃣ Create AppUser model
      final appUser = AppUser(
        uid: uid,
        fullName: fullName,
        email: email,
        authProvider: 'email',
        hasAppPassword: true,
        securityQuestionSelected: false,
        createdAt: DateTime.now(),
      );

      // 3️⃣ Save to Firestore
      await _firestore.collection('users').doc(uid).set(appUser.toMap());

      // 4️⃣ Emit authenticated state
      emit(
        AuthAuthenticated(
          uid: uid,
          securityQuestionSelected: false,
        ),
      );
    } on FirebaseAuthException catch (e) {
      emit(AuthError(_mapFirebaseError(e)));
    } catch (_) {
      emit(AuthError('Registration failed'));
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

      await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      emit(AuthError(_mapFirebaseError(e)));
    } catch (_) {
      emit(AuthError('Google sign-in failed'));
    }
  }

  /// 🔄 UPDATE PASSWORD
  Future<String?> updatePassword({
    required String newPassword,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return 'User not logged in';
      }
      await user.updatePassword(newPassword);
      return null; // ✅ success
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

      return null; // ✅ success
    } catch (_) {
      return 'Failed to update security question';
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

      return null; // ✅ success
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

      return null; // ✅ success
    } catch (_) {
      return 'Failed to verify security question';
    }
  }


  /// 🔐 FORGOT PASSWORD (EMAIL RESET)
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
