import 'package:expense_tracker/util/logger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/expense_model.dart';
import '../../data/repositories/expense_repository.dart';
import 'expense_state.dart';

class ExpenseCubit extends Cubit<ExpenseState> {
  final ExpenseRepository _repository;
  final log = logger(ExpenseCubit);

  ExpenseCubit(this._repository) : super(ExpenseInitial());

  /// LOAD EXPENSES
  Future<void> loadExpenses() async {
    emit(ExpenseLoading());

    try {
      final expenses = await _repository.fetchExpenses();
      final total = _calculateTotal(expenses);

      emit(
        ExpenseLoaded(
          expenses: expenses,
          filteredExpenses: expenses, // default show all
          totalExpense: total,
        ),
      );

    } catch (e) {
      emit(const ExpenseError('Failed to load expenses'));
    }
  }

  void filterExpenses(DateTime start, DateTime end) {
    if (state is! ExpenseLoaded) return;

    final current = state as ExpenseLoaded;

    final filtered = current.expenses.where((e) {
      return e.date.isAfter(start.subtract(const Duration(seconds: 1))) &&
          e.date.isBefore(end.add(const Duration(seconds: 1)));
    }).toList();

    emit(
      ExpenseLoaded(
        expenses: current.expenses,
        filteredExpenses: filtered,
        totalExpense: _calculateTotal(filtered),
      ),
    );
  }


  void clearFilter() {
    if (state is! ExpenseLoaded) return;

    final current = state as ExpenseLoaded;

    emit(
      ExpenseLoaded(
        expenses: current.expenses,
        filteredExpenses: current.expenses,
        totalExpense: _calculateTotal(current.expenses),
      ),
    );
  }


  /// ADD EXPENSE
  Future<void> addExpense(ExpenseModel expense) async {
    try {
      await _repository.addExpense(expense);
      await loadExpenses(); // refresh list
    } catch (e) {
      emit(const ExpenseError('Failed to add expense'));
    }
  }

  /// DELETE EXPENSE
  Future<void> deleteExpense(String id) async {
    try {
      await _repository.deleteExpense(id);
      await loadExpenses();
    } catch (e) {
      emit(const ExpenseError('Failed to delete expense'));
    }
  }

  double _calculateTotal(List<ExpenseModel> expenses) {
    return expenses.fold(0.0, (sum, e) => sum + e.amount);
  }
}
