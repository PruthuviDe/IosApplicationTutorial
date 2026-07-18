import Foundation
import UserNotifications

class NotificationService: NSObject, UNUserNotificationCenterDelegate {

    static let shared = NotificationService()

    private let center = UNUserNotificationCenter.current()

    private override init() {
        super.init()
        center.delegate = self
    }

    func requestPermission() {
        center.requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }

    func scheduleDailyChallenge(hour: Int, minute: Int) {
        let identifiers = ["dailyChallenge"] + (1...7).map { "dailyChallenge_\($0)" } + ["dailyChallenge_test"]
        center.removePendingNotificationRequests(withIdentifiers: identifiers)

        let calendar = Calendar.current
        let now = Date()
        let currentHour = calendar.component(.hour, from: now)
        let currentMinute = calendar.component(.minute, from: now)
        
        if hour == currentHour && minute == currentMinute {
            let content = UNMutableNotificationContent()
            content.title = "Quest Test Notification 🎮"
            
            let weekday = calendar.component(.weekday, from: now)
            let description: String
            switch weekday {
            case 1, 4:
                description = "Score 1,000+ points in Tap Frenzy!"
            case 2, 5:
                description = "Score 15+ points in Light It Up!"
            default:
                description = "Score 50+ points in Quiz Rush!"
            }
            
            content.body = "Alert setup successful! Today's quest: \(description)"
            content.sound = .default
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
            let request = UNNotificationRequest(identifier: "dailyChallenge_test", content: content, trigger: trigger)
            center.add(request)
        }

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
