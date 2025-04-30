//
//  MapView.swift
//  MacEvents
//
//  Created by Iren Sanchez on 3/19/25.
//

import SwiftUI
import MapKit

struct MapView: View {
    var body: some View {
        Map(initialPosition: .region(region))
        
    }
    private var region: MKCoordinateRegion{
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 44.938056, longitude:-93.168494),
            span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        )
    }
    var event: Event
//    var mapCoordinate: MKPointAnnotation? {
//        var latitude = event.coord? [0]
//        var longitude = event.coord? [1]
////        self.mapCoordinate?.coordinate = CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!)
////    }
}

#Preview {
    MKMapView()
}
