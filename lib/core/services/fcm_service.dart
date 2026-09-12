import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Runs on a separate isolate for messages arriving while the app is
/// backgrounded or terminated. Messages carrying a notification payload are
/// already posted to the status bar by the system — this handler exists so
/// data-only payloads (title/body keys) aren't silently dropped.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  if (message.notification != null) return; // system displayed it

  final title = message.data['title'] as String?;
  final body = message.data['body'] as String?;
  if (title == null || title.isEmpty || body == null || body.isEmpty) return;

  final plugin = FlutterLocalNotificationsPlugin();
  await plugin.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    ),
  );

  await plugin.show(
    message.messageId?.hashCode ?? title.hashCode,
    title,
    body,
    const NotificationDetails(
      android: AndroidNotificationDetails(
        FcmService.channelId,
        FcmService.channelName,
        channelDescription: FcmService.channelDescription,
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        icon: '@mipmap/ic_launcher',
      ),
    ),
    payload: message.data['route'] as String?,
  );
}

/// Called with every fresh FCM token so the app can persist it (e.g. under
/// the signed-in user's Firestore doc) — the backend needs stored tokens to
/// be able to push to this device at all.
typedef TokenPersister = Future<void> Function(String token);

final class FcmService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const String channelId = 'wallr_notifications';
  static const String channelName = 'WALLR Notifications';
  static const String channelDescription = 'Wallpaper updates and announcements';

  String? _lastToken;

  Future<void> initialize({TokenPersister? persistToken}) async {
    // Must be registered before runApp so cold-start messages reach the
    // background isolate too.
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

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
      await _createAndroidChannel();
      _getToken(persistToken);
      _setupMessageHandlers();
    }
  }

  /// Creates the channel up front so FCM background notifications (which use
  /// the channel id from AndroidManifest) land in it instead of
  /// "Miscellaneous".
  Future<void> _createAndroidChannel() async {
    final android = _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await android?.createNotificationChannel(
      const AndroidNotificationChannel(
        channelId,
        channelName,
        description: channelDescription,
        importance: Importance.high,
      ),
    );
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

  void _getToken(TokenPersister? persistToken) {
    _fcm.getToken().then((token) {
      _lastToken = token;
      _persistToken(persistToken);
    });
    _fcm.onTokenRefresh.listen((token) {
      _lastToken = token;
      _persistToken(persistToken);
    });
    // Save as soon as a user signs in — covers the first login after install
    // and re-login, when no token has been persisted for this uid yet.
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) _persistToken(persistToken);
    });
  }

  /// Best-effort persistence: a failed save must never break startup or
  /// messaging.
  Future<void> _persistToken(TokenPersister? persistToken) async {
    final token = _lastToken;
    if (persistToken == null || token == null || token.isEmpty) return;
    try {
      await persistToken(token);
    } catch (_) {}
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
        channelId,
        channelName,
        channelDescription: channelDescription,
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
