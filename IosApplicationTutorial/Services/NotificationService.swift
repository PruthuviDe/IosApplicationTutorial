import Foundation
import UserNotifications

class NotificationService {

    static let shared = NotificationService()

    private let center = UNUserNotificationCenter.current()

    func requestPermission() {
        center.requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    func scheduleDailyChallenge(hour: Int, minute: Int) {
        center.removePendingNotificationRequests(withIdentifiers: ["dailyChallenge"])

        let content = UNMutableNotificationContent()
        content.title = "Daily Challenge 🎮"
        content.body = "Time to play! Open GameVault and beat your high score."
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "dailyChallenge", content: content, trigger: trigger)

        center.add(request)
    }

    func cancelAll() {
        center.removeAllPendingNotificationRequests()
    }
}
