import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_service.dart';

// This must be a top-level function for AlarmManager
@pragma('vm:entry-point')
Future<void> checkAndNotifyCallback() async {
  // Initialize services in isolate
  final prefs = await SharedPreferences.getInstance();

  // Check if reminders are enabled (default: true)
  final remindersEnabled = prefs.getBool('expense_reminders_enabled') ?? true;
  if (!remindersEnabled) return;

  // Check if we already sent a notification today
  final lastNotificationDate = prefs.getString('last_notification_date');
  final today = DateTime.now().toIso8601String().split('T')[0];

  if (lastNotificationDate == today) {
    // Already notified today
    return;
  }

  // Check if there are expenses for today
  final lastTransactionDate = prefs.getString('last_transaction_date');
  final hasExpenses = lastTransactionDate == today;

  if (!hasExpenses) {
    // No expenses today, send notification
    await NotificationService.instance.initialize();
    await NotificationService.instance.showExpenseReminder();

    // Mark as notified for today
    await prefs.setString('last_notification_date', today);
  }
}

class AlarmService {
  static final AlarmService instance = AlarmService._init();
  static const int alarmId = 0;

  AlarmService._init();

  Future<void> initialize() async {
    await AndroidAlarmManager.initialize();
  }

  Future<void> scheduleDaily8PMCheck() async {
    // Cancel any existing alarm
    await AndroidAlarmManager.cancel(alarmId);

    // Calculate next 8 PM
    final now = DateTime.now();
    var scheduledTime = DateTime(now.year, now.month, now.day, 20, 0, 0);

    // If it's already past 8 PM today, schedule for tomorrow
    if (now.isAfter(scheduledTime)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    // Schedule recurring daily alarm at 8 PM
    await AndroidAlarmManager.periodic(
      const Duration(days: 1),
      alarmId,
      checkAndNotifyCallback,
      startAt: scheduledTime,
      exact: true,
      wakeup: true,
      rescheduleOnReboot: true,
    );
  }

  Future<void> cancelAlarm() async {
    await AndroidAlarmManager.cancel(alarmId);
  }
}
