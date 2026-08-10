import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final class FcmService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'wallr_notifications';
  static const String _channelName = 'WALLR Notifications';
  static const String _channelDescription = 'Wallpaper updates and announcements';

  String? _lastToken;

  Future<void> initialize() async {
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      announcement: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      _initLocalNotifications();
      _getToken();
      _setupMessageHandlers();
    }
  }

  void _initLocalNotifications() {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onLocalNotificationTap,
    );
  }

  Future<void> _getToken() async {
    _lastToken = await _fcm.getToken();
    _fcm.onTokenRefresh.listen((token) {
      _lastToken = token;
    });
  }

  String? get currentToken => _lastToken;

  void _setupMessageHandlers() {
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);

    FirebaseMessaging.onMessageOpenedApp.listen(_onNotificationTap);

    _fcm.getInitialMessage().then(_onInitialMessage);
  }

  Future<void> _onForegroundMessage(RemoteMessage message) async {
    final notification = message.notification;
    final data = message.data;

    if (notification != null) {
      final androidDetails = AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        icon: '@mipmap/ic_launcher',
      );

      const iosDetails = DarwinNotificationDetails();

      final details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        details,
        payload: data['route'] ?? '',
      );
    }
  }

  void _onNotificationTap(RemoteMessage message) {
    _handleNotificationRoute(message.data);
  }

  void _onInitialMessage(RemoteMessage? message) {
    if (message != null) {
      _handleNotificationRoute(message.data);
    }
  }

  void _onLocalNotificationTap(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null && payload.isNotEmpty) {
      _pendingRoute = payload;
    }
  }

  void _handleNotificationRoute(Map<String, dynamic> data) {
    final route = data['route'] as String?;
    if (route != null && route.isNotEmpty) {
      _pendingRoute = route;
    }
  }

  String? _pendingRoute;

  String? consumePendingRoute() {
    final route = _pendingRoute;
    _pendingRoute = null;
    return route;
  }
}
