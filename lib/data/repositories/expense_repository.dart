import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/expense_model.dart';

class ExpenseRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> get _expenseRef {
    if (_userId == null) {
      throw Exception('User not logged in');
    }
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('expenses');
  }

  /// ADD
  Future<void> addExpense(ExpenseModel expense) async {
    try {
      final doc = _expenseRef.doc();
      await doc.set(
        expense.copyWith(id: doc.id).toMap(),
      );
    } catch (e) {
      throw Exception('Failed to add expense');
    }
  }

  /// FETCH
  Future<List<ExpenseModel>> fetchExpenses() async {
    try {
      final snapshot = await _expenseRef.orderBy('date', descending: true).get();

      return snapshot.docs
        .map(
          (doc) => ExpenseModel.fromMap(doc.data(), doc.id),
        ).toList();
    } catch (e) {
      throw Exception('Failed to fetch expenses');
    }
  }

  /// DELETE
  Future<void> deleteExpense(String id) async {
    try {
      await _expenseRef.doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete expense');
    }
  }
}
