//
//  EventWidget.swift
//  MacEvents
//
//  Created by Iren Sanchez on 3/28/25.
//

import SwiftUI
struct EventRow: View {
    var event: Event
    var body: some View{
        HStack{
            event.image
                .resizable()
            VStack{
                Text(event.title).bold()
                Text(event.location)
                Text(event.date)
                Text(event.description)
            }
            Spacer()
        }
    }
}
#Preview {
    let sampleEvent = Event(id: "hi", title: "Sample Event", location: "JanetWallace", date: "March 13th, 2025", time: "2:00 pm", description: "Cool event")
    
    EventRow(event: sampleEvent)
}

// test push/pull
