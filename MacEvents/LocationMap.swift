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
    let locationManager: CLLocationManager = CLLocationManager()
    
    init(event: Event) {
        self.event = event
    }
    
    public var body: some View {
        let eventCoord: CLLocationCoordinate2D = CLLocationCoordinate2D(
            latitude: event.coord![0],
            longitude: event.coord![1])
        
        let region: MKCoordinateRegion =
        (locationManager.authorizationStatus == CLAuthorizationStatus.authorizedWhenInUse
         && locationManager.location != nil) ?
        MKCoordinateRegion(
            center: midpointBetweenPoints(
                coord1: eventCoord,
                coord2: locationManager.location!.coordinate),
            span: MKCoordinateSpan(
                latitudeDelta: distanceBetweenPoints(
                    coord1: eventCoord,
                    coord2: locationManager.location!.coordinate),
                longitudeDelta: distanceBetweenPoints(
                    coord1: eventCoord,
                    coord2: locationManager.location!.coordinate))) :
        MKCoordinateRegion(
            center: eventCoord,
            span: MKCoordinateSpan(
                latitudeDelta: 0.01,
                longitudeDelta: 0.01)
        )
        
        
        Map(initialPosition: .region(region),
            bounds: MapCameraBounds(
                centerCoordinateBounds: region,
                minimumDistance: 450,
                maximumDistance: 450)) {
                    Marker(coordinate: eventCoord) {
                        Text(event.location)
                    }
                    UserAnnotation()
                }
                .mapStyle(.hybrid)
    }
    
    func midpointBetweenPoints(coord1: CLLocationCoordinate2D, coord2: CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        
        let newLat: Double = (coord1.latitude + coord2.latitude) / 2
        let newLong: Double = (coord1.longitude + coord2.longitude) / 2
        return CLLocationCoordinate2D(latitude: newLat, longitude: newLong)
    }
    
    func distanceBetweenPoints(coord1: CLLocationCoordinate2D, coord2: CLLocationCoordinate2D) -> CLLocationDegrees {
        
        let distX: Double = coord1.latitude - coord2.latitude
        let distY: Double = coord1.longitude - coord2.longitude
        return sqrt(pow(distX, 2) + pow(distY, 2))
    }

}
