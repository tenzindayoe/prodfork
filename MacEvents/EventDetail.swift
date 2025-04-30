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
            event.image
            Text(event.date).bold()
            Text(event.link)
        }
        .navigationTitle(event.title)
    }
}
#Preview {
    let sampleEvent = Event(
            id: "hi",
            title: "Sample Event",
            location: "Janet Wallace Fine Arts Center",
            date: "March 13th, 2025",
            time: "2:00 pm",
            link: "test link",
            starttime: "1400",
            endtime: "1600",
            coord: [1.00, 2.05]
            )
    EventDetail(event: sampleEvent)
}

