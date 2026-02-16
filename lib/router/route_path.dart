import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../logic/auth/auth_cubit.dart';
import '../logic/auth/auth_state.dart';
import '../presentation/screens/add_income_page.dart';
import '../presentation/screens/expense_transaction_page.dart';
import '../presentation/screens/forgot_password.dart';
import '../presentation/screens/income_report.dart';
import '../presentation/screens/income_transaction_page.dart';
import '../presentation/screens/login_page.dart';
import '../presentation/screens/registeration_page.dart';
import '../presentation/screens/reset_password.dart';
import '../presentation/screens/security_page.dart';
import '../presentation/screens/dashboard_page.dart';
import '../presentation/screens/expense_report.dart';
import '../presentation/screens/add_expense_page.dart';
import '../presentation/screens/profile_page.dart';
import '../presentation/screens/navigation_page.dart';
import 'route_name.dart';

GoRouter createRouter(BuildContext context) {
  return GoRouter(
    initialLocation: RouteName.login,

    redirect: (context, state) {
      final authState = context.read<AuthCubit>().state;
      final isLoggedIn = authState is AuthAuthenticated;

      final isAuthRoute = 
        state.matchedLocation == RouteName.login ||
        state.matchedLocation == RouteName.registeration ||
        state.matchedLocation == RouteName.forgotPassword;

      if (!isLoggedIn && !isAuthRoute) {
        return RouteName.login;
      }

      if (isLoggedIn && isAuthRoute) {
        return RouteName.dashboard;
      }

      return null;
    },

    routes: [
      // ---------------- AUTH ROUTES ----------------
      GoRoute(
        path: RouteName.login,
        builder: (_, __) => const LoginPage(),
      ),

      GoRoute(
        path: RouteName.registeration,
        builder: (_, __) => const RegisterationPage(),
      ),

      GoRoute(
        path: RouteName.forgotPassword,
        builder: (_, __) => const ForgotPasswordPage(),
      ),


      GoRoute(
        path: RouteName.security,
        builder: (_, __) => const SecurityPage(),
      ),

      // ---------------- APP WITH BOTTOM NAV ----------------
      ShellRoute(
        builder: (context, state, child) {
          return NavigationPage(child: child);
        },
        routes: [
          GoRoute(
            path: RouteName.dashboard,
            builder: (_, __) => const DashboardPage(),
          ),
          GoRoute(
            path: RouteName.expenseReport,
            builder: (_, __) => const ExpenseReport(),
          ),
          GoRoute(
            path: RouteName.incomeReport,
            builder: (_, __) => const IncomeReport(),
          ),
        ],
      ),

      // ---------------- FULLSCREEN ROUTES ----------------
      GoRoute(
        path: RouteName.addExpense,
        builder: (_, __) => const AddExpensePage(),
      ),

      GoRoute(
        path: RouteName.addIncome,
        builder: (_, __) => const AddIncomePage(),
      ),

      GoRoute(
        path: RouteName.expenseTransaction,
        builder: (_, __) => const ExpenseTransactionPage(),
      ),

      GoRoute(
        path: RouteName.incomeTransaction,
        builder: (_, __) => const IncomeTransactionPage(),
      ),

      GoRoute(
        path: RouteName.profile,
        builder: (_, __) => const ProfilePage(),
      ),

      GoRoute(
        path: RouteName.resetPassword,
        builder: (_, __) => const ResetPasswordPage(),
      ),
    ],
  );
}
