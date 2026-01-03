import 'package:expense_tracker/presentation/screens/Registeration/name_page.dart';
import 'package:expense_tracker/presentation/screens/dashboard_page.dart';
import 'package:expense_tracker/presentation/screens/Registeration/register_page.dart';
import 'package:expense_tracker/router/route_name.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../logic/auth/auth_cubit.dart';
import '../presentation/screens/Registeration/otp_page.dart';
import '../presentation/screens/add_expense_page.dart';
import '../presentation/screens/login_page.dart';
import '../presentation/screens/reports_page.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {

      case RouteName.login:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider(
            create: (_) => AuthCubit(FirebaseAuth.instance),
            child: const LoginPage(),
          ),
        );

      case RouteName.name:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const NamePage(),
        );

      case RouteName.otp:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const OtpPage(),
        );

      case RouteName.register:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider(
            create: (_) => AuthCubit(FirebaseAuth.instance),
            child: const RegisterPage(),
          ),
        );
      
      case RouteName.dashboard:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider(
            create: (_) => AuthCubit(FirebaseAuth.instance),
            child: const DashboardPage(),
          ),
        );

      case RouteName.addExpense:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider(
            create: (_) => AuthCubit(FirebaseAuth.instance),
            child: const AddExpensePage(),
          ),
        );

      case RouteName.report:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider(
            create: (_) => AuthCubit(FirebaseAuth.instance),
            child: const ReportsPage(),
          ),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('Page not found'),
            ),
          )
        );
    }

    
  }
}