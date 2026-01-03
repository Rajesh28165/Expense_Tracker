import 'package:expense_tracker/data/models/expense_model.dart';

abstract class ExpenseState {}

class ExpenseInitial extends ExpenseState {}

class ExpenseLoading extends ExpenseState {}

class ExpenseLoaded extends ExpenseState {
  final List<ExpenseModel> expenses;
  final double totalIncome;
  final double totalExpense;

  ExpenseLoaded({
    required this.expenses,
    required this.totalIncome,
    required this.totalExpense,
  });
}

class ExpenseError extends ExpenseState {
  final String message;
  ExpenseError(this.message);
}
