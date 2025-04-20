//
//  Event.swift
//  MacEvents
//
//  Created by Iren Sanchez on 3/23/25.
//

import Foundation
import SwiftUI
import CoreLocation


struct Event: Identifiable, Codable {
    var id: String
    var title: String
    var location: String
    var date: String
    var time: String?
    var description: String
    var favorited = false
//    var category: String
    
    var image: Image{
        Image(location)
    }
//    private var coordinates : Coordinates
//    var locationCoordinate: CLLocationCoordinate2D{
//        CLLocationCoordinate2D(
//            latitude: coordinates.latitude,
//            longitude: coordinates.longitude)
//    }
//        
//    struct Coordinates: Hashable,Codable {
//        var latitude: Double
//        var longitude: Double
//    }
    
    func getDate() -> String {
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YY,MMM d"
        let formattedDate = dateFormatter.string(from: currentDate)
        print(formattedDate)
        return formattedDate
    }
    
//    mutating func setCategory(event: Event){
//        let currentDate = getDate()
//        let eventDate = event.date
//        if currentDate == eventDate {
//            self.category = "Today"
//        }
//        else {
//            self.category = currentDate
//        }
//    }
    
//    mutating func favorite(){
//        self.favorited = true
//    }
    
}

