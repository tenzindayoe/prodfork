//
//  MacEventsApp.swift
//  MacEvents
//
//  Created by Iren Sanchez on 3/14/25.
//

import SwiftUI

@main
struct MacEventsApp: App {
    @StateObject private var liked = LikedStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(liked)
                
        }
    }
    
    init() {
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
    }
}
