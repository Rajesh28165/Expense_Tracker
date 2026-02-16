import 'package:cloud_firestore/cloud_firestore.dart';

class IncomeModel {
  final String id;
  final String title;
  final double amount;
  final String category;
  final DateTime date;

  IncomeModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
  });

  /// Convert object to Firestore Map
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'amount': amount,
      'category': category,
      'date': Timestamp.fromDate(date),
    };
  }

  /// Create object from Firestore Map
  factory IncomeModel.fromMap(
    Map<String, dynamic> map,
    String docId,
  ) {
    return IncomeModel(
      id: docId,
      title: map['title'] ?? '',
      amount: (map['amount'] as num).toDouble(),
      category: map['category'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
    );
  }

  IncomeModel copyWith({
    String? id,
    String? title,
    double? amount,
    String? category,
    DateTime? date,
  }) {
    return IncomeModel(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
    );
  }
}
