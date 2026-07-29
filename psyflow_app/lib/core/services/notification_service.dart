import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import '../theme/app_colors.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    initializeTimeZones();

    await _requestPermissions();
    await _initLocalNotifications();
    await _configureFCM();

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

    await androidPlugin?.createNotificationChannel(const AndroidNotificationChannel(
      'appointment_reminders',
      'Lembretes de Consulta',
      description: 'Notificações para consultas agendadas',
      importance: Importance.high,
    ));

    await androidPlugin?.createNotificationChannel(const AndroidNotificationChannel(
      'task_reminders',
      'Lembretes de Tarefas',
      description: 'Notificações para tarefas terapêuticas pendentes',
      importance: Importance.high,
    ));

    await androidPlugin?.createNotificationChannel(const AndroidNotificationChannel(
      'mood_reminders',
      'Lembretes de Humor',
      description: 'Lembretes para registrar o humor diário',
      importance: Importance.defaultImportance,
    ));

    await androidPlugin?.createNotificationChannel(const AndroidNotificationChannel(
      'chat_messages',
      'Mensagens do Chat',
      description: 'Novas mensagens no chat terapêutico',
      importance: Importance.high,
    ));

    await androidPlugin?.createNotificationChannel(const AndroidNotificationChannel(
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

    final token = await _messaging.getToken();
    if (token != null) {
      await _saveTokenToFirestore(token);
    }
  }

  Future<void> _saveTokenToFirestore(String token) async {
    // Implementation would save to Firestore
    // await FirebaseFirestore.instance.collection('users').doc(userId).update({'fcm_token': token});
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
  }

  Future<void> _showLocalNotification({
    required int id,
    required String title,
    required String body,
    String payload = '',
    String channelId = 'general',
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'general',
      'Gerais',
      channelDescription: 'Notificações gerais do aplicativo',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: AppColors.primary,
      playSound: true,
      enableVibration: true,
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

    await _localNotifications.show(id, title, body, details, payload: payload);
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
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
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
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
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
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
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
}