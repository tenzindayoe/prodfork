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
    var events: [Event]
    var body: some View {
        Map(initialPosition: .region(region))
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
