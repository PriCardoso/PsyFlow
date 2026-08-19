import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/di/service_locator.dart';
import '../theme/app_colors.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final FirebaseFirestore _firestore = sl<FirebaseFirestore>();
  final FirebaseAuth _auth = sl<FirebaseAuth>();

  bool _initialized = false;
  String? _fcmToken;

  Future<void> initialize() async {
    if (_initialized) return;

    initializeTimeZones();

    await _requestPermissions();
    await _initLocalNotifications();
    await _configureFCM();
    await _subscribeToUserTopics();

    _initialized = true;
  }

  static void initializeTimeZones() {
    tz_data.initializeTimeZones();
  }

  Future<void> _requestPermissions() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  Future<void> _initLocalNotifications() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    await _createNotificationChannels();
  }

  Future<void> _createNotificationChannels() async {
    final androidPlugin = _localNotifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin == null) return;

    await androidPlugin.createNotificationChannel(const AndroidNotificationChannel(
      'appointment_reminders',
      'Lembretes de Consulta',
      description: 'Notificações para consultas agendadas',
      importance: Importance.high,
    ));

    await androidPlugin.createNotificationChannel(const AndroidNotificationChannel(
      'task_reminders',
      'Lembretes de Tarefas',
      description: 'Notificações para tarefas terapêuticas pendentes',
      importance: Importance.high,
    ));

    await androidPlugin.createNotificationChannel(const AndroidNotificationChannel(
      'mood_reminders',
      'Lembretes de Humor',
      description: 'Lembretes para registrar o humor diário',
      importance: Importance.defaultImportance,
    ));

    await androidPlugin.createNotificationChannel(const AndroidNotificationChannel(
      'chat_messages',
      'Mensagens do Chat',
      description: 'Novas mensagens no chat terapêutico',
      importance: Importance.high,
    ));

    await androidPlugin.createNotificationChannel(const AndroidNotificationChannel(
      'general',
      'Gerais',
      description: 'Notificações gerais do aplicativo',
      importance: Importance.defaultImportance,
    ));
  }

  Future<void> _configureFCM() async {
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageOpenedApp(initialMessage);
    }

    _messaging.onTokenRefresh.listen((token) {
      _saveTokenToFirestore(token);
    });

    _fcmToken = await _messaging.getToken();
    if (_fcmToken != null) {
      await _saveTokenToFirestore(_fcmToken!);
    }
  }

  Future<void> _saveTokenToFirestore(String token) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore.collection('users').doc(user.uid).update({
        'fcm_token': token,
        'fcm_token_updated_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error saving FCM token: $e');
    }
  }

  Future<void> _subscribeToUserTopics() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _messaging.subscribeToTopic('user_${user.uid}');
      
      final role = await _getUserRole(user.uid);
      if (role == 'psychologist' || role == 'professional') {
        await _messaging.subscribeToTopic('psychologist_${user.uid}');
      } else if (role == 'patient') {
        await _messaging.subscribeToTopic('patient_${user.uid}');
      }
    } catch (e) {
      debugPrint('Error subscribing to topics: $e');
    }
  }

  Future<void> unsubscribeFromUserTopics() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _messaging.unsubscribeFromTopic('user_${user.uid}');
      
      final role = await _getUserRole(user.uid);
      if (role == 'psychologist' || role == 'professional') {
        await _messaging.unsubscribeFromTopic('psychologist_${user.uid}');
      } else if (role == 'patient') {
        await _messaging.unsubscribeFromTopic('patient_${user.uid}');
      }
    } catch (e) {
      debugPrint('Error unsubscribing from topics: $e');
    }
  }

  Future<String?> _getUserRole(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      return doc.data()?['role'] as String?;
    } catch (e) {
      debugPrint('Error getting user role: $e');
      return null;
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    final data = message.data;

    if (notification != null) {
      _showLocalNotification(
        id: message.messageId?.hashCode ?? DateTime.now().millisecondsSinceEpoch,
        title: notification.title ?? 'PsyFlow',
        body: notification.body ?? '',
        payload: data['payload'] ?? '',
        channelId: _getChannelId(data['type']),
        data: data,
      );
    }
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    final data = message.data;
    _navigateBasedOnData(data);
  }

  String _getChannelId(String? type) {
    switch (type) {
      case 'appointment':
        return 'appointment_reminders';
      case 'task':
        return 'task_reminders';
      case 'mood':
        return 'mood_reminders';
      case 'chat':
        return 'chat_messages';
      default:
        return 'general';
    }
  }

  void _navigateBasedOnData(Map<String, dynamic> data) {
    // Navigation would be handled via a navigator key or router
    // Example: navigatorKey.currentState?.pushNamed(route, arguments: data);
    debugPrint('Navigate with data: $data');
  }

  Future<void> _showLocalNotification({
    required int id,
    required String title,
    required String body,
    String payload = '',
    String channelId = 'general',
    Map<String, dynamic>? data,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      channelId,
      _getChannelName(channelId),
      channelDescription: _getChannelDescription(channelId),
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: AppColors.primary,
      playSound: true,
      enableVibration: true,
    );

    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(id, title, body, details, payload: payload);
  }

  String _getChannelName(String channelId) {
    switch (channelId) {
      case 'appointment_reminders':
        return 'Lembretes de Consulta';
      case 'task_reminders':
        return 'Lembretes de Tarefas';
      case 'mood_reminders':
        return 'Lembretes de Humor';
      case 'chat_messages':
        return 'Mensagens do Chat';
      default:
        return 'Gerais';
    }
  }

  String _getChannelDescription(String channelId) {
    switch (channelId) {
      case 'appointment_reminders':
        return 'Notificações para consultas agendadas';
      case 'task_reminders':
        return 'Notificações para tarefas terapêuticas pendentes';
      case 'mood_reminders':
        return 'Lembretes para registrar o humor diário';
      case 'chat_messages':
        return 'Novas mensagens no chat terapêutico';
      default:
        return 'Notificações gerais do aplicativo';
    }
  }

  void _onNotificationTap(NotificationResponse response) {
    if (response.payload != null && response.payload!.isNotEmpty) {
      _navigateBasedOnData({'payload': response.payload});
    }
  }

  // Public methods for scheduling local notifications
  Future<void> scheduleAppointmentReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String payload = '',
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'appointment_reminders',
      'Lembretes de Consulta',
      channelDescription: 'Notificações para consultas agendadas',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: AppColors.psychologist,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.zonedSchedule(
      id,
      title,
      body,
      _toTZDateTime(scheduledTime),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> scheduleTaskReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String payload = '',
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'task_reminders',
      'Lembretes de Tarefas',
      channelDescription: 'Notificações para tarefas terapêuticas pendentes',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: AppColors.patient,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.zonedSchedule(
      id,
      title,
      body,
      _toTZDateTime(scheduledTime),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> scheduleMoodReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String payload = '',
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'mood_reminders',
      'Lembretes de Humor',
      channelDescription: 'Lembretes para registrar o humor diário',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      icon: '@mipmap/ic_launcher',
      color: AppColors.accent,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.zonedSchedule(
      id,
      title,
      body,
      _toTZDateTime(scheduledTime),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelNotification(int id) async {
    await _localNotifications.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  tz.TZDateTime _toTZDateTime(DateTime dateTime) {
    return tz.TZDateTime.from(dateTime, tz.local);
  }

  // Send notification to specific user via FCM topic
  Future<void> sendNotificationToUser({
    required String userId,
    required String title,
    required String body,
    String? type,
    Map<String, dynamic>? data,
  }) async {
    // This would typically be called from a Cloud Function or backend
    // For client-side, we can send to topic
    debugPrint('Sending notification to user_$userId: $title - $body');
  }

  // Get current FCM token
  String? get fcmToken => _fcmToken;
}