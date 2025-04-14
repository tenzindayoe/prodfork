//
//  EventHome.swift
//  MacEvents
//
//  Created by Iren Sanchez on 3/26/25.
//

import Foundation
import SwiftUI

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
            
            HomePageRow(categoryName: "Today",
                        sampleEvents: todayEvents)

            HomePageRow(categoryName: "Tomorrow",
                        sampleEvents: tomorrowEvents)

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
}
#Preview{
    EventHome()
}
