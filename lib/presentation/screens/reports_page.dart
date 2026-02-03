import 'package:expense_tracker/constants/extension.dart';
import 'package:expense_tracker/data/models/expense_model.dart';
import 'package:expense_tracker/logic/expense/expense_cubit.dart';
import 'package:expense_tracker/logic/expense/expense_state.dart';
import 'package:expense_tracker/presentation/widgets/generalComponents.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../constants/app_constants.dart';
import '../../util/colors.dart';
import '../widgets/pie_chart.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  DateTime? selectedMonth;

  final List<String> monthName = [
    'Jan','Feb','Mar','Apr','May','Jun',
    'Jul','Aug','Sep','Oct','Nov','Dec'
  ];

  Future<void> _pickMonth(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedMonth ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      helpText: "Select Month",
    );

    if (date != null) {
      setState(() => selectedMonth = date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          context.imageContainer(
            imagePath: ImagePathConstants.space,
            height: context.getPercentHeight(100),
          ),
          SafeArea(
            child: BlocBuilder<ExpenseCubit, ExpenseState>(
              builder: (context, state) {
                if (state is ExpenseLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (state is ExpenseError) {
                  return Center(
                    child: Text(
                      state.message,
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                if (state is ExpenseLoaded) {
                  final filteredExpenses = _filterExpensesByMonth(state.expenses);

                  final categoryData = _calculateCategoryTotals(filteredExpenses);

                  final totalExpense = categoryData.values.fold(0.0, (a, b) => a + b);

                  return SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.getPercentWidth(6),
                      vertical: context.getPercentHeight(3),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _header(context),
                        SizedBox(height: context.getPercentHeight(3)),
                        _monthSelector(context),
                        SizedBox(height: context.getPercentHeight(4)),
                        _summaryCard(totalExpense),
                        SizedBox(height: context.getPercentHeight(4)),
                        ExpensePieChart(categoryData: categoryData),
                        SizedBox(height: context.getPercentHeight(4)),
                        _categoryList(categoryData),
                      ],
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        context.header(title: "Reports", color: Colors.cyan),
      ],
    );
  }

  Widget _monthSelector(BuildContext context) {
    return InkWell(
      onTap: () => _pickMonth(context),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Selected Month", style: TextStyle(color: Colors.white70)),
            Text(
              selectedMonth == null
                ? "All Time"
                : "${monthName[selectedMonth!.month - 1]} ${selectedMonth!.year}",
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryCard(double totalExpense) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Total Expense", style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 8),
          Text(
            "₹ ${totalExpense.toStringAsFixed(2)}",
            style: const TextStyle(
              color: Colors.cyan,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryList(Map<String, double> categoryData) {
    if (categoryData.isEmpty) {
      return const Text(
        "No data available",
        style: TextStyle(color: Colors.white70),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Category Breakdown",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        ...categoryData.entries.map((entry) {
          final color = CategoryColorHelper.getColor(entry.key);

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(entry.key, style: const TextStyle(color: Colors.white)),
                Text(
                  "₹ ${entry.value.toStringAsFixed(0)}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  List<ExpenseModel> _filterExpensesByMonth(List<ExpenseModel> expenses) {
    if (selectedMonth == null) return expenses;

    return expenses.where((e) =>
      e.date.month == selectedMonth!.month &&
      e.date.year == selectedMonth!.year).toList();
  }

  Map<String, double> _calculateCategoryTotals(List<ExpenseModel> expenses) {
    final Map<String, double> data = {};

    for (final e in expenses) {
      data.update(e.category, (v) => v + e.amount,
        ifAbsent: () => e.amount);
    }
    return data;
  }
}
