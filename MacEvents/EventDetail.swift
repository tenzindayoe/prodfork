//  EventDetail.swift
//  MacEvents
//
//  Created by Iren Sanchez on 4/23/25.
//

import Foundation
import SwiftUI
import CoreLocation
import MapKit

///
/// The navigation view page where all event details
/// are available after clicking on corresponding event widget
/// 
struct EventDetail: View {
    let event: Event
    
    var body: some View {
        VStack{
            if event.coord != nil {
                let defaultTime = "None Specified"
                
                LocationMap(event: event)
                    .frame(height:550)
                    .padding(.top,-100)
                    .offset(y: 20)
                
                CircleImage(image:event.circleImage)
                    .offset(y: -130)
                    .padding(.bottom,-130)
                
                VStack(alignment: .leading) {
                    Text(event.title)
                        .font(.title2)
                        .bold()
                    Text(event.date)
                        .font(.title3)
                        .bold()
                    Text("Time: \(event.time ?? defaultTime)")
                    
                    Divider()
                    
                    ScrollView {
                        VStack{
                            Text(event.description)
                            Spacer()
                        }.frame(width: 410)
                    }
                    
                    VStack {
                        Link("More Info",
                             destination: URL(
                                string: event.link)!)
                    } .frame(width: 410, alignment: .center)
                }
                .padding(.leading)
            } else {
                let defaultTime = "None Specified"
                
                CircleImage(image:Image("MacLogoTextless"))
                    .offset(y: -130)
                    .padding(.bottom,-130)
                    .padding(.top, 140)
                
                VStack(alignment:.leading) {
                    Text(event.title)
                        .font(.title2)
                        .bold()
                    Text(event.date)
                        .font(.title3)
                        .bold()
                    Text("Time: \(event.time ?? defaultTime)")
                    
                    Divider()
                    
                    ScrollView {
                        VStack{
                            Text(event.description)
                            Spacer()
                        }
                        .frame(width: 410)
                    }
                    
                    VStack {
                        Link("More Info",
                             destination: URL(
                                string: event.link)!)
                    }
                    .frame(width: 410, alignment: .center)
                }
                .padding(.leading)
               
            }

        }
    }
}

#Preview {
    let sampleEvent = Event(
            id: "hi",
            title: "Sample Event",
            location:"Macalester",
            date: "Sunday, March 13th, 2025",
            time: nil,
            description: "test description",
            link: "google.com",
            starttime: "1400",
            endtime: "1600",
            coord: [44.93749, -93.16959]
            )
    EventDetail(event: sampleEvent)
}
