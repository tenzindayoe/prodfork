//
//  Event.swift
//  MacEvents
//
//  Created by Iren Sanchez on 3/23/25.
//

import Foundation
import SwiftUI
import CoreLocation


struct Event: Hashable, Codable{
    var title: String
    var place: String
    var date: String
    var time: String
    var description: String
    var favorited: Bool
    
    
    var category: Category
    enum Category: String, CaseIterable, Codable{
        case today = "Featured Events Today"
        case tomorrow = "Events happening tomorrow"
//        case date = "Events on" + event.date
    }
    var image: Image{
        Image(place)
    }
    private var coordinates : Coordinates
    var locationCoordinate: CLLocationCoordinate2D{
        CLLocationCoordinate2D(
            latitude: coordinates.latitude,
            longitude: coordinates.longitude)
    }
        
    struct Coordinates: Hashable,Codable {
        var latitude: Double
        var longitude: Double
    }
    
}

