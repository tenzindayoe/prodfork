//
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
                    .frame(height:350)
                    .padding(.top,-230)
            }
            CircleImage(image:event.image)
                .offset(y: -130)
                .padding(.bottom,-130)
            VStack(alignment: .leading) {
                Text(event.title)
                    .font(.title)
                Divider()
                Text("Date: \(event.date)")
                Text(event.link)
                Text(event.description)
            }
            .padding(.leading)
        }
        .navigationTitle(event.title).bold()
    }
}

#Preview {
    let sampleEvent = Event(
            id: "hi",
            title: "Sample Event",
            location: "Janet Wallace Fine Arts Center",
            date: "March 13th, 2025",
            time: "2:00 pm",
            description: "test description",
            link: "test link",
            starttime: "1400",
            endtime: "1600",
            coord: [1.00, 2.05]
            )
    EventDetail(event: sampleEvent)
}

