//
//  Event.swift
//  MacEvents
//  A structure that creates event object.
//  Created by Iren Sanchez on 3/23/25.
//

import Foundation
import SwiftUI
import CoreLocation


struct Event: Identifiable, Codable, Comparable {
    var id: String
    var title: String
    var location: String
    var date: String
    var time: String?
    var description: String
    var link: String
    var starttime: String?
    var endtime: String?
    var coord: [Double]?
    
    var image: Image{
        if location.contains("Janet"){
            return Image("Janet Wallace Fine Arts Center")
        } else if location.contains("Olin") {
            return Image ("Olin Rice")
        } else {
            return Image("MacLogo")
        }
        }
    
//        if UIImage(named: location) != nil{
//            Image(location)
//        } else {
//            Image("MacLogo")
//        }
//        }
    func formatDate() -> Date {
        let eventDate = self.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMMM dd, yyyy"
        let formattedEventDate = dateFormatter.date(from: eventDate)
        return formattedEventDate!
    }
    static func < (lhs : Event, rhs: Event ) -> Bool {
            return lhs.formatDate() < rhs.formatDate()
    }
    static func > (lhs : Event, rhs: Event ) -> Bool {
            return lhs.formatDate() > rhs.formatDate()
    }
    static func == (lhs : Event, rhs: Event ) -> Bool {
            return lhs.formatDate() == rhs.formatDate() && rhs.formatDate() == lhs.formatDate()
    }
    
}

