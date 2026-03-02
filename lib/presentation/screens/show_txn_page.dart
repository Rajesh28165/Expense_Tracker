import 'package:expense_tracker/constants/extension.dart';
import 'package:expense_tracker/logic/expense/expense_cubit.dart';
import 'package:expense_tracker/logic/expense/expense_state.dart';
import 'package:expense_tracker/logic/income/income_cubit.dart';
import 'package:expense_tracker/logic/income/income_state.dart';
import 'package:expense_tracker/presentation/widgets/generalComponents.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';

import '../../data/models/txn_model.dart';
import '../widgets/date_filter_widget.dart';
import '../widgets/showBottomModel.dart';

enum TransactionType { income, expense }

class ShowTransactionPage extends StatefulWidget {
  final TransactionType type;

  const ShowTransactionPage({super.key, required this.type});

  @override
  State<ShowTransactionPage> createState() => _ShowTransactionPageState();
}

class _ShowTransactionPageState extends State<ShowTransactionPage> {
  DateTime? filterStart;
  DateTime? filterEnd;
  bool isFiltering = false;

  String get title =>
      widget.type == TransactionType.income
        ? "Income Transactions"
        : "Expense Transactions";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: context.customAppBar(title: title, fontSize: 25),
      body: context.gradientScreen(
        colors: const [
          Color(0xFFF5F7FA),
          Color(0xFFB8D8FF),
          Color(0xFF4A90E2),
        ],
        child: SafeArea(
          child: widget.type == TransactionType.income
            ? _buildIncomeBloc()
            : _buildExpenseBloc(),
        ),
      ),
    );
  }

  // ================= INCOME =================

  Widget _buildIncomeBloc() {
    return BlocBuilder<IncomeCubit, IncomeState>(
      builder: (context, state) {
        if (state is IncomeLoaded) {
          return _buildContent(state.incomes);
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  // ================= EXPENSE =================

  Widget _buildExpenseBloc() {
    return BlocBuilder<ExpenseCubit, ExpenseState>(
      builder: (context, state) {
        if (state is ExpenseLoaded) {
          return _buildContent(state.expenses);
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  // ================= COMMON CONTENT =================

  Widget _buildContent(List<TransactionModel> data) {
    final filtered = _getSortedFilteredList(data);

    return Stack(
      children: [
        Column(
          children: [
            DateFilterWidget(
              onFilter: (start, end) async {
                setState(() => isFiltering = true);
                await Future.delayed(const Duration(seconds: 1));
                setState(() {
                  filterStart = start;
                  filterEnd = end;
                  isFiltering = false;
                });
              },
            ),
            SizedBox(height: context.getPercentHeight(2)),
            Expanded(child: _transactionList(filtered)),
          ],
        ),

        if (isFiltering)
          const Center(
            child: SpinKitThreeBounce(
              color: Colors.blue,
              size: 50,
            ),
          ),
      ],
    );
  }

  // ================= FILTER + SORT =================

  List<TransactionModel> _getSortedFilteredList(
      List<TransactionModel> list) {
    List<TransactionModel> filtered = list;

    if (filterStart != null || filterEnd != null) {
      filtered = list.where((e) {
        final date = e.date;

        if (filterStart != null && date.isBefore(filterStart!)) return false;
        if (filterEnd != null &&
            date.isAfter(filterEnd!.add(const Duration(days: 1)))) {
          return false;
        }

        return true;
      }).toList();
    }

    filtered.sort((a, b) => b.date.compareTo(a.date));
    return filtered;
  }

  // ================= TABLE =================

  Widget _transactionList(List<TransactionModel> list) {
    if (list.isEmpty) {
      return const Center(
        child: Text(
          "No data found",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      );
    }

    return Column(
      children: [
        Container(
          color: Colors.blueGrey.shade800,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            children: const [
              Expanded(
                child: Text(
                  "Category",
                  style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold)
                )
              ),
              Expanded(
                child: Text(
                  "Amount(₹)",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,fontWeight: FontWeight.bold)
                  )
                ),
              Expanded(
                child: Text(
                  "Date",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold)
                )
              ),
            ],
          ),
        ),

        Expanded(
          child: ListView.builder(
            itemCount: list.length,
            itemBuilder: (_, i) {
              final e = list[i];

              return InkWell(
                onTap: () => ShowBottomModel.open(context, e),
                child: Padding(
                  padding:
                  const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(child: Text(e.category)),
                      Expanded(
                        child: Text(
                          e.amount.toStringAsFixed(2),
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          DateFormat("dd-MMM-yyyy").format(e.date),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}