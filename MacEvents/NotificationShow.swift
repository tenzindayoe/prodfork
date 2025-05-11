//
//  NotificationShow.swift
//  MacEvents
//
//  Created by Nimo Mohamed  on 5/9/25.
//
import UserNotifications

///
/// A class representing the notification as delivered to the user
///
class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationDelegate()

    // This method is called when a notification is delivered while the app is running
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler:
                                   @escaping (UNNotificationPresentationOptions) -> Void) {
        
        completionHandler([.banner, .sound, .badge])
    }
}
