import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/medicament.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        // Gérer le tap sur la notification
      },
    );

    // Demander les permissions au démarrage
    await requestPermissions();
  }

  Future<void> scheduleNotification(Medicament medicament) async {
    if (!medicament.rappelActive) return;

    final now = DateTime.now();
    final scheduledDate = medicament.rappel;

    // Si la date est dans le passé, on programme pour le lendemain
    if (scheduledDate.isBefore(now)) {
      final tomorrow = DateTime(
        now.year,
        now.month,
        now.day + 1,
        scheduledDate.hour,
        scheduledDate.minute,
      );
      await _scheduleNotification(medicament, tomorrow);
    } else {
      await _scheduleNotification(medicament, scheduledDate);
    }
  }

  Future<void> _scheduleNotification(
      Medicament medicament, DateTime scheduledDate) async {
    final androidDetails = AndroidNotificationDetails(
      'medication_channel',
      'Rappels de médicaments',
      channelDescription: 'Canal pour les rappels de médicaments',
      importance: Importance.max,
      priority: Priority.high,
      enableLights: true,
      enableVibration: true,
    );

    final iosDetails = const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      medicament.id.hashCode,
      'Rappel de médicament',
      'Il est temps de prendre ${medicament.nom} (${medicament.dose})',
      tz.TZDateTime.from(scheduledDate, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelNotification(Medicament medicament) async {
    await _notifications.cancel(medicament.id.hashCode);
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  Future<void> requestPermissions() async {
    final android = await _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      await android.requestNotificationsPermission();
    }

    // Pour iOS, les permissions sont déjà demandées dans l'initialisation
  }
}
