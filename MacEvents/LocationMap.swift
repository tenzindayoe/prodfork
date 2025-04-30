//
//  LocationMap.swift
//  MacEvents
//
//  Created by Marvin Contreras on 4/30/25.
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
        
        let region: MKCoordinateRegion =
            MKCoordinateRegion(
                center: eventCoord,
                span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
            )
        
        Map(initialPosition: .region(region),
            bounds: MapCameraBounds(centerCoordinateBounds: region,
                                    minimumDistance: 450,
                                    maximumDistance: 450)) {
                
                Marker(coordinate: eventCoord) {
                    Text(event.location)
            }
        }
    }
}
