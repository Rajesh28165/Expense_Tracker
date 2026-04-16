import 'dart:async';

import 'package:kharchasutra/presentation/screens/Support/verify_password_page.dart';
import 'package:kharchasutra/presentation/screens/Support/verify_security_question_page.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../constants/app_constants.dart';
import '../logic/auth/auth_cubit.dart';
import '../logic/auth/auth_state.dart';
import '../presentation/screens/Contents/add_txn_page.dart';
import '../presentation/screens/Registration/email_verification_page.dart';
import '../presentation/screens/Login/forgot_password.dart';
import '../presentation/screens/Login/login_page.dart';
import '../presentation/screens/Registration/registeration_page.dart';
import '../presentation/screens/Support/reset_password.dart';
import '../presentation/screens/Registration/security_page.dart';
import '../presentation/screens/Contents/dashboard_page.dart';
import '../presentation/screens/Support/profile_page.dart';
import '../presentation/screens/Contents/navigation_page.dart';
import '../presentation/screens/Contents/show_txn_page.dart';
import '../presentation/screens/Support/support_page.dart';
import '../presentation/screens/Contents/txn_report.dart';
import 'route_name.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

GoRouter createRouter(BuildContext context, GlobalKey<NavigatorState> navigatorKey) {
  return GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: RouteName.login,

    refreshListenable: GoRouterRefreshStream(
      context.read<AuthCubit>().stream,
    ),

    redirect: (context, state) {
      final authState = context.read<AuthCubit>().state;
      final isLoggedIn = authState is AuthAuthenticated;
      final isEmailUnverified = authState is AuthEmailUnverified;
      final isVerifySuccess = authState is VerifySuccess;
      final isSessionTimeout = authState is AuthSessionTimeout;

      final isAuthRoute = 
        state.matchedLocation == RouteName.login ||
        state.matchedLocation == RouteName.registeration ||
        state.matchedLocation == RouteName.forgotPassword ||
        state.matchedLocation == RouteName.emailVerification;

      if (
          !isLoggedIn && 
          !isEmailUnverified && 
          !isVerifySuccess &&
          !isSessionTimeout &&
          !isAuthRoute
        ) {
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
        path: RouteName.emailVerification,
        builder: (context, state) => EmailVerificationPage(
          email: state.extra as String
        ),
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
            builder: (_, __) => const TransactionReportPage(type: TransactionType.expense),
          ),

          GoRoute(
            path: RouteName.incomeReport,
            builder: (_, __) => const TransactionReportPage(type: TransactionType.income),
          ),
        ],
      ),

      // ---------------- FULLSCREEN ROUTES ----------------

      GoRoute(
        path: RouteName.addTransactions,
        builder: (context, state) => AddTransactionPage(
          type: state.extra as TransactionType,
        ),
      ),

      GoRoute(
        path: RouteName.showTransactions,
        builder: (context, state) => ShowTransactionPage(
          type: state.extra as TransactionType,
        ),
      ),

      GoRoute(
        path: RouteName.profile,
        builder: (_, __) => const ProfilePage(),
      ),

      GoRoute(
        path: RouteName.verifySecurityQuestion,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return VerifySecurityQuestionPage(
            purpose: extra?['purpose'] as String? ?? AppConstants.purposeUpdateSecurityQA,
            count:   extra?['count'] as int? ?? 1,
          );
        },
      ),

      GoRoute(
        path: RouteName.verifyPassword,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return VerifyPasswordPage(
            purpose: extra?['purpose'] as String? ?? AppConstants.purposeUpdatePassword,
            count:   extra?['count'] as int? ?? 1,
          );
        },
      ),

      GoRoute(
        path: RouteName.resetPassword,
        builder: (_, __) => const ResetPasswordPage(),
      ),

      GoRoute(
        path: RouteName.support,
        builder: (_, __) => const SupportPage(),
      ),
    ],
  );
}
