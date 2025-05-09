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
    var link: String
    var starttime: String?
    var endtime: String?
    var coord: [Double]?
//    var category: String
    
    var image: Image{
        //        if location.contains("Janet"){
        //            return Image("Janet Wallace Fine Arts Center")
        //        } else if location.contains("Olin")
        //       
        //    }
        if UIImage(named: location) != nil{
            Image(location)
        } else {
            Image("MacLogo")
        }
    }
//    func getDate() -> Date {
//        let currentDate = Date()
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "EEEE, MMMM dd, yyyy"
//        let formattedDate = dateFormatter.string(from: currentDate)
//        print(formattedDate)
//        return formattedDate
//    }/  
    
    func formatDate() -> Date {
        let eventDate = self.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMMM dd, yyyy"
        let formattedEventDate = dateFormatter.date(from: eventDate)
        return formattedEventDate!
    }
        
        

//        var month: String
//        let noDayDate : String
//        
//        let space = self.date.firstIndex(of: " ")!
//        noDayDate = String(self.date[space...])
//        let monthSpace = noDayDate.firstIndex(of: " ")!
//        month = String(noDayDate[...monthSpace])
//        let dateAndYear = noDayDate[space...]
//        let formattedDate = dateFormatter.string(from: noDayDate)
        
//        switch month  {
//        case "January":
//            month = "Jan"
//        case "February":
//            month = "Feb"
//        case "March":
//            month = "Mar"
//        case "April":
//            month = "Apr"
//        case "May":
//            month = "May"
//        case "June":
//            month = "Jan"
//        case "July":
//            month = "Jan"
//        case "August":
//            month = "Aug"
//        case "September":
//            month = "May"
//        case "June":
//            month = "Jan"
//        case "July":
//            month = "Jan"
//        case "August":
//            month = "Aug"
//        default:
//            <#otherwise, do something else#>
//        }
        
    

  
    
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

