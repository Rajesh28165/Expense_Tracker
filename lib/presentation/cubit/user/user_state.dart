class UserState {
  final String? uid;
  final String? fullName;
  final String? email;

  /// auth metadata (derived from Firestore)
  final String? authProvider; // 'email' | 'google'
  final bool hasAppPassword;

  /// temporary values (never persisted)
  final String? tempPassword;

  /// security question
  final int? securityQuestionIndex;
  final String? securityAnswerHash;
  final bool securityQuestionSelected;

  const UserState({
    this.uid,
    this.fullName,
    this.email,
    this.authProvider,
    this.hasAppPassword = false,
    this.tempPassword,
    this.securityQuestionIndex,
    this.securityAnswerHash,
    this.securityQuestionSelected = false,
  });

  UserState copyWith({
    String? uid,
    String? fullName,
    String? email,
    String? authProvider,
    bool? hasAppPassword,
    String? tempPassword,
    int? securityQuestionIndex,
    String? securityAnswerHash,
    bool? securityQuestionSelected,
  }) {
    return UserState(
      uid: uid ?? this.uid,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      authProvider: authProvider ?? this.authProvider,
      hasAppPassword: hasAppPassword ?? this.hasAppPassword,
      tempPassword: tempPassword ?? this.tempPassword,
      securityQuestionIndex: securityQuestionIndex ?? this.securityQuestionIndex,
      securityAnswerHash: securityAnswerHash ?? this.securityAnswerHash,
      securityQuestionSelected: securityQuestionSelected ?? this.securityQuestionSelected,
    );
  }
}
