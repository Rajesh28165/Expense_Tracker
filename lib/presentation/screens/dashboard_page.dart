import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/constants/entension.dart';
import 'package:expense_tracker/logic/auth/auth_cubit.dart';
import 'package:expense_tracker/presentation/widgets/generalComponents.dart';
import 'package:expense_tracker/router/route_name.dart';
import 'package:expense_tracker/util/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../logic/expense/expense_cubit.dart';
import '../../logic/expense/expense_state.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: context.customAppBar(title: 'Dashboard'),
        body: Stack(
          children: [
            SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: context.getPercentWidth(6),
                  vertical: context.getPercentHeight(2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // _header(context),
                    SizedBox(height: context.getPercentHeight(4)),

                    _userSummary(context),
                    SizedBox(height: context.getPercentHeight(3)),

                    _quickActions(context),
                    SizedBox(height: context.getPercentHeight(5)),
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

  // ================= HEADER =================
  Widget _header(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            context.header(
              title: "Dashboard",
              color: Colors.cyan,
            ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.logout, color: WidgetColors.black),
          onPressed: () {
            context.read<AuthCubit>().logout();
            context.pushNamedUnAuthenticated(RouteName.login);
          },
        ),
      ],
    );
  }

  // ================= USER SUMMARY =================
  Widget _userSummary(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) return const SizedBox();

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox();
        }

        final data = snapshot.data?.data() as Map<String, dynamic>;
        final firstName = data['firstName'] ?? '';
        final lastName = data['lastName'] ?? '';
        final fullName = "$firstName $lastName";

        return BlocBuilder<ExpenseCubit, ExpenseState>(
          builder: (context, state) {
            final totalExpense = state is ExpenseLoaded ? state.totalExpense : 0;

            return Column(
              children: [
                context.shadowBox(
                  width: 85,
                  height: 12,
                  textColor: Colors.black,
                  text: 'Hey $firstName welcome to your money management system ',
                  fontStyle: FontStyle.italic,
                ),
                SizedBox(height: context.getPercentHeight(4)),
                context.shadowBox(
                  width: 85,
                  height: 15,
                  header: 'Your total expenses',
                  textColor: Colors.black,
                  text: "₹ $totalExpense",
                  fontStyle: FontStyle.normal,
                  gradient: LinearGradient(
                    colors: [
                      Colors.blueAccent.shade100,
                      Colors.pinkAccent.shade100,
                      Colors.orangeAccent.shade100,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ================= QUICK ACTIONS =================
  Widget _quickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Quick Actions",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
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
              const Text(
                "Recent Expenses",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ...state.expenses.take(5).map((e) {
                return _transactionTile(
                  e.title,
                  "💸 ₹${e.amount.toStringAsFixed(2)}",
                  Colors.redAccent.shade400,
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
        color: Colors.black.withOpacity(0.35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

}
