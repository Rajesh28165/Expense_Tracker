import 'package:expense_tracker/data/models/income_model.dart';
import 'package:expense_tracker/logic/income/income_cubit.dart';
import 'package:expense_tracker/logic/income/income_state.dart';
import 'package:expense_tracker/presentation/widgets/generalComponents.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../widgets/date_filter_widget.dart';

class IncomeTransactionPage extends StatefulWidget {
  const IncomeTransactionPage({super.key});

  @override
  State<IncomeTransactionPage> createState() =>
      _IncomeTransactionPageState();
}

class _IncomeTransactionPageState extends State<IncomeTransactionPage> {
  DateTime? filterStart;
  DateTime? filterEnd;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: context.customAppBar(title: "Income Transactions"),
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
                final filtered = _filterIncomes(state.incomes);

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

  List<IncomeModel> _filterIncomes(List<IncomeModel> incomes) {
    if (filterStart == null && filterEnd == null) {
      return incomes;
    }

    return incomes.where((e) {
      final date = e.date;

      if (filterStart != null && date.isBefore(filterStart!)) return false;
      if (filterEnd != null && date.isAfter(filterEnd!)) return false;

      return true;
    }).toList();
  }

  // ================= TRANSACTION LIST =================

  Widget _transactionList(List<IncomeModel> incomes) {
    if (incomes.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 60),
        child: Text(
          "No income found",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: incomes.length,
      itemBuilder: (_, i) {
        final e = incomes[i];

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.35),
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
                  color: Colors.white,
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
