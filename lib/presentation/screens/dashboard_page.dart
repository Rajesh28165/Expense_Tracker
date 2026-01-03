import 'package:expense_tracker/constants/entension.dart';
import 'package:expense_tracker/logic/auth/auth_cubit.dart';
import 'package:expense_tracker/presentation/widgets/generalComponents.dart';
import 'package:expense_tracker/router/route_name.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../constants/app_constants.dart';
import '../../data/models/expense_model.dart';
import '../../logic/expense/expense_cubit.dart';
import '../../logic/expense/expense_state.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Stack(
          children: [
            context.imageContainer(
              imagePath: ImagePathConstants.shultter,
              height: context.getPercentHeight(100),
            ),
            SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: context.getPercentWidth(6),
                  vertical: context.getPercentHeight(2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _header(context),
                    SizedBox(height: context.getPercentHeight(4)),
                    _balanceCard(context),
                    SizedBox(height: context.getPercentHeight(4)),
                    _incomeExpenseRow(context),
                    SizedBox(height: context.getPercentHeight(4)),
                    _quickActions(context),
                    SizedBox(height: context.getPercentHeight(4)),
                    _recentTransactions(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= STYLES =================
  static const _titleStyle = TextStyle(
    color: Colors.white70,
    fontSize: 16,
  );

  static const _amountStyle = TextStyle(
    color: Colors.white,
    fontSize: 22,
    fontWeight: FontWeight.bold,
  );

  static const _largeAmountStyle = TextStyle(
    color: Colors.white,
    fontSize: 32,
    fontWeight: FontWeight.bold,
  );

  static const _sectionHeaderStyle = TextStyle(
    color: Colors.white,
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  // ================= HEADER =================
  Widget _header(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        context.header(
          title: "Dashboard",
          color: Colors.cyan,
        ),
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.white),
          onPressed: () {
            context.read<AuthCubit>().logout();
            context.pushNamedUnAuthenticated(RouteName.login);
          },
        ),
      ],
    );
  }

  // ================= REUSABLE CARD =================
  Widget _buildCard({
    required String title,
    required String amount,
    double? height,
    double? width,
    Color? backgroundColor,
    Gradient? gradient,
    TextStyle? amountStyle,
  }) {
    return Container(
      height: height,
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: gradient == null ? backgroundColor : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: _titleStyle),
          const SizedBox(height: 8),
          Text(
            amount,
            style: amountStyle ?? _amountStyle,
          ),
        ],
      ),
    );
  }

  // ================= BALANCE =================
  Widget _balanceCard(BuildContext context) {
    return BlocBuilder<ExpenseCubit, ExpenseState>(
      builder: (context, state) {
        if (state is ExpenseLoaded) {
          final balance = state.totalIncome - state.totalExpense;
          return _buildCard(
            title: "Total Balance",
            amount: "₹ ${balance.toStringAsFixed(0)}",
            height: 100,
            width: context.getPercentWidth(90),
            gradient: const LinearGradient(
              colors: [Colors.blueAccent, Colors.cyan],
            ),
            amountStyle: _largeAmountStyle,
          );
        }
        return const SizedBox();
      },
    );
  }

  // ================= INCOME / EXPENSE =================
  Widget _incomeExpenseRow(BuildContext context) {
    return BlocBuilder<ExpenseCubit, ExpenseState>(
      builder: (context, state) {
        if (state is ExpenseLoaded) {
          return Row(
            children: [
              Expanded(
                child: _buildCard(
                  title: "Income",
                  amount: "₹ ${state.totalIncome}",
                  height: 85,
                  backgroundColor: Colors.green.withOpacity(0.85),
                ),
              ),
              SizedBox(width: context.getPercentWidth(4)),
              Expanded(
                child: _buildCard(
                  title: "Expense",
                  amount: "₹ ${state.totalExpense}",
                  height: 85,
                  backgroundColor: Colors.redAccent.withOpacity(0.85),
                ),
              ),
            ],
          );
        }
        return const SizedBox();
      },
    );
  }

  // ================= QUICK ACTIONS =================
  Widget _quickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Quick Actions", style: _sectionHeaderStyle),
        const SizedBox(height: 12),
        Row(
          children: [
            _actionButton(
              icon: Icons.add,
              label: "Add Expense",
              onTap: () => context.pushNamed(RouteName.addExpense),
            ),
            SizedBox(width: context.getPercentWidth(4)),
            _actionButton(
              icon: Icons.bar_chart,
              label: "Reports",
              onTap: () => context.pushNamed(RouteName.report),
            ),
          ],
        ),
      ],
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white24),
          ),
          child: Column(
            children: [
              Icon(icon, color: Colors.cyan, size: 28),
              const SizedBox(height: 8),
              Text(label, style: const TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }

  // ================= RECENT TRANSACTIONS =================
  Widget _recentTransactions() {
    return BlocBuilder<ExpenseCubit, ExpenseState>(
      builder: (context, state) {
        if (state is ExpenseLoaded && state.expenses.isNotEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Recent Transactions", style: _sectionHeaderStyle),
              const SizedBox(height: 12),
              ...state.expenses.take(5).map((e) {
                return _transactionTile(
                  e.title,
                  "${e.type == ExpenseType.expense ? '-' : '+'} ₹${e.amount}",
                  e.type == ExpenseType.expense ? Colors.red : Colors.green,
                );
              }),
            ],
          );
        }
        return const SizedBox();
      },
    );
  }


  Widget _transactionTile(String title, String amount, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.white)),
          Text(
            amount,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
