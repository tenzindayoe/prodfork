//
//  MacEventsApp.swift
//  MacEvents
//
//  Created by Iren Sanchez on 3/14/25.
//

import SwiftUI

@main
struct MacEventsApp: App {
    var body: some Scene {
        WindowGroup {
//            Event(title: "Sample", place: "SamplePlace", date: "June 30", time: "12:00-1:00", description: "Dexpriction", coordinates: 44.938056,-93.168494)
            ContentView()
        }
        
    }
    init() {
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
    }
}
