import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/income_model.dart';

class IncomeRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> get _incomeRef {
    if (_userId == null) {
      throw Exception('User not logged in');
    }

    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('incomes'); // ✅ DIFFERENT COLLECTION
  }

  /// ADD INCOME
  Future<void> addIncome(IncomeModel income) async {
    try {
      final doc = _incomeRef.doc();

      await doc.set(
        income.copyWith(id: doc.id).toMap(),
      );
    } catch (e) {
      throw Exception('Failed to add income');
    }
  }

  /// FETCH INCOME
  Future<List<IncomeModel>> fetchIncomes() async {
    try {
      final snapshot = await _incomeRef.orderBy('date', descending: true).get();

      return snapshot.docs
          .map((doc) => IncomeModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch incomes');
    }
  }

  /// DELETE INCOME
  Future<void> deleteIncome(String id) async {
    try {
      await _incomeRef.doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete income');
    }
  }
}
