import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kharchasutra/data/models/txn_model.dart';

class ExpenseModel implements TransactionModel {
  final String id;
  final String title;
  final double amount;
  final String category;
  final DateTime date;
  final String? customCategory;

  ExpenseModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    this.customCategory
  });

  /// Convert object to Firestore Map
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'amount': amount,
      'category': category,
      'date': Timestamp.fromDate(date),
      'customCategory': customCategory,
    };
  }

  /// Create object from Firestore Map
  factory ExpenseModel.fromMap(
    Map<String, dynamic> map,
    String docId,
  ) {
    return ExpenseModel(
      id: docId,
      title: map['title'] ?? '',
      amount: (map['amount'] as num).toDouble(),
      category: map['category'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      customCategory: map['customCategory'],
    );
  }

  ExpenseModel copyWith({
    String? id,
    String? title,
    double? amount,
    String? category,
    DateTime? date,
    String? customCategory,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      customCategory: customCategory ?? this.customCategory,
    );
  }
}
