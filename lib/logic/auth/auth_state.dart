abstract class AuthState {}

class AuthInitial extends AuthState {}

// ── Generic loading (keep for backward compat if needed) ──
class AuthLoading extends AuthState {
  final String? source;
  AuthLoading({this.source});
}

// ── Email Login ───────────────────────────────────────────
class LoginLoading extends AuthState {}
class LoginSuccess extends AuthState {
  final String uid;
  final bool securityQuestionSelected;
  LoginSuccess({required this.uid, required this.securityQuestionSelected});
}
class LoginError extends AuthState {
  final String message;
  LoginError(this.message);
}

// ── Google Sign In ────────────────────────────────────────
class GoogleSignInLoading extends AuthState {}
class GoogleSignInSuccess extends AuthState {
  final String uid;
  final bool securityQuestionSelected;
  GoogleSignInSuccess({required this.uid, required this.securityQuestionSelected});
}
class GoogleSignInError extends AuthState {
  final String message;
  GoogleSignInError(this.message);
}

// ── Registration ──────────────────────────────────────────
class RegisterLoading extends AuthState {}
class RegisterSuccess extends AuthState {
  final String email;
  RegisterSuccess({required this.email});
}
class RegisterError extends AuthState {
  final String message;
  RegisterError(this.message);
}

// ── Email Verification ────────────────────────────────────
class VerifyLoading extends AuthState {}
class VerifySuccess extends AuthState {
  final String uid;
  final bool securityQuestionSelected;
  VerifySuccess({required this.uid, required this.securityQuestionSelected});
}
class VerifyEmailUnverified extends AuthState {
  final String email;
  VerifyEmailUnverified({required this.email});
}
class VerifyError extends AuthState {
  final String message;
  VerifyError(this.message);
}

// ── Stream / Global ───────────────────────────────────────
class AuthAuthenticated extends AuthState {
  final String uid;
  final bool securityQuestionSelected;
  AuthAuthenticated({required this.uid, required this.securityQuestionSelected});
}
class AuthUnauthenticated extends AuthState {}
class AuthEmailUnverified extends AuthState {
  final String email;
  AuthEmailUnverified({required this.email});
}
class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}