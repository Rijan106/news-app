import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'notification_service.dart';

class AppInitializationService {
  static final AppInitializationService _instance =
      AppInitializationService._internal();

  factory AppInitializationService() {
    return _instance;
  }

  AppInitializationService._internal();

  bool _isFirebaseInitialized = false;
  bool _isNotificationServiceInitialized = false;

  bool get isFirebaseInitialized => _isFirebaseInitialized;
  bool get isNotificationServiceInitialized =>
      _isNotificationServiceInitialized;

  Future<void> initializeApp() async {
    debugPrint('🚀 Starting app initialization...');

    // Initialize Firebase
    await _initializeFirebase();

    // Initialize Notification Service if Firebase is available
    if (_isFirebaseInitialized) {
      await _initializeNotificationService();
    }

    debugPrint('✅ App initialization completed');
  }

  Future<void> _initializeFirebase() async {
    try {
      if (kIsWeb) {
        // For web platform, provide explicit options
        await Firebase.initializeApp(
          options: const FirebaseOptions(
            apiKey: "AIzaSyCsz2A4Zy8822GkrgIrz-Ye_kKIbOt4LWs",
            authDomain: "pushnotification-f9cc5.firebaseapp.com",
            projectId: "pushnotification-f9cc5",
            storageBucket: "pushnotification-f9cc5.firebasestorage.app",
            messagingSenderId: "138106899280",
            appId: "1:138106899280:web:1c551d42b679527a35ba55",
          ),
        );
      } else {
        // For mobile platforms, use default initialization (reads from google-services.json)
        await Firebase.initializeApp();
      }
      _isFirebaseInitialized = true;
      debugPrint('✅ Firebase initialized successfully');
    } catch (e) {
      _isFirebaseInitialized = false;
      debugPrint('⚠️ Firebase initialization failed: $e');
      debugPrint('📱 App will continue without Firebase features');
    }
  }

  Future<void> _initializeNotificationService() async {
    try {
      final notificationService = NotificationService();
      await notificationService.init();
      _isNotificationServiceInitialized = true;
      debugPrint('✅ Notification service initialized');
    } catch (e) {
      _isNotificationServiceInitialized = false;
      debugPrint('⚠️ Notification service initialization failed: $e');
    }
  }

  // Get notification service instance (only if initialized)
  NotificationService? getNotificationService() {
    if (_isNotificationServiceInitialized) {
      return NotificationService();
    }
    return null;
  }

  // Check if all services are ready
  bool get isAppReady =>
      _isFirebaseInitialized && _isNotificationServiceInitialized;

  // Get initialization status
  String getInitializationStatus() {
    return '''
    Firebase: ${_isFirebaseInitialized ? '✅' : '❌'}
    Notifications: ${_isNotificationServiceInitialized ? '✅' : '❌'}
    App Ready: ${isAppReady ? '✅' : '❌'}
    ''';
  }
}
