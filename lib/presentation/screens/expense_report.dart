import 'package:expense_tracker/constants/app_constants.dart';
import 'package:expense_tracker/constants/extension.dart';
import 'package:expense_tracker/data/models/expense_model.dart';
import 'package:expense_tracker/logic/expense/expense_cubit.dart';
import 'package:expense_tracker/logic/expense/expense_state.dart';
import 'package:expense_tracker/presentation/widgets/generalComponents.dart';
import 'package:expense_tracker/router/route_name.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../util/colors.dart';
import '../widgets/date_filter_widget.dart';
import '../widgets/pie_chart.dart';

class ExpenseReport extends StatefulWidget {
  const ExpenseReport({super.key});

  @override
  State<ExpenseReport> createState() => _ExpenseReportState();
}

class _ExpenseReportState extends State<ExpenseReport> {

  @override
  Widget build(BuildContext context) {
    return BlocListener<ExpenseCubit, ExpenseState>(
      listener: (context, state) {
        if (state is ExpenseLoading) {
          context.showLoader(text: 'Loading report');
        }
        if (state is ExpenseLoaded || state is ExpenseError) {
          context.hideLoader(context);
        }

        if (state is ExpenseError) {
          context.showCustomDialog(description: state.message);
        }
      },
      child: WillPopScope(
        onWillPop: () async {
          context.go(RouteName.dashboard);
          return false;
        },
        child: Scaffold(
          appBar: context.customAppBar(
            title: 'Reports',
            onBackPressed: () => context.go(RouteName.dashboard)
          ),
          body: context.gradientScreen(
            colors: const [
              Color(0xFFF5F7FA),
              Color(0xFFB8D8FF),
              Color(0xFF4A90E2),
            ],
            child: SafeArea(
              child: BlocBuilder<ExpenseCubit, ExpenseState>(
                builder: (context, state) {
                  if (state is ExpenseLoaded) {

                    final filteredExpenses = state.filteredExpenses;
                    final categoryData = _calculateCategoryTotals(filteredExpenses);

                    final totalExpense = categoryData.values
                        .fold(0.0, (a, b) => a + b);

                    return Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            padding: EdgeInsets.symmetric(
                              horizontal: context.getPercentWidth(3),
                              vertical: context.getPercentHeight(3),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                /// ✅ REUSABLE FILTER
                                DateFilterWidget(
                                  onFilter: (start, end) {
                                    final cubit = context.read<ExpenseCubit>();
                                    if (start == null || end == null) {
                                      cubit.clearFilter();
                                    } else {
                                      cubit.filterExpenses(start, end);
                                    }
                                  },
                                ),

                                SizedBox(height: context.getPercentHeight(4)),

                                context.shadowBox(
                                  header: "Total Expense",
                                  text: "₹ ${totalExpense.toStringAsFixed(2)}",
                                  width: 100,
                                  height: 12
                                ),

                                SizedBox(height: context.getPercentHeight(4)),

                                ExpensePieChart(categoryData: categoryData),

                                SizedBox(height: context.getPercentHeight(4)),

                                _categoryList(categoryData),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  }

                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _categoryList(Map<String, double> categoryData) {
    if (categoryData.isEmpty) {
      return const Center(
        child: Text(
          "No expenses found for selected filter",
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontFamily: AppConstants.PlayfairDisplay,
            fontWeight: FontWeight.bold
          ),
        ),
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
                Text(
                  entry.key,
                  style: const TextStyle(color: Colors.white)
                ),
                Text(
                  "₹ ${entry.value.toStringAsFixed(0)}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Map<String, double> _calculateCategoryTotals(
    List<ExpenseModel> expenses
  ) {
    final Map<String, double> data = {};

    for (final e in expenses) {
      data.update(
        e.category, 
        (v) => v + e.amount,
        ifAbsent: () => e.amount
      );
    }
    return data;
  }
}
