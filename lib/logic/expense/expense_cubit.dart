import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/expense_model.dart';
import '../../data/repositories/expense_repository.dart';
import 'expense_state.dart';

class ExpenseCubit extends Cubit<ExpenseState> {
  final ExpenseRepository repository;

  ExpenseCubit(this.repository) : super(ExpenseInitial());

  /// Load all expenses from repository
  Future<void> loadExpenses() async {
    try {
      emit(ExpenseLoading());

      final expenses = await repository.fetchExpenses();

      final totalExpense = expenses.fold(
        0.0,
        (sum, e) => sum + e.amount,
      );

      emit(
        ExpenseLoaded(
          expenses: expenses,
          totalExpense: totalExpense,
        ),
      );
    } catch (e) {
      emit(ExpenseError(e.toString()));
    }
  }

  /// Add a new expense and refresh the list
  Future<void> addExpense(ExpenseModel expense) async {
    await repository.addExpense(expense);
    await loadExpenses();
  }
}
