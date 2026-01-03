import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/expense_model.dart';
import '../../data/repositories/expense_repository.dart';
import 'expense_state.dart';

class ExpenseCubit extends Cubit<ExpenseState> {
  final ExpenseRepository repository;

  ExpenseCubit(this.repository) : super(ExpenseInitial());

  Future<void> loadExpenses() async {
    try {
      emit(ExpenseLoading());

      final expenses = await repository.fetchExpenses();

      final totalIncome = expenses
          .where((e) => e.type == ExpenseType.income)
          .fold(0.0, (sum, e) => sum + e.amount);

      final totalExpense = expenses
          .where((e) => e.type == ExpenseType.expense)
          .fold(0.0, (sum, e) => sum + e.amount);

      emit(
        ExpenseLoaded(
          expenses: expenses,
          totalIncome: totalIncome,
          totalExpense: totalExpense,
        ),
      );
    } catch (e) {
      emit(ExpenseError(e.toString()));
    }
  }

  Future<void> addExpense(ExpenseModel expense) async {
    await repository.addExpense(expense);
    await loadExpenses(); // refresh UI
  }
}
