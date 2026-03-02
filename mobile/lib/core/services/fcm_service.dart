import 'dart:async';
import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';

import '../../features/notifications/data/datasources/notifications_remote_datasource.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  log('FCM background message: ${message.messageId}');
}

class FcmService {
  final NotificationsRemoteDataSource _dataSource;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  final _foregroundController = StreamController<void>.broadcast();
  Stream<void> get onForegroundNotification => _foregroundController.stream;

  GoRouter? _router;
  bool _localNotificationsInitialized = false;
  StreamSubscription? _tokenRefreshSub;
  StreamSubscription? _foregroundMessageSub;
  StreamSubscription? _messageTapSub;

  FcmService({required NotificationsRemoteDataSource dataSource})
      : _dataSource = dataSource;

  void setRouter(GoRouter router) => _router = router;

  Future<void> initialize() async {
    await _cancelSubscriptions();

    if (!_localNotificationsInitialized) {
      await _setupLocalNotifications();
      _localNotificationsInitialized = true;
    }

    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      log('FCM: Push notification permission denied');
      return;
    }

    final token = await _messaging.getToken();
    if (token != null) {
      await _registerToken(token);
    }

    _tokenRefreshSub = _messaging.onTokenRefresh.listen(_registerToken);
    _foregroundMessageSub =
        FirebaseMessaging.onMessage.listen(_onForegroundMessage);
    _messageTapSub =
        FirebaseMessaging.onMessageOpenedApp.listen(_onNotificationTap);

    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _onNotificationTap(initialMessage);
    }

    log('FCM: Initialized');
  }

  Future<void> _setupLocalNotifications() async {
    const androidChannel = AndroidNotificationChannel(
      'anticifi_notifications',
      'AnticiFi Notifications',
      description: 'Financial alerts and updates from AnticiFi',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (_) {
        _router?.go('/notifications');
      },
    );
  }

  Future<void> _registerToken(String token) async {
    try {
      await _dataSource.registerFcmToken(token);
      log('FCM: Token registered');
    } catch (e) {
      log('FCM: Failed to register token: $e');
    }
  }

  void _onForegroundMessage(RemoteMessage message) {
    log('FCM foreground message: ${message.notification?.title}');

    final notification = message.notification;
    if (notification != null) {
      _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'anticifi_notifications',
            'AnticiFi Notifications',
            channelDescription: 'Financial alerts and updates from AnticiFi',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
      );
    }

    _foregroundController.add(null);
  }

  void _onNotificationTap(RemoteMessage message) {
    log('FCM: Notification tapped: ${message.notification?.title}');
    _router?.go('/notifications');
  }

  Future<void> removeToken() async {
    await _cancelSubscriptions();
    try {
      await _dataSource.removeFcmToken();
      await _messaging.deleteToken();
      log('FCM: Token removed');
    } catch (e) {
      log('FCM: Failed to remove token: $e');
    }
  }

  Future<void> _cancelSubscriptions() async {
    await _tokenRefreshSub?.cancel();
    await _foregroundMessageSub?.cancel();
    await _messageTapSub?.cancel();
    _tokenRefreshSub = null;
    _foregroundMessageSub = null;
    _messageTapSub = null;
  }
}
