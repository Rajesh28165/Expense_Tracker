import 'package:expense_tracker/data/models/expense_model.dart';
import 'package:expense_tracker/logic/expense/expense_cubit.dart';
import 'package:expense_tracker/logic/expense/expense_state.dart';
import 'package:expense_tracker/presentation/widgets/generalComponents.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../widgets/date_filter_widget.dart';

class ExpenseTransactionPage extends StatefulWidget {
  const ExpenseTransactionPage({super.key});

  @override
  State<ExpenseTransactionPage> createState() => _ExpenseTransactionPageState();
}

class _ExpenseTransactionPageState extends State<ExpenseTransactionPage> {

  DateTime? filterStart;
  DateTime? filterEnd;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: context.customAppBar(title: "Transactions"),
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
                final filtered = _filterExpenses(state.expenses);

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [

                      DateFilterWidget(
                        onFilter: (start, end) {
                          setState(() {
                            filterStart = start;
                            filterEnd = end;
                          });
                        },
                      ),

                      const SizedBox(height: 20),

                      _transactionList(filtered),
                    ],
                  ),
                );
              }

              return const Center(child: CircularProgressIndicator());
            },
          ),
        ),
      ),
    );
  }

  // ================= FILTER LOGIC =================

  List<ExpenseModel> _filterExpenses(List<ExpenseModel> expenses) {
    if (filterStart == null && filterEnd == null) {
      return expenses;
    }

    return expenses.where((e) {
      final date = e.date;

      if (filterStart != null && date.isBefore(filterStart!)) return false;
      if (filterEnd != null && date.isAfter(filterEnd!)) return false;

      return true;
    }).toList();
  }

  // ================= TRANSACTION LIST =================

  Widget _transactionList(List<ExpenseModel> expenses) {
    if (expenses.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 60),
        child: Text(
          "No transactions found",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: expenses.length,
      itemBuilder: (_, i) {
        final e = expenses[i];

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.35),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  e.title,
                  style: const TextStyle(color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                "₹ ${e.amount.toStringAsFixed(2)}",
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
