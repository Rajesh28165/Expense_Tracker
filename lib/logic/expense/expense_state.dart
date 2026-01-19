import '../../data/models/expense_model.dart';

abstract class ExpenseState {}

class ExpenseInitial extends ExpenseState {}

class ExpenseLoading extends ExpenseState {}

class ExpenseLoaded extends ExpenseState {
  final List<ExpenseModel> expenses;
  final double totalExpense;

  ExpenseLoaded({
    required this.expenses,
    required this.totalExpense,
  });
}

class ExpenseError extends ExpenseState {
  final String message;
  ExpenseError(this.message);
}
