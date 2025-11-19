//
//  Event.swift
//  MacEvents
//  A structure that creates event object.
//  Created by Iren Sanchez on 3/23/25.
//

import Foundation
import SwiftUI
import CoreLocation
import UIKit

///
///
///
///
/// A struct that represents a Macalester event
///
///
///
struct ConfigData: Codable {
    let urls: [String]
    let locationImages: [String: String]
}


class ConfigManager {
    static let shared = ConfigManager()
    var config: ConfigData?

    private init() {
        self.config = loadConfig()
    }

    private func loadConfig() -> ConfigData? {
        guard let url = Bundle.main.url(forResource: "Config", withExtension: "json") else {
            print("❌ Config.json not found in bundle")
            return nil
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode(ConfigData.self, from: data)
            return decoded
        } catch {
            print("❌ Error reading Config.json: \(error)")
            return nil
        }
    }
}


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
    
    func checkIfDateIsNull() -> Bool {
        return self.date.isEmpty
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
            let imageName: String = {
                guard let locationImages = ConfigManager.shared.config?.locationImages else {
                    return defaultImage
                }
                if let match = locationImages.first(where: { location.contains($0.key) }) {
                    return match.value
                }
                return defaultImage
            }()

            if UIImage(named: imageName) != nil {
                return Image(imageName)
            }
            return Image(systemName: "photo")
    }
}
