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
            NavigationLink{
                EventDetail(event:event)
            } label: {
                event.image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
            }
            VStack (alignment: .leading){
                NavigationLink{
                    EventDetail(event:event)
                } label: {
                    Text(event.title).bold().multilineTextAlignment(.leading)
                }
                Text(event.date).multilineTextAlignment(.leading)
                Text(event.location).multilineTextAlignment(.leading)
            }
            //            .padding(20)
            Spacer()
            //        }
        }
    }
}

#Preview {
    let sampleEvent = Event(
            id: "hi",
            title: "Sample Event Really really long title",
            location: "Janet Wallace Fine Arts Center",
            date: "March 13th, 2025",
            time: "2:00 pm",
            description: "test description",
            link: "test link",
            starttime: "1400",
            endtime: "1600",
            coord: [1.00, 2.05]
            )
    
    EventWidget(event: sampleEvent)
}

// test push/pull
