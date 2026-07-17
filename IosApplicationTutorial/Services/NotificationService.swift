import Foundation
import UserNotifications

class NotificationService {

    static let shared = NotificationService()

    private let center = UNUserNotificationCenter.current()

    func requestPermission() {
        center.requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    func scheduleDailyChallenge(hour: Int, minute: Int) {
        let identifiers = ["dailyChallenge"] + (1...7).map { "dailyChallenge_\($0)" }
        center.removePendingNotificationRequests(withIdentifiers: identifiers)

        for weekday in 1...7 {
            let content = UNMutableNotificationContent()
            content.title = "Today's Challenge 🎮"
            
            let description: String
            switch weekday {
            case 1, 4:
                description = "Score 1,000+ points in Tap Frenzy!"
            case 2, 5:
                description = "Score 15+ points in Light It Up!"
            default:
                description = "Score 50+ points in Quiz Rush!"
            }
            
            content.body = "Can you complete today's quest? \(description)"
            content.sound = .default

            var dateComponents = DateComponents()
            dateComponents.hour = hour
            dateComponents.minute = minute
            dateComponents.weekday = weekday

            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let request = UNNotificationRequest(identifier: "dailyChallenge_\(weekday)", content: content, trigger: trigger)

            center.add(request)
        }
    }

    func cancelAll() {
        center.removeAllPendingNotificationRequests()
    }
}
