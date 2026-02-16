import 'package:expense_tracker/router/route_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

import 'data/repositories/income_repository.dart';
import 'logic/auth/auth_cubit.dart';
import 'logic/expense/expense_cubit.dart';
import 'data/repositories/expense_repository.dart';
import 'logic/income/income_cubit.dart';
import 'logic/user/user_cubit.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AuthCubit(FirebaseAuth.instance),
        ),
        BlocProvider(
          create: (_) => ExpenseCubit(ExpenseRepository())..loadExpenses(),
        ),
        BlocProvider(
          create: (_) => IncomeCubit(IncomeRepository())..loadIncomes(),
        ),

        BlocProvider(
          create: (_) => UserCubit(),
        ),
      ],
      child: Builder(
        builder: (context) {
          final GoRouter router = createRouter(context);

          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'HISABKITAB',
            routerConfig: router,
          );
        },
      ),
    );
  }
}
