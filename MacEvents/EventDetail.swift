//  EventDetail.swift
//  MacEvents
//
//  Created by Iren Sanchez on 4/23/25.
//

import Foundation
import SwiftUI

struct EventDetail: View {
    let event: Event
    
    var body: some View {
        VStack{
            if event.coord != nil {
                LocationMap(event: event)
                    .frame(height:400)
                    .padding(.top,-90)
                CircleImage(image:event.image)
                    .offset(y: -130)
                    .padding(.bottom,-130)
                VStack(alignment: .leading) {
                    Text(event.title)
                        .font(.title2)
                        .bold()
                    Text(event.date)
                        .font(.title3)
                        .bold()
                    Divider()
                    ScrollView {
                        Text(event.description)
                        Spacer()
                        Link("More Info",
                             destination: URL(string: event.link)!)

                    }
                }
                .padding(.leading)
            } else {
                CircleImage(image:Image("MacLogoTextless"))
                    .offset(y: -130)
                    .padding(.bottom,-130)
                    .padding(.top, 140)
                VStack(alignment: .leading) {
                    Text(event.title)
                        .font(.title2)
                        .bold()
                    Text(event.date)
                        .font(.title3)
                        .bold()
                    Divider()
                    ScrollView {
                        Text(event.description)
                        Spacer()
                        Link("More Info",
                             destination: URL(string: event.link)!)

                    }
                }
                .padding(.leading)
            }

        }
        .navigationTitle(event.title).
    }
}

#Preview {
    let sampleEvent = Event(
            id: "hi",
            title: "Sample Event",
            location:"Macalester",
            date: "March 13th, 2025",
            time: "2:00 pm",
            description: "test description",
            link: "google.com",
            starttime: "1400",
            endtime: "1600",
            coord: nil
            )
    EventDetail(event: sampleEvent)
}
