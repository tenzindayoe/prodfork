//
//  EventWidget.swift
//  MacEvents
//
//  Created by Iren Sanchez on 3/28/25.
//

import SwiftUI

///
/// A small rectangle showing the basic information of an event
///
struct EventWidget: View {
    var event: Event
    @Binding var favoriteEventIDs: Set<String>
    
    var body: some View {
        Spacer()
        HStack {
            NavigationLink{
                EventDetail(event:event)
            } label: {
                event.widgetImage
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
            }
            VStack (alignment: .leading) {
                NavigationLink{
                    EventDetail(event:event)
                } label: {
                    Text(event.title)
                        .bold().multilineTextAlignment(.leading)
                }
                Text(event.date)
                    .multilineTextAlignment(.leading)
                Text(event.location)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
            
            Button(action: {
                      if favoriteEventIDs.contains(event.id) {
                          favoriteEventIDs.remove(event.id)
                          NotificationManager.shared.cancelNotification(for: event)
                      } else {
                          favoriteEventIDs.insert(event.id)
                          NotificationManager.shared.scheduleNotification(for: event)
                      }
            }){
                Image(systemName: favoriteEventIDs.contains(event.id) ? "heart.fill" : "heart")
                          .foregroundColor(favoriteEventIDs.contains(event.id) ? .red : .gray)
                }
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
    
    return EventWidget(event: sampleEvent, favoriteEventIDs: .constant(Set<String>()))
}
