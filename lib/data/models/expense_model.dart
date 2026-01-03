enum ExpenseType { income, expense }

class ExpenseModel {
  final String id;
  final String title;
  final double amount;
  final String category;
  final ExpenseType type;
  final DateTime date;

  ExpenseModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.type,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'category': category,
      'type': type.name,
      'date': date.toIso8601String(),
    };
  }

  factory ExpenseModel.fromMap(Map<String, dynamic> map) {
    return ExpenseModel(
      id: map['id'],
      title: map['title'],
      amount: (map['amount'] as num).toDouble(),
      category: map['category'],
      type: ExpenseType.values.firstWhere(
        (e) => e.name == map['type'],
      ),
      date: DateTime.parse(map['date']),
    );
  }
}
