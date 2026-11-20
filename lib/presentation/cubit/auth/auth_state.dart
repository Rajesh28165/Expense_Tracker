abstract class AuthState {}

class AuthInitial extends AuthState {}

// ── Generic loading ──
class AuthLoading extends AuthState {
  final String? source;
  AuthLoading({this.source});
}

// ── Email Login ───────────────────────────────────────────
class LoginLoading extends AuthState {}
class LoginSuccess extends AuthState {
  final String uid;
  final bool securityQuestionSelected;
  LoginSuccess({
    required this.uid, 
    required this.securityQuestionSelected
  });
}

// ── Google Sign In ────────────────────────────────────────
class GoogleSignInLoading extends AuthState {}
class GoogleSignInSuccess extends AuthState {
  final String uid;
  final bool securityQuestionSelected;
  GoogleSignInSuccess({
    required this.uid, 
    required this.securityQuestionSelected
  });
}

// ── Registration ──────────────────────────────────────────
class RegisterLoading extends AuthState {}
class RegisterSuccess extends AuthState {
  final String email;
  RegisterSuccess({required this.email});
}

// ── Email Verification ────────────────────────────────────
class VerifyLoading extends AuthState {}
class VerifySuccess extends AuthState {
  final String uid;
  final bool securityQuestionSelected;
  VerifySuccess({
    required this.uid, 
    required this.securityQuestionSelected
  });
}
class VerifyEmailUnverified extends AuthState {
  final String email;
  VerifyEmailUnverified({required this.email});
}


// ── Stream / Global ───────────────────────────────────────
class AuthAuthenticated extends AuthState {
  final String uid;
  final bool securityQuestionSelected;
  AuthAuthenticated({
    required this.uid, 
    required this.securityQuestionSelected
  });
}
class AuthUnauthenticated extends AuthState {}
class AuthEmailUnverified extends AuthState {
  final String email;
  AuthEmailUnverified({required this.email});
}

class AuthSessionTimeout extends AuthState {}

// ------------------------------------------------------------------------

// Error States

abstract class AuthErrorState extends AuthState {
  final String message;

  AuthErrorState(this.message);
}

class LoginError extends AuthErrorState {
  LoginError(super.message);
}

class GoogleSignInError extends AuthErrorState {
  GoogleSignInError(super.message);
}

class AuthError extends AuthErrorState {
  AuthError(super.message);
}

class RegisterError extends AuthErrorState {
  RegisterError(super.message);
}

class VerifyError extends AuthErrorState {
  VerifyError(super.message);
}