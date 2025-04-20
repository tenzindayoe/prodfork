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
        HStack{
            event.image
                .resizable()
            VStack{
                Text(event.title).bold()
                Text(event.location)
                Text(event.date)
            }
            Spacer()
        }
    }
}
#Preview {
    let sampleEvent = Event(id: "HI" , title: "Sample Event", location: "JanetWallace", date: "March 13th, 2025", time: "2:00 pm", description: "Cool event")
    
    EventWidget(event: sampleEvent)
}

// test push/pull
