import 'package:expense_tracker/util/encrption.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// --------------------
/// User State
/// --------------------
class UserState {
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? tempPassword;
  final int? securityQuestionIndex;
  final String? securityAnswer;
  final String? uid;

  const UserState({
    this.firstName,
    this.lastName,
    this.email,
    this.tempPassword,
    this.securityQuestionIndex,
    this.securityAnswer,
    this.uid,
  });

  UserState copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? tempPassword,
    int? securityQuestionIndex,
    String? securityAnswer,
    String? uid,
  }) {
    return UserState(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      tempPassword: tempPassword ?? this.tempPassword,
      securityQuestionIndex: securityQuestionIndex ?? this.securityQuestionIndex,
      securityAnswer: securityAnswer ?? this.securityAnswer,
      uid: uid ?? this.uid,
    );
  }
}

/// --------------------
/// User Cubit
/// --------------------
class UserCubit extends Cubit<UserState> {
  UserCubit() : super(const UserState());

  /// Step 1: Name Page
  void setName({
    required String firstName,
    required String lastName,
  }) {
    emit(state.copyWith(
      firstName: firstName.trim(),
      lastName: lastName.trim(),
    ));
  }

  /// Step 2: Email Page
  void setEmail(String email) {
    emit(state.copyWith(
      email: email.trim().toLowerCase(),
    ));
  }


  /// Step 2: Password Page
  void settempPassword(String tempPassword) {
    emit(state.copyWith(tempPassword: tempPassword));
  }


  /// Step 4: Security Question Page
  void setSecurityInfo({
    required int securityQuestionIndex,
    required String securityAnswer,
  }) {
    emit(state.copyWith(
      securityQuestionIndex: securityQuestionIndex,
      securityAnswer: hashData(securityAnswer.trim()),
    ));
  }


  /// After Firebase Auth success
  void setUid(String uid) {
    emit(state.copyWith(uid: uid));
  }

  void clearSensitiveData() {
    emit(state.copyWith(tempPassword: null, securityAnswer: null));
  }

  /// Clear everything after logout or failed registration
  void clear() {
    emit(const UserState());
  }

}
