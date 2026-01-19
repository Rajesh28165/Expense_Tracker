import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String firstName;
  final String lastName;
  final String email;
  final int securityQuestionIndex;
  final String securityAnswerHash;
  final DateTime createdAt;

  AppUser({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.securityQuestionIndex,
    required this.securityAnswerHash,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'securityQuestionIndex': securityQuestionIndex,
      'securityAnswerHash': securityAnswerHash,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory AppUser.fromMap(String uid, Map<String, dynamic> map) {
    return AppUser(
      uid: uid,
      firstName: map['firstName'],
      lastName: map['lastName'],
      email: map['email'],
      securityQuestionIndex: map['securityQuestionIndex'],
      securityAnswerHash: map['securityAnswerHash'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}
