//
//  HomePageRow.swift
//  MacEvents
//
//  Created by Iren Sanchez on 3/28/25.
//

import Foundation
import SwiftUI


struct HomePageRow: View {
    var categoryName: String
    var sampleEvents: [Event]
    
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(categoryName)
                .font(.headline)
                .padding(.leading,15)
                .padding(.top,5)
            ScrollView(.horizontal,showsIndicators: false) {
                HStack(alignment: .top, spacing: 10) {
                    ForEach(sampleEvents) { event in
                        Text(event.title)
                    }
//                    for event in sampleEvents {
//                        /*@START_MENU_TOKEN@*/Text(event.title)/*@END_MENU_TOKEN@*/
//                    }
                    
//                    }
                    
                }
            }
        }
        .frame(height: 105)
    }
}
#Preview {
//    var event1 = "event1"
//    var event2 = "event2"
//    var event3 = "event3"

//    HomePageRow(categoryName: "Tomorrow",
//                sampleEvents: Array(repeating: "sample", count: 4))
//    HomePageRow(categoryName: "Event.date",
//                sampleEvents: Array(repeating: "sample", count: 4))
}
