//
//  EventHome.swift
//  MacEvents
//
//  Created by Iren Sanchez on 3/26/25.
//

import Foundation
import SwiftUI
import UserNotifications
import CoreLocation

///
/// The main view of the app, a list of stacked homepage columns
///
struct EventHome: View {
    let locationManager = CLLocationManager()
    @State private var favoriteEventIDs: Set<String> = []
    @State var allEvents: [Event] = []
    
    var todayEvents: [Event] {
        let currentTime = Date()
        return allEvents.filter { event in
            let eventDate = event.formatDate()
            return Calendar.current.isDate(eventDate, inSameDayAs: currentTime)
        }
    }
    var tomorrowEvents: [Event] {
        let calendar = Calendar.current
        let currentTime = Date()
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: currentTime)!
        return allEvents.filter { event in
            let eventDate = event.formatDate()
            return Calendar.current.isDate(eventDate, inSameDayAs: tomorrow)
        }
    }
    var futureEvents: [Event] {
        let calendar = Calendar.current
        let currentTime = Date()
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: currentTime)!
        return allEvents.filter { event in
            let eventDate = event.formatDate()
            return eventDate > tomorrow
        }
        .sorted(by: <)
    }
    var body: some View {
        

        NavigationSplitView {
            ScrollView(.vertical,showsIndicators: false) {
                HomePageColumn(
                    categoryName: "Today",
                    eventArray: todayEvents,
                    favoriteEventIDs: $favoriteEventIDs)
                HomePageColumn(
                    categoryName: "Tomorrow",
                    eventArray: tomorrowEvents,
                    favoriteEventIDs: $favoriteEventIDs)
                HomePageColumn(
                    categoryName: "Future Events",
                    eventArray: futureEvents,
                    favoriteEventIDs: $favoriteEventIDs)
            }
            .navigationTitle("MacEvents")

        } detail: {
            Text("Select Event")
        }
        .onAppear {
            // Optional permission for placing user pin on map
            locationManager.requestWhenInUseAuthorization()
        }
        .task {
            // Calling to request notification permission
               NotificationManager.shared.requestPermission()
            
            // API call to server to retrieve events data
            do {
                let url = URL(string: "http://127.0.0.1:5000/events")!
                let (data, _) = try await URLSession.shared.data(from: url)
                
                let events = try JSONDecoder().decode([Event].self, from: data)
                allEvents = events
            } catch {
                print("Yuck! Error getting event data:", error)
            }
        }
    }
   
}
#Preview {
    EventHome()
}
