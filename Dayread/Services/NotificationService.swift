import UserNotifications

/// Local notification scheduling for daily study reminders
/// Port of src/lib/native/notifications.ts
enum NotificationService {
    private static let dailyReminderId = "dayread-daily-reminder"

    // MARK: - Permission

    static func requestPermission() async -> Bool {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        if settings.authorizationStatus == .authorized { return true }
        if settings.authorizationStatus == .denied { return false }
        return (try? await center.requestAuthorization(options: [.alert, .badge, .sound])) ?? false
    }

    static func checkPermission() async -> UNAuthorizationStatus {
        await UNUserNotificationCenter.current().notificationSettings().authorizationStatus
    }

    // MARK: - Daily Reminder

    static func scheduleDailyReminder(hour: Int) async -> Bool {
        guard await requestPermission() else { return false }
        await cancelDailyReminder()

        let content = UNMutableNotificationContent()
        content.title = "오늘의 영어 학습 시간이에요"
        content.body = "3분이면 충분해요. 오늘도 한 문장 시작해볼까요?"
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = max(0, min(23, hour))
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: dailyReminderId, content: content, trigger: trigger)

        do {
            try await UNUserNotificationCenter.current().add(request)
            return true
        } catch {
            return false
        }
    }

    static func cancelDailyReminder() async {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [dailyReminderId])
    }

    // MARK: - Settings Sync

    static func rescheduleIfNeeded(enabled: Bool, hour: Int) async {
        if enabled {
            _ = await scheduleDailyReminder(hour: hour)
        } else {
            await cancelDailyReminder()
        }
    }
}
