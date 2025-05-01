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
//    var description: String
    var link: String
    var starttime: String?
    var endtime: String?
    var coord: [Double]?
//    var category: String
    
    var image: Image{
        if UIImage(named: location) != nil{
            Image(location)
        } else {
            Image("MacLogo")
        }
    }
    
    func getDate() -> String {
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, YYYY"
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

