import 'package:firebase_auth/firebase_auth.dart';

class CredentialService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> sendOtp({
    required String phone,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phone,
      timeout: const Duration(seconds: 60),

      verificationCompleted: (credential) {
        // CURRENTLY DO NOTHING
      },

      verificationFailed: (FirebaseAuthException e) {
        onError(e.message ?? 'OTP verification failed');
      },

      codeSent: (verificationId, _) {
        onCodeSent(verificationId);
      },

      codeAutoRetrievalTimeout: (_) {},
    );
  }

  Future<void> verifyOtp({
    required String verificationId,
    required String otp,
  }) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: otp,
    );

    await _auth.signInWithCredential(credential);
  }
}
