import 'package:expense_tracker/constants/app_constants.dart';
import 'package:expense_tracker/constants/extension.dart';
import 'package:expense_tracker/data/models/income_model.dart';
import 'package:expense_tracker/logic/income/income_cubit.dart';
import 'package:expense_tracker/logic/income/income_state.dart';
import 'package:expense_tracker/presentation/widgets/generalComponents.dart';
import 'package:expense_tracker/router/route_name.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../util/colors.dart';
import '../widgets/date_filter_widget.dart';
import '../widgets/pie_chart.dart';

class IncomeReport extends StatefulWidget {
  const IncomeReport({super.key});

  @override
  State<IncomeReport> createState() => _IncomeReportState();
}

class _IncomeReportState extends State<IncomeReport> {
  @override
  Widget build(BuildContext context) {
    return BlocListener<IncomeCubit, IncomeState>(
      listener: (context, state) {
        if (state is IncomeLoading) {
          context.showLoader(text: 'Loading report');
        }
        if (state is IncomeLoaded || state is IncomeError) {
          context.hideLoader(context);
        }

        if (state is IncomeError) {
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
            title: 'Income Reports',
            onBackPressed: () => context.go(RouteName.dashboard),
          ),
          body: context.gradientScreen(
            colors: const [
              Color(0xFFF5F7FA),
              Color(0xFFB8D8FF),
              Color(0xFF4A90E2),
            ],
            child: SafeArea(
              child: BlocBuilder<IncomeCubit, IncomeState>(
                builder: (context, state) {
                  if (state is IncomeLoaded) {
                    final filteredIncomes = state.filteredIncomes;
                    final categoryData =
                        _calculateCategoryTotals(filteredIncomes);

                    final totalIncome = categoryData.values
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
                                /// FILTER
                                DateFilterWidget(
                                  onFilter: (start, end) {
                                    final cubit =
                                        context.read<IncomeCubit>();

                                    if (start == null || end == null) {
                                      cubit.clearFilter();
                                    } else {
                                      cubit.filterIncomes(start, end);
                                    }
                                  },
                                ),

                                SizedBox(
                                    height: context.getPercentHeight(4)),

                                context.shadowBox(
                                  header: "Total Income",
                                  text:
                                      "₹ ${totalIncome.toStringAsFixed(2)}",
                                  width: 100,
                                  height: 12,
                                ),

                                SizedBox(
                                    height: context.getPercentHeight(4)),

                                /// SAME PIE CHART WIDGET CAN BE USED
                                ExpensePieChart(
                                    categoryData: categoryData),

                                SizedBox(
                                    height: context.getPercentHeight(4)),

                                _categoryList(categoryData),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  }

                  return const Center(
                      child: CircularProgressIndicator());
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ================= CATEGORY LIST =================

  Widget _categoryList(Map<String, double> categoryData) {
    if (categoryData.isEmpty) {
      return const Center(
        child: Text(
          "No income found for selected filter",
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontFamily: AppConstants.PlayfairDisplay,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Income Breakdown",
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
                Text(entry.key,
                    style: const TextStyle(color: Colors.white)),
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

  // ================= CATEGORY TOTAL CALC =================

  Map<String, double> _calculateCategoryTotals(
      List<IncomeModel> incomes) {
    final Map<String, double> data = {};

    for (final e in incomes) {
      data.update(
        e.category,
        (v) => v + e.amount,
        ifAbsent: () => e.amount,
      );
    }
    return data;
  }
}
