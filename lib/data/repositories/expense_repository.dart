import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/expense_model.dart';

class ExpenseRepository {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get _userId => _auth.currentUser!.uid;

  CollectionReference get _expenseRef =>
      _firestore.collection('users').doc(_userId).collection('expenses');

  /// ADD
  Future<void> addExpense(ExpenseModel expense) async {
    await _expenseRef.doc(expense.id).set(expense.toMap());
  }

  /// FETCH
  Future<List<ExpenseModel>> fetchExpenses() async {
    final snapshot = await _expenseRef.orderBy('date', descending: true).get();

    return snapshot.docs
        .map((doc) => ExpenseModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  /// DELETE (optional)
  Future<void> deleteExpense(String id) async {
    await _expenseRef.doc(id).delete();
  }
}
