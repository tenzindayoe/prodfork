//
//  EventHome.swift
//  MacEvents
//
//  Created by Iren Sanchez on 3/26/25.
//

import Foundation
import SwiftUI

struct EventHome:View{
    var body: some View{
        NavigationSplitView{
            MapView()
                .navigationTitle("MacEvents")
            HomePageRow(categoryName: "Today",
                        sampleEvents: Array(repeating: "sample", count: 4))
            HomePageRow(categoryName: "Tomorrow",
                        sampleEvents: Array(repeating: "sample", count: 4))
            HomePageRow(categoryName: "Event.date",
                        sampleEvents: Array(repeating: "sample", count: 4))
            
        } detail: {
            Text("Select Event")
        }
    }
}
#Preview{
    EventHome()
}
