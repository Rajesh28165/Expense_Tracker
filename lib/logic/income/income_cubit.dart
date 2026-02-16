import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/income_model.dart';

import '../../data/repositories/income_repository.dart';
import 'income_state.dart';
import '../../util/logger.dart';

class IncomeCubit extends Cubit<IncomeState> {
  final IncomeRepository _repository;
  final log = logger(IncomeCubit);

  IncomeCubit(this._repository) : super(IncomeInitial());

  /// LOAD INCOMES
  Future<void> loadIncomes() async {
    emit(IncomeLoading());

    try {
      final incomes = await _repository.fetchIncomes();
      final total = _calculateTotal(incomes);

      emit(
        IncomeLoaded(
          incomes: incomes,
          filteredIncomes: incomes,
          totalIncome: total,
        ),
      );
    } catch (e) {
      emit(const IncomeError('Failed to load incomes'));
    }
  }

  /// FILTER INCOME
  void filterIncomes(DateTime start, DateTime end) {
    if (state is! IncomeLoaded) return;

    final current = state as IncomeLoaded;

    final filtered = current.incomes.where((i) {
      return i.date.isAfter(start.subtract(const Duration(seconds: 1))) &&
          i.date.isBefore(end.add(const Duration(seconds: 1)));
    }).toList();

    emit(
      IncomeLoaded(
        incomes: current.incomes,
        filteredIncomes: filtered,
        totalIncome: _calculateTotal(filtered),
      ),
    );
  }

  /// CLEAR FILTER
  void clearFilter() {
    if (state is! IncomeLoaded) return;

    final current = state as IncomeLoaded;

    emit(
      IncomeLoaded(
        incomes: current.incomes,
        filteredIncomes: current.incomes,
        totalIncome: _calculateTotal(current.incomes),
      ),
    );
  }

  /// ADD INCOME
  Future<void> addIncome(IncomeModel income) async {
    try {
      await _repository.addIncome(income);
      await loadIncomes();
    } catch (e) {
      emit(const IncomeError('Failed to add income'));
    }
  }

  /// DELETE INCOME
  Future<void> deleteIncome(String id) async {
    try {
      await _repository.deleteIncome(id);
      await loadIncomes();
    } catch (e) {
      emit(const IncomeError('Failed to delete income'));
    }
  }

  double _calculateTotal(List<IncomeModel> incomes) {
    return incomes.fold(0.0, (sum, i) => sum + i.amount);
  }
}
