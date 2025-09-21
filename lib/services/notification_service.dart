import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_core/firebase_core.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  FirebaseMessaging? _firebaseMessaging;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isFirebaseAvailable = false;

  Future<void> init() async {
    try {
      // Check if Firebase is available
      await Firebase.initializeApp();
      _firebaseMessaging = FirebaseMessaging.instance;
      _isFirebaseAvailable = true;
    } catch (e) {
      _isFirebaseAvailable = false;
      print('⚠️ Firebase not available for notifications: $e');
      return;
    }

    if (!_isFirebaseAvailable || _firebaseMessaging == null) {
      print('📱 Notifications disabled - Firebase not available');
      return;
    }

    try {
      // Request permissions for iOS
      await _firebaseMessaging!.requestPermission();

      // Initialize local notifications
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const InitializationSettings initializationSettings =
          InitializationSettings(android: initializationSettingsAndroid);

      await _flutterLocalNotificationsPlugin.initialize(initializationSettings);

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        RemoteNotification? notification = message.notification;
        AndroidNotification? android = message.notification?.android;

        if (notification != null && android != null) {
          _flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            const NotificationDetails(
              android: AndroidNotificationDetails(
                'default_channel',
                'Default Channel',
                channelDescription: 'This channel is used for notifications.',
                importance: Importance.max,
                priority: Priority.high,
                icon: '@mipmap/ic_launcher',
              ),
            ),
          );
        }
      });

      // Handle background and terminated state messages
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        // Handle notification tap
        // You can navigate to specific screen here
      });

      print('✅ Notification service initialized successfully');
    } catch (e) {
      print('⚠️ Error initializing notification service: $e');
    }
  }

  Future<String?> getToken() async {
    if (!_isFirebaseAvailable || _firebaseMessaging == null) {
      print('📱 Firebase not available - cannot get token');
      return null;
    }

    try {
      return await _firebaseMessaging!.getToken();
    } catch (e) {
      print('⚠️ Error getting FCM token: $e');
      return null;
    }
  }

  bool get isFirebaseAvailable => _isFirebaseAvailable;
}
