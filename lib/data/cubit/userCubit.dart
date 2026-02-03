import 'package:expense_tracker/util/encrption.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// --------------------
/// User State
/// --------------------
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
      securityQuestionIndex:
          securityQuestionIndex ?? this.securityQuestionIndex,
      securityAnswerHash:
          securityAnswerHash ?? this.securityAnswerHash,
      securityQuestionSelected:
          securityQuestionSelected ?? this.securityQuestionSelected,
    );
  }
}

/// --------------------
/// User Cubit
/// --------------------
class UserCubit extends Cubit<UserState> {
  UserCubit() : super(const UserState());

  /// 🔹 REGISTRATION (single screen)
  void setBasicInfo({
    required String fullName,
    required String email,
    required String password,
    required String authProvider,
  }) {
    emit(state.copyWith(
      fullName: fullName.trim(),
      email: email.trim().toLowerCase(),
      tempPassword: password,
      authProvider: authProvider,
      hasAppPassword: authProvider == 'email',
    ));
  }

  /// 🔐 SECURITY QUESTION (mandatory first-time)
  void setSecurityInfo({
    required int securityQuestionIndex,
    required String securityAnswer,
  }) {
    emit(state.copyWith(
      securityQuestionIndex: securityQuestionIndex,
      securityAnswerHash: hashData(securityAnswer.trim()),
      securityQuestionSelected: true,
    ));
  }

  /// 🔁 LOAD USER FROM FIRESTORE (login / app restart)
  void hydrateFromFirestore({
    required String uid,
    required String fullName,
    required String email,
    required String authProvider,
    required bool hasAppPassword,
    required bool securityQuestionSelected,
    int? securityQuestionIndex,
  }) {
    emit(state.copyWith(
      uid: uid,
      fullName: fullName,
      email: email,
      authProvider: authProvider,
      hasAppPassword: hasAppPassword,
      securityQuestionSelected: securityQuestionSelected,
      securityQuestionIndex: securityQuestionIndex,
    ));
  }

  /// 🔄 UPDATE PASSWORD (Firebase + Firestore flag)
  void markPasswordUpdated() {
    emit(state.copyWith(hasAppPassword: true));
  }

  /// 🔄 UPDATE SECURITY QUESTION (future screen)
  void updateSecurityQuestion({
    required int securityQuestionIndex,
    required String securityAnswer,
  }) {
    emit(state.copyWith(
      securityQuestionIndex: securityQuestionIndex,
      securityAnswerHash: hashData(securityAnswer.trim()),
      securityQuestionSelected: true,
    ));
  }

  /// 🧹 CLEAR TEMP / SENSITIVE DATA
  void clearSensitiveData() {
    emit(state.copyWith(
      tempPassword: null,
      securityAnswerHash: null,
    ));
  }

  /// 🚪 LOGOUT
  void clear() {
    emit(const UserState());
  }
}
