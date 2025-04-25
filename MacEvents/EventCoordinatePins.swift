//
//  EventCoordinatePins.swift
//  MacEvents
//
//  Created by Marvin Contreras on 4/19/25.
//

import Foundation
import SwiftUI
import MapKit

struct EventCoordinatePins: View {
    @State var events: [Event] = []
   
    var body: some View {
        Map(initialPosition: .region(region))
        
        VStack {
            ForEach(events) { event in
                Text(event.title)
            }
        }
        
        .task {
            do {
                let url = URL(string: "http://127.0.0.1:5000/events")!
                let (data, _) = try await URLSession.shared.data(from: url)
                    
                let eventData = try JSONDecoder().decode([Event].self, from: data)
                events = eventData
                
                print("success")
            } catch {
                print("Yuck! Error getting event data:", error)
            }
        }
    }
    private var region: MKCoordinateRegion{
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 44.938056, longitude:-93.168494),
            span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        )
    }
    
}

#Preview {
    EventCoordinatePins()
}
