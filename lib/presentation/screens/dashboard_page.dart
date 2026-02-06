import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/constants/extension.dart';
import 'package:expense_tracker/presentation/widgets/generalComponents.dart';
import 'package:expense_tracker/router/route_name.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../logic/auth/auth_cubit.dart';
import '../../logic/expense/expense_cubit.dart';
import '../../logic/expense/expense_state.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    _loadUser();
    context.read<ExpenseCubit>().loadExpenses();
  }

  Future<void> _loadUser() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (mounted) {
      setState(() => userData = doc.data());
    }
  }

  bool isGoogleUser() {
    final user = FirebaseAuth.instance.currentUser;
    return user?.providerData.any(
      (p) => p.providerId == 'google.com',
    ) ?? false;
  }

  bool isEmailUser() {
    final user = FirebaseAuth.instance.currentUser;
    return user?.providerData.any(
      (p) => p.providerId == 'password',
    ) ?? false;
  }



  @override
  Widget build(BuildContext context) {
    log.d('is email user: ${isEmailUser()}');
    log.d('is google user: ${isGoogleUser()}');

    return Scaffold(
      appBar: context.customAppBar(
        title: 'Dashboard',
        showBackButton: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            iconSize: 30,
            onPressed: () {
              if (isEmailUser()) {
                context.pushNamed(RouteName.profile);
              } else {
                _showSignOutDialog(context);
              }
            } 
          ),
        ],
      ),

      body: context.gradientScreen(
        colors: const [
          Color.fromARGB(255, 235, 216, 215),
          Colors.blue,
        ],
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: context.getPercentWidth(6),
              vertical: context.getPercentHeight(2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
      ),
    );
  }

  // ================= USER SUMMARY =================
  Widget _userSummary(BuildContext context) {
    final firstName = userData?['firstName'] ?? '';

    return BlocBuilder<ExpenseCubit, ExpenseState>(
      builder: (context, state) {
        final totalExpense = state is ExpenseLoaded ? state.totalExpense : 0.0;

        return Column(
          children: [
            context.shadowBox(
              width: 85,
              height: 12,
              textColor: Colors.black,
              text: 'Hey $firstName welcome to your money management system',
              fontStyle: FontStyle.italic,
            ),
            SizedBox(height: context.getPercentHeight(4)),
            context.shadowBox(
              width: 85,
              height: 15,
              header: 'Your total expenses',
              textColor: Colors.black,
              text: "₹ ${totalExpense.toStringAsFixed(2)}",
              gradient: LinearGradient(
                colors: [
                  Colors.blueAccent.shade100,
                  Colors.pinkAccent.shade100,
                  Colors.orangeAccent.shade100,
                ],
              ),
            ),
          ],
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
              onTap: () async {
                await Navigator.pushNamed(context, RouteName.addExpense);

                if (!mounted) return;
                context.read<ExpenseCubit>().loadExpenses();
              },

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

  // ================= RECENT TRANSACTIONS =================
  Widget _recentTransactions() {
    return BlocBuilder<ExpenseCubit, ExpenseState>(
      builder: (context, state) {
        if (state is ExpenseLoading) {
          return const Center(child: CircularProgressIndicator());
        }

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
              ...state.expenses.take(5).map(
                    (e) => _transactionTile(
                      e.title,
                      "₹ ${e.amount.toStringAsFixed(2)}",
                      Colors.redAccent.shade400,
                    ),
                  ),
            ],
          );
        }

        return const SizedBox();
      },
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

  Widget _transactionTile(String title, String amount, Color color) {
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
              title,
              style: const TextStyle(color: Colors.white),
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

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        // title: const Text('Sign Out'),
        content: const Text(
          'Are you sure you want to sign out?',
          style: TextStyle(fontWeight: FontWeight.bold)
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text(
                  'Cancel', 
                  style: TextStyle(
                    fontWeight: FontWeight.bold, 
                    fontSize: 20
                  )
                ),
              ),
              const SizedBox(width: 20,),
              TextButton(
                onPressed: () async {
                  Navigator.pop(ctx);
                  await context.read<AuthCubit>().logout();
                  // ignore: use_build_context_synchronously
                  context.pushNamedUnAuthenticated(RouteName.login);
                },
                child: const Text(
                  'Sign Out',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.red, 
                    fontWeight: FontWeight.bold, 
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

