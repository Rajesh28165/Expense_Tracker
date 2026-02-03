// ignore_for_file: prefer_const_constructors

import 'package:expense_tracker/constants/extension.dart';
import 'package:expense_tracker/router/route_name.dart';
import 'package:expense_tracker/router/route_path.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'data/repositories/expense_repository.dart';
import 'data/cubit/userCubit.dart';
import 'logic/auth/auth_cubit.dart';
import 'logic/expense/expense_cubit.dart';


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
        BlocProvider<AuthCubit>(
          create: (_) => AuthCubit(FirebaseAuth.instance),
        ),
        BlocProvider<ExpenseCubit>(
          create: (_) => ExpenseCubit(ExpenseRepository())..loadExpenses(),
        ),
        BlocProvider<UserCubit>(
          create: (_) => UserCubit(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'HISABKITAB',
        navigatorKey: BuildContextExtensionFunctions.navigatorUnauthenticated,
        onGenerateRoute: AppRouter.generateRoute,
        initialRoute: RouteName.home,
      ),
    );


  }
}
