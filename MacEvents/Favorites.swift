//
//  Favorites.swift
//  MacEvents
//
//  Created by Iren Sanchez on 3/28/25.
//

import Foundation
import SwiftUI


// A class that manages a user's favorite events
class Favorites : ObservableObject {
    private var events: Set<String> // stores the titles of the events in a set
    private let saveKey = "Favorites"
    
    init() {
        events = []
        
    }
    
 
    
    
    
    
    
    // Checks if a given event is already in the favorites set
    func contains(event : Event) -> Bool {
        events.contains(event.title)
    }
    
    // adds an event to the set and lets the user know
    func add(_ event: Event) {
        objectWillChange.send()
        events.insert(event.title)
        save()
    }
    // Removes an event from the favorites set and notifies the user of the change
    
    
    func remove(event: Event) {
        objectWillChange.send()
        events.remove(event.title)
        save()
    }
    
    func save() {
        //writing out
    }
   
}
