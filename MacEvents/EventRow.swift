//
//  EventRow.swift
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
                Text(event.title)
                Text(event.place)
                Text(event.date)
            }
            Spacer()
        }
    }
    
}


#Preview {
    var e = Event(title: "Library hours")
    EventRow(event: e)
}

// test push/pull
