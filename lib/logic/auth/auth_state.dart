abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {
  final String? source; // 'login' | 'register' | 'verify' | 'google'
  AuthLoading({this.source});
}

class AuthAuthenticated extends AuthState {
  final String uid;
  final bool securityQuestionSelected;
  AuthAuthenticated({required this.uid, required this.securityQuestionSelected});
}

class AuthUnauthenticated extends AuthState {}

class AuthEmailUnverified extends AuthState {
  final String email;
  final String? source;
  AuthEmailUnverified({
    required this.email, 
    this.source,
  });
}

class AuthError extends AuthState {
  final String message;
  final String? source;
  AuthError(this.message, {this.source});
}