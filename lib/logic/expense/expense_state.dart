import 'package:equatable/equatable.dart';
import '../../data/models/expense_model.dart';

abstract class ExpenseState extends Equatable {
  const ExpenseState();

  @override
  List<Object?> get props => [];
}

class ExpenseInitial extends ExpenseState {}

class ExpenseLoading extends ExpenseState {}

class ExpenseLoaded extends ExpenseState {
  final List<ExpenseModel> expenses;        // original list
  final List<ExpenseModel> filteredExpenses; // filtered list
  final double totalExpense;

  const ExpenseLoaded({
    required this.expenses,
    required this.filteredExpenses,
    required this.totalExpense,
  });

  @override
  List<Object?> get props => [expenses, filteredExpenses, totalExpense];
}

class ExpenseError extends ExpenseState {
  final String message;

  const ExpenseError(this.message);

  @override
  List<Object?> get props => [message];
}
