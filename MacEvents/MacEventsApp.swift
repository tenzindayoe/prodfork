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
            EventHome()
        }
    }
    
    init() {
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
    }
}
