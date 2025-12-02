//
//  AttendanceStore.swift
//  MacEvents
//
//  Tracks attended events and calculates user score with Macalester-themed levels
//

import Foundation
import SwiftUI

// MARK: - Level Definition

struct MacLevel {
    let name: String
    let emoji: String
    let minEvents: Int
    let color: Color
    let description: String
}

// MARK: - Attendance Store

class AttendanceStore: ObservableObject {
    @Published private(set) var attendedEventIDs: Set<String> = []
    
    private let saveKey = "AttendedEvents"
    
    // Gem/Metal themed levels
    static let levels: [MacLevel] = [
        MacLevel(name: "Bronze", emoji: "🥉", minEvents: 0, color: .brown, description: "Just getting started!"),
        MacLevel(name: "Silver", emoji: "🥈", minEvents: 3, color: .gray, description: "You're on your way!"),
        MacLevel(name: "Gold", emoji: "🥇", minEvents: 7, color: .yellow, description: "Shining bright!"),
        MacLevel(name: "Platinum", emoji: "🏆", minEvents: 15, color: .cyan, description: "Elite status achieved!"),
        MacLevel(name: "Diamond", emoji: "💎", minEvents: 25, color: .blue, description: "Rare and brilliant!"),
        MacLevel(name: "Emerald", emoji: "💚", minEvents: 40, color: .green, description: "A true gem!"),
        MacLevel(name: "Ruby", emoji: "❤️", minEvents: 60, color: .red, description: "Legendary status!")
    ]
    
    init() {
        load()
    }
    
    // MARK: - Score & Level
    
    var score: Int {
        attendedEventIDs.count
    }
    
    var currentLevel: MacLevel {
        // Find the highest level the user qualifies for
        let qualifying = Self.levels.filter { $0.minEvents <= score }
        return qualifying.last ?? Self.levels[0]
    }
    
    var nextLevel: MacLevel? {
        // Find the next level to achieve
        return Self.levels.first { $0.minEvents > score }
    }
    
    var progressToNextLevel: Double {
        guard let next = nextLevel else { return 1.0 } // Max level reached
        let current = currentLevel
        let eventsInCurrentRange = score - current.minEvents
        let eventsNeededForNext = next.minEvents - current.minEvents
        return Double(eventsInCurrentRange) / Double(eventsNeededForNext)
    }
    
    var eventsToNextLevel: Int {
        guard let next = nextLevel else { return 0 }
        return next.minEvents - score
    }
    
    // MARK: - Attendance Actions
    
    func contains(_ eventID: String) -> Bool {
        attendedEventIDs.contains(eventID)
    }
    
    func markAttended(_ eventID: String) {
        guard !attendedEventIDs.contains(eventID) else { return }
        attendedEventIDs.insert(eventID)
        save()
    }
    
    func removeAttendance(_ eventID: String) {
        attendedEventIDs.remove(eventID)
        save()
    }
    
    func toggle(_ eventID: String) {
        if contains(eventID) {
            removeAttendance(eventID)
        } else {
            markAttended(eventID)
        }
    }
    
    // MARK: - Persistence
    
    private func save() {
        if let data = try? JSONEncoder().encode(Array(attendedEventIDs)) {
            UserDefaults.standard.set(data, forKey: saveKey)
        }
    }
    
    private func load() {
        guard let data = UserDefaults.standard.data(forKey: saveKey),
              let ids = try? JSONDecoder().decode([String].self, from: data) else { return }
        attendedEventIDs = Set(ids)
    }
}

