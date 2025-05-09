//
//  Notifications.swift
//  MacEvents
//
//  Created by Nimo Mohamed  on 5/9/25.
//
import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    
   
    // requesting persmisson from the user
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else {
                print("Notification denied")
            }

            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }

   
    // Function to schedule a notification for a specific event
    func scheduleNotification(for event: Event) {
        let date = event.formatDate().addingTimeInterval(-3600)
        guard date > Date() else { return }

        //notification content
        let content = UNMutableNotificationContent()
        content.title = "\(event.title) starts soon"
        content.body = "Location: \(event.location)"
        content.sound = .default

        
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        // timeInterval is 5 just for test pourposes,so the notification will show 5sec after the event if favorited
        // change 5 back to  "NotificationDelegate.swift" to get notification for an event 
        
        let request = UNNotificationRequest(identifier: event.id, content: content, trigger: trigger)

        // Add the notification to the system
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Notification error: \(error.localizedDescription)")
            }
        }
    }

    // Function to cancel a previously scheduled notification for an event
    func cancelNotification(for event: Event) {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [event.id])
    }
}

