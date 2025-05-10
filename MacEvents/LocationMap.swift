//
//  LocationMap.swift
//  MacEvents
//
//  Created by Marvin Swift on 4/30/25.
//

import SwiftUI
import MapKit

public struct LocationMap: View {
    var event: Event
    
    init(event: Event) {
        self.event = event
    }
    
    public var body: some View {
        let eventCoord: CLLocationCoordinate2D = CLLocationCoordinate2D(
                                                    latitude: event.coord![0],
                                                    longitude: event.coord![1])
        
        let campusCenter: CLLocationCoordinate2D = CLLocationCoordinate2D(
                                                    latitude: 44.937913,
                                                    longitude: -93.168521)
        
        let region: MKCoordinateRegion = MKCoordinateRegion(
                                            center: campusCenter,
                                            latitudinalMeters: 450,
                                            longitudinalMeters: 60)
        
        Map(initialPosition: .region(region),
            bounds: MapCameraBounds(
                centerCoordinateBounds: region,
                maximumDistance: 1100),
            interactionModes: [MapInteractionModes.zoom,
                               MapInteractionModes.pan]
            ) {
                    Marker(coordinate: eventCoord) {
                        Text(event.location)
                    }
                    UserAnnotation()
                }
                .mapStyle(.hybrid)
    }
}

#Preview {
    let event: Event = Event(id: "10",
                             title: "FreakCon",
                             location: "Janet Wallace Fine Arts Center",
                             date: "Saturday, May 10, 2025",
                             description: "FreakCon 2025 2nd Bicentennial Anniversary",
                             link: "google.com",
                             coord: [44.93749, -93.16959])
    
    LocationMap(event: event)
}
