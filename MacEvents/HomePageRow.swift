//
//  HomePageRow.swift
//  MacEvents
// Row of Widgets by Date 
//  Created by Iren Sanchez on 3/28/25.
//

import Foundation
import SwiftUI


struct HomePageRow: View {
    var categoryName: String
    var eventArray: [Event]
    // added this
    @Binding var favoriteEventIDs: Set<String>
    
    
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(categoryName)
                .font(.headline)
                .padding(.leading,-5)
                .padding(.top)
                .bold()
            //            ScrollView(.vertical,showsIndicators: false) {
            VStack(alignment: .leading) {
                ForEach(eventArray) { event in
                    EventWidget(event: event, favoriteEventIDs: $favoriteEventIDs)
                    
                }
            }
        }.padding()
        
    }
}
    //        .frame(height: 600)
    //        }
    //    }
    
    
    #Preview {
        //    var event1 = "event1"
        //    var event2 = "event2"
        //    var event3 = "event3"
        
        //    HomePageRow(categoryName: "Tomorrow",
        //                sampleEvents: Array(repeating: "sample", count: 4))
        //    HomePageRow(categoryName: "Event.date",
        //                sampleEvents: Array(repeating: "sample", count: 4))
    }
