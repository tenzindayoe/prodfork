//
//  EventHome.swift
//  MacEvents
//
//  Created by Iren Sanchez on 3/26/25.
//

import Foundation
import SwiftUI
import UserNotifications


struct EventHome: View {
    
    @State var todayEvents: [Event] = []
    @State var tomorrowEvents: [Event] = []

    var body: some View {
//        let todaySampleEvent = Event(title: "Sample Event", place: "JanetWallace", date: "March 13th, 2025", time: "2:00 pm", description: "Cool event")
//        let todaySampleEvent2 = Event(title: "Sample Event", place: "JanetWallace", date: "March 13th, 2025", time: "2:00 pm", description: "Cool event")
//        let todaySampleEvent3 = Event(title: "Sample Event", place: "JanetWallace", date: "March 13th, 2025", time: "2:00 pm", description: "Cool event")
//        let sampleEvent1 = Event(title: "Sample Event", place: "JanetWallace", date: "March 13th, 2025", time: "2:00 pm", description: "Cool event")
//        let sampleEvent2 = Event(title: "Sample Event", place: "JanetWallace", date: "March 13th, 2025", time: "2:00 pm", description: "Cool event")
//        let todaySampleEvents = [todaySampleEvent,todaySampleEvent2,todaySampleEvent3]
//        let otherSampleEvents = [sampleEvent1, sampleEvent2]

        NavigationSplitView {
            MapView()
                .navigationTitle("MacEvents")

            // test button for notifications
            
            Button() {
                Task {
                    await scheduleNotification()
                }
            } label: {
                Text("Schedule Notification!")
            }

        } detail: {
            Text("Select Event")
        }
        .task {
            do {
                let url = URL(string: "http://127.0.0.1:5000/events")!
                let (data, _) = try await URLSession.shared.data(from: url)
                
                let events = try JSONDecoder().decode([Event].self, from: data)
                todayEvents = events
            } catch {
                print("Yuck! Error getting event data:", error)
            }
        }
    }
    
    // Notification function
    func scheduleNotification() async  {
        let center = UNUserNotificationCenter.current()
        
        // Asking the user for permission
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .badge, .sound])
            if granted {
                print(" Permission granted")
            } else {
                print("Permission denied")
                return
            }
        } catch {
            print("Failed to request authorization: \(error)")
            return
        }
        
        // Making the message
        let content = UNMutableNotificationContent()
        content.title = "Alumni Meet and Greet!"
        content.body = "Join us for a fun evening of networking!"
        content.sound = .default
        
        // Set time to 10:00 AM every day, this will later on be changed to event time and day, 10Am is just an example
        var dateComponents = DateComponents()
        dateComponents.hour = 14
        dateComponents.minute = 55
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        // Creating the request
        let uuidString = UUID().uuidString
        let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
        
        // Add the notification
        do {
            try await center.add(request)
            print("Notification scheduled with ID: \(uuidString)")
        } catch {
            print("Failed to schedule notification: \(error)")
        }
    }
}
#Preview{
    EventHome()
}
