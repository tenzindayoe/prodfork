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
    @State var selectedEvent: Event? = nil
    @State var events: [Event] = []
    @State var eventCoord: CLLocationCoordinate2D?
    
    private var region: MKCoordinateRegion =
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 44.938056, longitude:-93.168494),
            span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        )
    
    var body: some View {
        ScrollView {
            ForEach($events) { event in
                Button(action: {
                    selectedEvent = event.wrappedValue
                    print("Current selected event: \(selectedEvent!.title)")
                    if event.wrappedValue.coord != nil {
                        eventCoord = CLLocationCoordinate2D(latitude: event.wrappedValue.coord![0], longitude: event.wrappedValue.coord![1])
                        print("Current event coord: \(selectedEvent!.coord)")
                    } else {
                        eventCoord = nil
                    }
                }) {
                    EventWidget(event: event.wrappedValue)
                }
            }
        }
        
        Map(initialPosition: .region(region),
            bounds: MapCameraBounds(centerCoordinateBounds: region,
                                    minimumDistance: 450,
                                    maximumDistance: 450)) {
            if eventCoord != nil && selectedEvent != nil {
                Marker(coordinate: eventCoord!) {
                    Text(selectedEvent!.location)
                }
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
}

#Preview {
    EventCoordinatePins()
}
