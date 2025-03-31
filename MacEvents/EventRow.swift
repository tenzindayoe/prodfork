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
//    var sampleevent= Event(title: , place: <#T##String#>, date: <#T##String#>, time: <#T##String#>, description: <#T##String#>, favorited: <#T##Bool#>, category: <#T##Category#>, coordinates: <#T##Coordinates#>)
//    EventRow(event: T##Event)
}
