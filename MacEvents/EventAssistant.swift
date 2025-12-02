//
//  EventAssistant.swift
//  MacEvents
//
//  AI-powered assistant for campus events using Apple's on-device Foundation Models
//  with fallback for devices without Apple Intelligence
//

import Foundation
import SwiftUI

// Import Foundation Models when available (iOS 26+ / Xcode 26+)
#if canImport(FoundationModels)
import FoundationModels
#endif

// MARK: - Chat Message Model

struct ChatMessage: Identifiable, Equatable {
    let id = UUID()
    let content: String
    let isUser: Bool
    let timestamp: Date
    
    init(content: String, isUser: Bool) {
        self.content = content
        self.isUser = isUser
        self.timestamp = Date()
    }
}

// MARK: - Event Assistant

@MainActor
class EventAssistant: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var isProcessing = false
    @Published var supportsAppleIntelligence = false
    
    private var events: [Event] = []
    private let eventService: any EventService
    
    // Quick suggestion buttons
    let suggestions = [
        "What's happening today?",
        "Events this weekend",
        "Find food events",
        "Music & arts events"
    ]
    
    // Instructions for the AI model
    private let systemInstructions = """
        You are a helpful assistant for Macalester College campus events.
        Be concise, friendly, and helpful. Use emojis occasionally.
        Answer based only on the events provided. If no events match, say so politely.
        Format event info clearly with title, date, time, and location.
        Keep responses brief - no more than 3-5 events at a time.
        """
    
    init(eventService: any EventService = EventServiceFactory.make()) {
        self.eventService = eventService
        checkAppleIntelligenceSupport()
        
        // Add welcome message
        messages.append(ChatMessage(
            content: "Hi! I'm your Mac Events assistant 🎓\n\nAsk me about campus events, like:\n• \"What's happening today?\"\n• \"Any events this weekend?\"\n• \"Find music events\"",
            isUser: false
        ))
    }
    
    // MARK: - Apple Intelligence Check
    
    private func checkAppleIntelligenceSupport() {
        #if canImport(FoundationModels)
        if #available(iOS 26.0, macOS 26.0, *) {
            supportsAppleIntelligence = true
        } else {
            supportsAppleIntelligence = false
        }
        #else
        supportsAppleIntelligence = false
        #endif
    }
    
    // MARK: - Load Events
    
    func loadEvents() async {
        do {
            events = try await eventService.fetchEvents()
        } catch {
            print("Failed to load events for assistant: \(error)")
        }
    }
    
    // MARK: - Send Message
    
    func send(_ message: String) async {
        let trimmed = message.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        // Add user message
        messages.append(ChatMessage(content: trimmed, isUser: true))
        isProcessing = true
        
        // Ensure events are loaded
        if events.isEmpty {
            await loadEvents()
        }
        
        // Generate response using Foundation Models or fallback
        let response = await generateResponse(query: trimmed)
        
        // Add assistant response
        messages.append(ChatMessage(content: response, isUser: false))
        isProcessing = false
    }
    
    // MARK: - Generate Response
    
    private func generateResponse(query: String) async -> String {
        #if canImport(FoundationModels)
        if #available(iOS 26.0, macOS 26.0, *) {
            return await generateWithFoundationModels(query: query)
        } else {
            return generateSmartResponse(query: query)
        }
        #else
        return generateSmartResponse(query: query)
        #endif
    }
    
    // MARK: - Foundation Models Response (iOS 26+)
    
    #if canImport(FoundationModels)
    @available(iOS 26.0, macOS 26.0, *)
    private func generateWithFoundationModels(query: String) async -> String {
        // Build event context
        let eventContext = buildEventContext()
        let today = formattedDate(Date())
        
        // Create the prompt with event context
        let prompt = """
            TODAY'S DATE: \(today)
            
            AVAILABLE CAMPUS EVENTS:
            \(eventContext)
            
            USER QUESTION: \(query)
            """
        
        do {
            // Create a session with instructions
            let session = LanguageModelSession(instructions: systemInstructions)
            
            // Generate response from the on-device LLM
            let response = try await session.respond(to: prompt)
            return response.content
        } catch {
            print("Foundation Models error: \(error). Falling back to smart search.")
            return generateSmartResponse(query: query)
        }
    }
    #endif
    
    // MARK: - Smart Fallback Response
    
    private func generateSmartResponse(query: String) -> String {
        let lowercased = query.lowercased()
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        let weekEnd = Calendar.current.date(byAdding: .day, value: 7, to: today)!
        
        // Parse intent from query
        if lowercased.contains("today") || lowercased.contains("tonight") {
            let todayEvents = events.filter { event in
                guard let eventDate = parseEventDate(event.date) else { return false }
                return Calendar.current.isDate(eventDate, inSameDayAs: today)
            }
            return formatEventResponse(events: todayEvents, timeframe: "today")
        }
        
        if lowercased.contains("tomorrow") {
            let tomorrowEvents = events.filter { event in
                guard let eventDate = parseEventDate(event.date) else { return false }
                return Calendar.current.isDate(eventDate, inSameDayAs: tomorrow)
            }
            return formatEventResponse(events: tomorrowEvents, timeframe: "tomorrow")
        }
        
        if lowercased.contains("weekend") || lowercased.contains("this week") {
            let weekEvents = events.filter { event in
                guard let eventDate = parseEventDate(event.date) else { return false }
                return eventDate >= today && eventDate <= weekEnd
            }.sorted()
            return formatEventResponse(events: weekEvents, timeframe: "this week")
        }
        
        // Category searches
        if lowercased.contains("food") || lowercased.contains("eat") || lowercased.contains("pizza") || lowercased.contains("lunch") || lowercased.contains("dinner") {
            let foodEvents = searchEvents(keywords: ["food", "pizza", "lunch", "dinner", "breakfast", "snack", "eat", "meal", "dining"])
            return formatEventResponse(events: foodEvents, timeframe: "with food", category: "🍕 Food")
        }
        
        if lowercased.contains("music") || lowercased.contains("concert") || lowercased.contains("arts") || lowercased.contains("performance") {
            let artsEvents = searchEvents(keywords: ["music", "concert", "art", "performance", "theater", "theatre", "dance", "choir", "band", "orchestra"])
            return formatEventResponse(events: artsEvents, timeframe: "", category: "🎵 Music & Arts")
        }
        
        if lowercased.contains("sport") || lowercased.contains("game") || lowercased.contains("athletic") || lowercased.contains("basketball") || lowercased.contains("soccer") {
            let sportsEvents = searchEvents(keywords: ["sport", "game", "athletic", "basketball", "soccer", "football", "volleyball", "tennis", "swim"])
            return formatEventResponse(events: sportsEvents, timeframe: "", category: "🏀 Sports")
        }
        
        if lowercased.contains("study") || lowercased.contains("academic") || lowercased.contains("lecture") || lowercased.contains("workshop") {
            let academicEvents = searchEvents(keywords: ["study", "academic", "lecture", "workshop", "seminar", "class", "learning", "research"])
            return formatEventResponse(events: academicEvents, timeframe: "", category: "📚 Academic")
        }
        
        // Location-based search
        let locations = ["campus center", "library", "chapel", "stadium", "kagin", "olin", "great lawn", "old main"]
        for location in locations {
            if lowercased.contains(location) {
                let locationEvents = events.filter { $0.location.lowercased().contains(location) }
                return formatEventResponse(events: locationEvents, timeframe: "at \(location.capitalized)", category: "📍 Location")
            }
        }
        
        // General search - look for keywords in event titles/descriptions
        let words = lowercased.components(separatedBy: .whitespaces).filter { $0.count > 3 }
        if !words.isEmpty {
            let matchingEvents = events.filter { event in
                let searchText = "\(event.title) \(event.description)".lowercased()
                return words.contains { searchText.contains($0) }
            }
            if !matchingEvents.isEmpty {
                return formatEventResponse(events: matchingEvents, timeframe: "matching your search")
            }
        }
        
        // Default: show upcoming events
        let upcomingEvents = events.filter { event in
            guard let eventDate = parseEventDate(event.date) else { return false }
            return eventDate >= today
        }.sorted().prefix(5)
        
        return """
            I'm not sure what you're looking for. Here are some upcoming events:
            
            \(formatEventList(events: Array(upcomingEvents)))
            
            💡 Try asking:
            • "What's happening today?"
            • "Events this weekend"
            • "Find music events"
            """
    }
    
    // MARK: - Helper Functions
    
    private func searchEvents(keywords: [String]) -> [Event] {
        let today = Calendar.current.startOfDay(for: Date())
        return events.filter { event in
            guard let eventDate = parseEventDate(event.date), eventDate >= today else { return false }
            let searchText = "\(event.title) \(event.description) \(event.location)".lowercased()
            return keywords.contains { searchText.contains($0) }
        }.sorted()
    }
    
    private func formatEventResponse(events: [Event], timeframe: String, category: String? = nil) -> String {
        if events.isEmpty {
            let categoryText = category ?? "events"
            return "I couldn't find any \(categoryText) \(timeframe). Try checking back later or browse all events in the Home tab! 📅"
        }
        
        let header: String
        if let cat = category {
            header = "\(cat) Events\(timeframe.isEmpty ? "" : " \(timeframe)"):"
        } else {
            header = "Here's what's happening \(timeframe):"
        }
        
        let eventList = formatEventList(events: Array(events.prefix(5)))
        let moreText = events.count > 5 ? "\n\n...and \(events.count - 5) more events!" : ""
        
        return "\(header)\n\n\(eventList)\(moreText)"
    }
    
    private func formatEventList(events: [Event]) -> String {
        events.map { event in
            let time = event.time ?? "Time TBD"
            return """
                📌 \(event.title)
                📅 \(event.date)
                🕐 \(time)
                📍 \(event.location)
                """
        }.joined(separator: "\n\n")
    }
    
    private func buildEventContext() -> String {
        let upcomingEvents = events.filter { event in
            guard let eventDate = parseEventDate(event.date) else { return false }
            return eventDate >= Calendar.current.startOfDay(for: Date())
        }.sorted().prefix(50) // Limit for context window
        
        return upcomingEvents.map { event in
            """
            - TITLE: \(event.title)
              DATE: \(event.date)
              TIME: \(event.time ?? "TBD")
              LOCATION: \(event.location)
              DESCRIPTION: \(event.description.prefix(200))
            """
        }.joined(separator: "\n\n")
    }
    
    private func parseEventDate(_ dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM dd, yyyy"
        return formatter.date(from: dateString)
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM dd, yyyy"
        return formatter.string(from: date)
    }
}
