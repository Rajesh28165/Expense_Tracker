import 'package:expense_tracker/constants/entension.dart';
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

                if (state is ExpenseLoaded) {
                  final filteredExpenses = _filterExpensesByMonth(state.expenses);
                  final categoryData = _calculateCategoryTotals(filteredExpenses);
                  final totalExpense = categoryData.values.fold(
                    0.0,
                    (sum, item) => sum + item,
                  );

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

                        /// PIE CHART
                        ExpensePieChart(categoryData: categoryData),

                        SizedBox(height: context.getPercentHeight(4)),

                        /// CATEGORY LIST (NO PROGRESS BAR)
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

  // ================= HEADER =================
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

  // ================= MONTH =================
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
            const Text(
              "Selected Month",
              style: TextStyle(color: Colors.white70),
            ),
            Text(
              selectedMonth == null
                  ? "All Time"
                  : "${selectedMonth!.month}-${selectedMonth!.year}",
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }


  // ================= SUMMARY =================
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
          const Text(
            "Total Expense",
            style: TextStyle(color: Colors.white70),
          ),
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

  // ================= CATEGORY LIST =================
  Widget _categoryReport(
    Map<String, double> categoryData,
    double totalExpense,
  ) {
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
          final percent = totalExpense == 0 ? 0 : (entry.value / totalExpense);

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      entry.key,
                      style: const TextStyle(color: Colors.white),
                    ),
                    Text(
                      "₹ ${entry.value.toStringAsFixed(0)}",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  value: percent.toDouble(),
                  backgroundColor: Colors.white24,
                  valueColor: const AlwaysStoppedAnimation(Colors.cyan),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _categoryList(Map<String, double> categoryData) {
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
                Row(
                  children: [
                    const SizedBox(width: 10),
                    Text(
                      entry.key,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
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


  // ================= HELPERS =================
  List<ExpenseModel> _filterExpensesByMonth(List<ExpenseModel> expenses) {
    if (selectedMonth == null) {
      return expenses.where(
        (e) => e.type == ExpenseType.expense,
      ).toList();
    }

    return expenses.where((expense) {
      return expense.date.month == selectedMonth!.month &&
        expense.date.year == selectedMonth!.year &&
        expense.type == ExpenseType.expense;
    }).toList();
  }


  Map<String, double> _calculateCategoryTotals(List<ExpenseModel> expenses) {
    final Map<String, double> data = {};

    for (final expense in expenses) {
      data.update(
        expense.category,
        (value) => value + expense.amount,
        ifAbsent: () => expense.amount,
      );
    }

    return data;
  }
}
