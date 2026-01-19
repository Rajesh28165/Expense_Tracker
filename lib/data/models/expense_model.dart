class ExpenseModel {
  final String id;
  final String title;     // note or category
  final double amount;
  final String category;
  final DateTime date;

  ExpenseModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
  });

  /// Convert object to Map for Firestore / storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'category': category,
      'date': date.toIso8601String(),
    };
  }

  /// Create object from Map
  factory ExpenseModel.fromMap(Map<String, dynamic> map) {
    return ExpenseModel(
      id: map['id'],
      title: map['title'] ?? '',
      amount: (map['amount'] as num).toDouble(),
      category: map['category'] ?? '',
      date: map['date'] != null ? DateTime.parse(map['date']) : DateTime.now(),
    );
  }
}
