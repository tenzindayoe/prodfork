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
    
    // Macalester-themed levels
    static let levels: [MacLevel] = [
        MacLevel(name: "First Year Scot", emoji: "🏫", minEvents: 0, color: .gray, description: "Welcome to Mac! Start exploring campus events."),
        MacLevel(name: "Tartan Rookie", emoji: "🏴󠁧󠁢󠁳󠁣󠁴󠁿", minEvents: 3, color: .green, description: "You're getting the hang of campus life!"),
        MacLevel(name: "Campus Explorer", emoji: "🗺️", minEvents: 7, color: .blue, description: "You know your way around Mac events."),
        MacLevel(name: "Mac Enthusiast", emoji: "🔥", minEvents: 15, color: .orange, description: "A true Macalester spirit!"),
        MacLevel(name: "Scottish Legend", emoji: "⚔️", minEvents: 25, color: .purple, description: "Your dedication is legendary."),
        MacLevel(name: "Old Main Master", emoji: "🏛️", minEvents: 40, color: .pink, description: "You've mastered campus engagement."),
        MacLevel(name: "Mac Royalty", emoji: "👑", minEvents: 60, color: .yellow, description: "The ultimate Macalester champion!")
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

