import 'package:expense_tracker/constants/app_constants.dart';
import 'package:expense_tracker/constants/extension.dart';
import 'package:expense_tracker/logic/expense/expense_cubit.dart';
import 'package:expense_tracker/logic/expense/expense_state.dart';
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
import 'show_txn_page.dart';


class TransactionReportPage extends StatefulWidget {
  final TransactionType type;

  const TransactionReportPage({super.key, required this.type});

  @override
  State<TransactionReportPage> createState() => _TransactionReportPageState();
}

class _TransactionReportPageState extends State<TransactionReportPage> {

  bool get isExpense => widget.type == TransactionType.expense;

  String get title => isExpense ? "Expense Reports" : "Income Reports";

  String get breakdownTitle => isExpense ? "Category Breakdown" : "Income Breakdown";

  String get totalLabel => isExpense ? "Total Expense" : "Total Income";

  // =================== BUILD ===================

  @override
  Widget build(BuildContext context) {
    return isExpense
    ? BlocListener<ExpenseCubit, ExpenseState>(
        listener: _expenseListener,
        child: _body(),
      )
    : BlocListener<IncomeCubit, IncomeState>(
        listener: _incomeListener,
        child: _body(),
      );
  }


  Widget _body() {
    return WillPopScope(
      onWillPop: () async {
        context.go(RouteName.dashboard);
        return false;
      },
      child: Scaffold(
        appBar: context.customAppBar(
          title: title,
          onBackPressed: () => context.go(RouteName.dashboard),
        ),
        body: context.gradientScreen(
          colors: const [
            Color(0xFFF5F7FA),
            Color(0xFFB8D8FF),
            Color(0xFF4A90E2),
          ],
          child: SafeArea(
            child: isExpense ? _expenseBuilder() : _incomeBuilder(),
          ),
        ),
      ),
    );
  }
  // ================= EXPENSE BUILDER =================

  void _expenseListener(BuildContext context, ExpenseState state) {
    if (state is ExpenseLoading) {
      context.showLoader(text: "Loading ...");
    }

    if (state is ExpenseLoaded || state is ExpenseError) {
      context.hideLoader(context);
    }

    if (state is ExpenseError) {
      context.showCustomDialog(description: state.message);
    }
  }

  Widget _expenseBuilder() {
    return BlocBuilder<ExpenseCubit, ExpenseState>(
      builder: (context, state) {
        if (state is ExpenseLoaded) {
          final data = _calculateTotals(state.filteredExpenses);

          return _buildUI(context, data);
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  // ================= INCOME BUILDER =================

  void _incomeListener(BuildContext context, IncomeState state) {
    if (state is IncomeLoading) {
      context.showLoader(text: "Loading report");
    }

    if (state is IncomeLoaded || state is IncomeError) {
      context.hideLoader(context);
    }

    if (state is IncomeError) {
      context.showCustomDialog(description: state.message);
    }
  }

  Widget _incomeBuilder() {
    return BlocBuilder<IncomeCubit, IncomeState>(
      builder: (context, state) {
        if (state is IncomeLoaded) {
          final data = _calculateTotals(state.filteredIncomes);
          return _buildUI(context, data);
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  // ================= COMMON UI =================

  Widget _buildUI(BuildContext context, Map<String, double> categoryData) {
    final total = categoryData.values.fold(0.0, (a, b) => a + b);

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: context.getPercentWidth(3),
        vertical: context.getPercentHeight(1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// DATE FILTER
          DateFilterWidget(
            onFilter: (start, end) {
              if (isExpense) {
                final cubit = context.read<ExpenseCubit>();
                start == null || end == null
                  ? cubit.clearFilter()
                  : cubit.filterExpenses(start, end);
              } else {
                final cubit = context.read<IncomeCubit>();
                start == null || end == null
                  ? cubit.clearFilter()
                  : cubit.filterIncomes(start, end);
              }
            },
          ),

          SizedBox(height: context.getPercentHeight(2)),

          /// TOTAL BOX
          context.shadowBox(
            header: totalLabel,
            text: "₹ ${total.toStringAsFixed(2)}",
            width: 100,
            height: 12,
          ),

          SizedBox(height: context.getPercentHeight(4)),

          /// PIE CHART
          CustomPieChart(categoryData: categoryData),

          SizedBox(height: context.getPercentHeight(4)),

          _categoryList(categoryData),
        ],
      ),
    );
  }

  // ================= CATEGORY LIST =================

  Widget _categoryList(Map<String, double> data) {
    if (data.isEmpty) {
      return const Center(
        child: Text(
          "No data found",
          style: TextStyle(
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
        Text(
          breakdownTitle,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        ...data.entries.map((entry) {
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

  // ================= CALCULATE TOTAL =================

  Map<String, double> _calculateTotals(List<dynamic> items) {
    final Map<String, double> data = {};

    for (final e in items) {
      data.update(
        e.category,
        (v) => v + e.amount,
        ifAbsent: () => e.amount,
      );
    }

    return data;
  }
}