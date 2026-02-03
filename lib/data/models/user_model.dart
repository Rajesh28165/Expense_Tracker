import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents application-level user data stored in Firestore
class AppUser {
  final String uid;
  final String fullName;
  final String email;

  /// auth provider used to create account
  /// examples: 'email', 'google'
  final String authProvider;

  /// whether user has email/password set in Firebase Auth
  final bool hasAppPassword;

  /// security question info (app-level security)
  final int? securityQuestionIndex;
  final String? securityAnswerHash;
  final bool securityQuestionSelected;

  final DateTime createdAt;

  AppUser({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.authProvider,
    required this.hasAppPassword,
    required this.securityQuestionSelected,
    required this.createdAt,
    this.securityQuestionIndex,
    this.securityAnswerHash,
  });

  /// Convert model → Firestore map
  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'email': email,
      'authProvider': authProvider,
      'hasAppPassword': hasAppPassword,
      'securityQuestionIndex': securityQuestionIndex,
      'securityAnswerHash': securityAnswerHash,
      'securityQuestionSelected': securityQuestionSelected,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Create model from Firestore document
  factory AppUser.fromMap(String uid, Map<String, dynamic> map) {
    return AppUser(
      uid: uid,
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      authProvider: map['authProvider'] ?? 'email',
      hasAppPassword: map['hasAppPassword'] ?? true,
      securityQuestionIndex: map['securityQuestionIndex'],
      securityAnswerHash: map['securityAnswerHash'],
      securityQuestionSelected: map['securityQuestionSelected'] ?? false,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}
