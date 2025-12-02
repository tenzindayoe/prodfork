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
    @StateObject private var attendance = AttendanceStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(liked)
                .environmentObject(attendance)
        }
    }
    
    init() {}
}
