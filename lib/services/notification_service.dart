import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  static const String _newsNotifKey = 'news_notifications_enabled';
  static const String _videoNotifKey = 'video_notifications_enabled';
  static const String _breakingNotifKey = 'breaking_notifications_enabled';

  Future<void> init() async {
    // Initialize local notifications first (always available)
    await _initializeLocalNotifications();

    // Try to initialize Firebase (optional)
    try {
      await Firebase.initializeApp();
      _firebaseMessaging = FirebaseMessaging.instance;
      _isFirebaseAvailable = true;
      await _initializeFirebaseMessaging();
    } catch (e) {
      _isFirebaseAvailable = false;
      print('⚠️ Firebase not available for push notifications: $e');
      print('📱 Local notifications will still work');
    }
  }

  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Create notification channels
    await _createNotificationChannels();

    print('✅ Local notifications initialized');
  }

  Future<void> _createNotificationChannels() async {
    // News updates channel
    const newsChannel = AndroidNotificationChannel(
      'news_updates',
      'News Updates',
      description: 'Notifications for new news articles',
      importance: Importance.high,
    );

    // Breaking news channel
    const breakingChannel = AndroidNotificationChannel(
      'breaking_news',
      'Breaking News',
      description: 'Urgent breaking news notifications',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );

    // Video updates channel
    const videoChannel = AndroidNotificationChannel(
      'video_updates',
      'Video Updates',
      description: 'Notifications for new videos',
      importance: Importance.defaultImportance,
    );

    final plugin =
        _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await plugin?.createNotificationChannel(newsChannel);
    await plugin?.createNotificationChannel(breakingChannel);
    await plugin?.createNotificationChannel(videoChannel);
  }

  Future<void> _initializeFirebaseMessaging() async {
    if (!_isFirebaseAvailable || _firebaseMessaging == null) return;

    try {
      // Request permissions for iOS
      await _firebaseMessaging!.requestPermission();

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
      });

      print('✅ Firebase messaging initialized');
    } catch (e) {
      print('⚠️ Error initializing Firebase messaging: $e');
    }
  }

  // Show new news notification
  Future<void> showNewNewsNotification(int count) async {
    if (!await isNewsNotificationsEnabled()) return;

    await _flutterLocalNotificationsPlugin.show(
      1,
      'New Articles Available',
      '$count new article${count > 1 ? 's' : ''} published',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'news_updates',
          'News Updates',
          channelDescription: 'Notifications for new news articles',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
    );
  }

  // Show breaking news notification
  Future<void> showBreakingNewsNotification(String title, String body) async {
    if (!await isBreakingNotificationsEnabled()) return;

    await _flutterLocalNotificationsPlugin.show(
      2,
      '🚨 BREAKING NEWS',
      title,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'breaking_news',
          'Breaking News',
          channelDescription: 'Urgent breaking news notifications',
          importance: Importance.max,
          priority: Priority.max,
          playSound: true,
          enableVibration: true,
          icon: '@mipmap/ic_launcher',
        ),
      ),
    );
  }

  // Show new videos notification
  Future<void> showNewVideosNotification(int count) async {
    if (!await isVideoNotificationsEnabled()) return;

    await _flutterLocalNotificationsPlugin.show(
      3,
      'New Videos Available',
      '$count new video${count > 1 ? 's' : ''} uploaded',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'video_updates',
          'Video Updates',
          channelDescription: 'Notifications for new videos',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: '@mipmap/ic_launcher',
        ),
      ),
    );
  }

  // Preference getters/setters
  Future<bool> isNewsNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_newsNotifKey) ?? true;
  }

  Future<void> setNewsNotifications(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_newsNotifKey, enabled);
  }

  Future<bool> isVideoNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_videoNotifKey) ?? true;
  }

  Future<void> setVideoNotifications(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_videoNotifKey, enabled);
  }

  Future<bool> isBreakingNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_breakingNotifKey) ?? true;
  }

  Future<void> setBreakingNotifications(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_breakingNotifKey, enabled);
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
