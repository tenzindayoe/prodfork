//
//  Event.swift
//  MacEvents
//  A structure that creates event object.
//  Created by Iren Sanchez on 3/23/25.
//

import Foundation
import SwiftUI
import CoreLocation

///
/// A struct that represents a Macalester event
///
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
    var widgetImage: Image {
        return setImage(location: location, defaultImage: "MacLogo")
    }
    
    var circleImage: Image {
        return setImage(location: location, defaultImage: "MacLogoTextless")
    }
    
    /**
     Converts date string into a date object for comparison
     */
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
    
    /**
     Returns an image based on event location with a different default
     image depending on what the image is being used for
     */
    func setImage(location: String, defaultImage: String) -> Image {
        if location.contains("Janet"){
            return Image("Janet Wallace Fine Arts Center")
        } else if location.contains("Olin") {
            return Image ("Olin Rice")
        } else if location.contains("DeWitt") {
            return Image ("DeWitt Wallace Library")
        } else if location.contains("Music") {
            return Image ("Janet Wallace Fine Arts Center")
        } else if location.contains("Janet") {
            return Image ("Janet Wallace Fine Arts Center")
        } else if location.contains("Theater") {
                return Image ("Janet Wallace Fine Arts Center")
        } else if location.contains("Dance") {
                return Image ("Janet Wallace Fine Arts Center")
        } else if location.contains("Campus Center") {
                return Image ("Campus Center")
        } else if location.contains("Lawn") {
                return Image ("Great Lawn")
        } else if location.contains("Kagin") {
            return Image ("Kagin")
        } else if location.contains("Stadium") {
            return Image ("Stadium")
        } else if location.contains("Leonard") {
            return Image ("Leonard")
        } else if location.contains("Markim") {
            return Image ("MarkimHall")
        } else if location.contains("Main") {
            return Image ("OldMain")
        } else if location.contains("Chapel") {
            return Image ("Weyerhaeuser Chapel")
        } else if location.contains("Weyerhaeuser Hall") {
            return Image ("Weyerhaeuser Hall")
        } else {
            return Image(defaultImage)
        }
    }
}

