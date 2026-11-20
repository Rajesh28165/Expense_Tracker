
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:kharchasutra/util/logging.dart';

import '../firebase_options.dart';

class NotificationService {
  final log = logger(NotificationService);

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<String>? _tokenRefreshSubscription;

  String? _currentToken;
  String? _registeredUid;
  String? _registeredToken;

  Future<void> initialize() async {
    // 1. Request notification permission
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    log.d('Notification permission: ${settings.authorizationStatus}');

    // 2. Get FCM registration token
    _currentToken = await _messaging.getToken();

    log.d('FCM Token: $_currentToken');

    // 3. Listen for authentication changes
    _authSubscription = _auth.authStateChanges().listen(
      (user) {
        _handleAuthStateChange(user);
      },
      onError: (error) {
        log.d('Auth state listener error: $error');
      },
    );

    // 4. Listen for token refresh
    _tokenRefreshSubscription = _messaging.onTokenRefresh.listen(
      (newToken) {
        log.d('New FCM Token: $newToken');

        _currentToken = newToken;

        final user = _auth.currentUser;

        if (user != null) {
          _saveTokenToFirestore(user, newToken);
        }
      },
      onError: (error) {
        log.d('FCM token refresh error: $error');
      },
    );

    // 5. Listen for foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log.d('Foreground notification received');
      log.d('Title: ${message.notification?.title}');
      log.d('Body: ${message.notification?.body}');
      log.d('Data: ${message.data}');

      // Step 3: Display using flutter_local_notifications
    });

    // 6. Handle notification click when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      log.d('Notification clicked from background');
      handleNotificationClick(message);
    });

    // 7. Handle notification click when app was terminated
    final initialMessage = await _messaging.getInitialMessage();

    if (initialMessage != null) {
      log.d('App opened through notification');
      handleNotificationClick(initialMessage);
    }
  }

  Future<void> _handleAuthStateChange(User? user) async {
    if (user == null) {
      // Keep the existing token registration.
      // It may be needed if the user resets their password
      // while logged out.
      return;
    }

    // If a different user logs in on this device,
    // remove the previous user's token association.
    if (_registeredUid != null &&
        _registeredUid != user.uid &&
        _registeredToken != null) {
      await _removeTokenFromFirestore(
        _registeredUid!,
        _registeredToken!,
      );
    }

    if (_currentToken != null) {
      await _saveTokenToFirestore(user, _currentToken!);
    }
  }

  Future<void> _saveTokenToFirestore(
    User user,
    String token,
  ) async {
    try {
      final tokenId = Uri.encodeComponent(token);

      final tokenRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('fcmTokens')
          .doc(tokenId);

      final existingDoc = await tokenRef.get();

      final data = <String, dynamic>{
        'token': token,
        'platform': kIsWeb ? 'web' : defaultTargetPlatform.name,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (!existingDoc.exists) {
        data['createdAt'] = FieldValue.serverTimestamp();
      }

      await tokenRef.set(data, SetOptions(merge: true));

      _registeredUid = user.uid;
      _registeredToken = token;

      log.d('FCM token saved for user: ${user.uid}');
    } catch (error) {
      log.d('Failed to save FCM token: $error');
    }
  }

  Future<void> _removeTokenFromFirestore(
    String uid,
    String token,
  ) async {
    try {
      final tokenId = Uri.encodeComponent(token);

      await _firestore
          .collection('users')
          .doc(uid)
          .collection('fcmTokens')
          .doc(tokenId)
          .delete();

      log.d('Previous FCM token removed for user: $uid');
    } catch (error) {
      log.d('Failed to remove previous FCM token: $error');
    }
  }

  void handleNotificationClick(RemoteMessage message) {
    log.d('Notification data: ${message.data}');

    // Step 4: Navigate to the relevant screen
  }

  Future<void> dispose() async {
    await _authSubscription?.cancel();
    await _tokenRefreshSubscription?.cancel();
  }
}

// Background handler must be top-level
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  debugPrint('Background message: ${message.messageId}');
  debugPrint('Notification title: ${message.notification?.title}');
  debugPrint('Notification body: ${message.notification?.body}');
  debugPrint('Notification data: ${message.data}');
}
