import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kharchasutra/presentation/widgets/generalComponents.dart';
import 'package:kharchasutra/router/route_path.dart';
import 'package:kharchasutra/services/services.dart';
import 'package:kharchasutra/util/colors.dart';

import 'constants/app_constants.dart';
import 'data/repositories/income_repository.dart';
import 'logic/auth/auth_cubit.dart';
import 'logic/auth/auth_state.dart';
import 'logic/expense/expense_cubit.dart';
import 'data/repositories/expense_repository.dart';
import 'logic/income/income_cubit.dart';
import 'logic/user/user_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  late final AuthCubit _authCubit;

  Timer? _dialogTimer;
  late ValueNotifier<int> countdownNotifier;

  bool isDialogOpen = false;

  @override
  void initState() {
    super.initState();

    _authCubit = AuthCubit(FirebaseAuth.instance);

    countdownNotifier = ValueNotifier(5);

    sessionService.setOnTimeout(() {
      _authCubit.sessionExpired();
    });
  }

  @override
  void dispose() {
    _dialogTimer?.cancel();
    countdownNotifier.dispose();
    _authCubit.close();
    sessionService.dispose();
    super.dispose();
  }

  void _showSessionDialog() {
    final navContext = navigatorKey.currentContext;
    if (navContext == null) return;

    if (isDialogOpen) return;
    isDialogOpen = true;

    int seconds = AppConstants.sessionWaringTime;
    countdownNotifier.value = seconds;

    _dialogTimer?.cancel();
    _dialogTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      seconds--;
      countdownNotifier.value = seconds;

      if (seconds <= 0) {
        timer.cancel();

        if (isDialogOpen) {
          Navigator.of(navContext, rootNavigator: true).pop();
          isDialogOpen = false;
        }
        Future.microtask(() {
          _authCubit.logout();
        });
      }
    });

    navContext.showCustomDialog(
      title: 'Session Expired',
      descriptionWidget: ValueListenableBuilder<int>(
        valueListenable: countdownNotifier,
        builder: (_, value, __) {
          return Text(
            'You will be logged out in $value seconds',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: WidgetColors.ink2,
            ),
            textAlign: TextAlign.center,
          );
        },
      ),
      buttonText: 'Keep me logged in',
      onPressed: () {
        _dialogTimer?.cancel();
        sessionService.resetTimer();
        isDialogOpen = false;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _authCubit),

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
          return AppLifecycleHandler(
            sessionService: sessionService,
            child: UserActivityDetector(
              sessionService: sessionService,
              child: BlocListener<AuthCubit, AuthState>(
                listenWhen: (_, current) => current is AuthSessionTimeout,
                listener: (context, state) {
                  _showSessionDialog();
                },
                child: MaterialApp.router(
                  debugShowCheckedModeBanner: false,
                  title: AppConstants.appName,
                  routerConfig: createRouter(context, navigatorKey),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}