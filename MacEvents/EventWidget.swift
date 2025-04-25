//
//  EventWidget.swift
//  MacEvents
//
//  Created by Iren Sanchez on 3/28/25.
//

import SwiftUI
struct EventWidget: View {
    var event: Event
    var body: some View{
            
        VStack (alignment: .leading){
                event.image
                    .resizable()
                Text(event.title).bold()
                Text(event.location)
                Text(event.date)
//            Text(event.coord.joined(separator: ,))
        }
        .padding(20)
        Spacer()
    }
}
#Preview {
    let sampleEvent = Event(id: "hi", title: "Sample Event", location: "Janet Wallace Fine Arts Center", date: "March 13th, 2025", time: "2:00 pm",link: "test link", coord: [1.00, 2.05])
    
    EventWidget(event: sampleEvent)
}

// test push/pull
