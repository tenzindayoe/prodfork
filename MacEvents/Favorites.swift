//
//  Favorites.swift
//  MacEvents
//
//  Created by Iren Sanchez on 3/28/25.
//

import Foundation
import SwiftUI

class Favorites : ObservableObject {
    private var events: Set<String>
    private let saveKey = "Favorites"
    
    init() {
        events = []
        
    }
    func contains( event : Event) -> Bool {
        events.contains(event.title)
    }
    func add (_ event: Event) {
        objectWillChange.send()
        events.insert(event.title)
        save()
    }
    func remove (event: Event) {
        objectWillChange.send()
        events.remove(event.title)
        save()
    }
    func save(){
        //writing out 
    }
}
