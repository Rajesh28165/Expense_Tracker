import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kharchasutra/constants/app_constants.dart';

import '../logic/auth/auth_cubit.dart';
import '../logic/auth/auth_state.dart';

class SessionService {
  static const Duration _sessionTimeout = Duration(minutes: AppConstants.sessionTime);

  Timer? _timer;
  VoidCallback? _onTimeout;

  void resetTimer() {
    _timer?.cancel();

    if (_onTimeout == null) return;

    _timer = Timer(
      _sessionTimeout, 
      () => _onTimeout?.call()
    );
  }

  /// Set timeout callback (call only once)
  void setOnTimeout(VoidCallback callback) {
    _onTimeout = callback;
  }

  /// Cancel session timer
  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  /// Cleanup (optional)
  void dispose() {
    cancel();
    _onTimeout = null;
  }
}

/// GLOBAL SINGLE INSTANCE (IMPORTANT)
final SessionService sessionService = SessionService();


// ==========================================================
// USER ACTIVITY DETECTOR
// ==========================================================

class UserActivityDetector extends StatelessWidget {
  final Widget child;
  final SessionService sessionService;

  const UserActivityDetector({
    super.key,
    required this.child,
    required this.sessionService,
  });

  void _handleUserInteraction(BuildContext context) {
    final authState = context.read<AuthCubit>().state;

    if (authState is AuthAuthenticated) {
      sessionService.resetTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _handleUserInteraction(context),
      onPointerMove: (_) => _handleUserInteraction(context),
      onPointerUp: (_) => _handleUserInteraction(context),
      child: child,
    );
  }
}


// ==========================================================
// APP LIFECYCLE HANDLER (IMPORTANT)
// ==========================================================

class AppLifecycleHandler extends StatefulWidget {
  final Widget child;
  final SessionService sessionService;

  const AppLifecycleHandler({
    super.key,
    required this.child,
    required this.sessionService,
  });

  @override
  State<AppLifecycleHandler> createState() => _AppLifecycleHandlerState();
}

class _AppLifecycleHandlerState extends State<AppLifecycleHandler>
    with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final authState = context.read<AuthCubit>().state;
      if (authState is AuthAuthenticated) {
        widget.sessionService.resetTimer();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}