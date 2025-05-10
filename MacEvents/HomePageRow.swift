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
    @Binding var favoriteEventIDs: Set<String>
    
    
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(categoryName)
                .font(.headline)
                .padding(.leading,-5)
                .padding(.top)
                .bold()
            VStack(alignment: .leading) {
                ForEach(eventArray) { event in
                    EventWidget(event: event, favoriteEventIDs: $favoriteEventIDs)
                    
                }
            }
        }
        .padding()
    }
}
