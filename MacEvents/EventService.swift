import Foundation

protocol EventService {
    func fetchEvents() async throws -> [Event]
    func checkHealth() async -> Bool 
}

struct RemoteEventService: EventService {
    var session: URLSession
    let base_url: URL
    let events_url: URL
    let health_url: URL

    init(base_url: URL = URL(string: "https://mac-events-494-e4c3b3cxfhdca5fh.centralus-01.azurewebsites.net")!,
         session: URLSession = .shared) {
        self.base_url = base_url
        self.events_url = base_url.appendingPathComponent("events")
        self.health_url = base_url.appendingPathComponent("health")
        self.session = session
    }

    func fetchEvents() async throws -> [Event] {
        let (data, _) = try await session.data(from: events_url)
        return try JSONDecoder().decode([Event].self, from: data)
    }
    func checkHealth() async -> Bool {
        var request = URLRequest(url: health_url)
        request.httpMethod = "GET"
        do {
            let (data, response) = try await session.data(for: request)
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                return true
            } else {
                return false
            }
        } catch {
            return false
        }
    }
}

struct TestRemoteEventService: EventService {
    var session: URLSession
    let base_url: URL
    let events_url: URL
    let health_url: URL

    init(base_url: URL = URL(string: "https://mac-events-494-e4c3b3cxfhdca5fh.centralus-01.azurewebsites.net/test")!,
         session: URLSession = .shared) {
        self.base_url = base_url
        self.events_url = base_url.appendingPathComponent("events")
        self.health_url = base_url.appendingPathComponent("health")
        self.session = session
    }

    func fetchEvents() async throws -> [Event] {
        let (data, _) = try await session.data(from: events_url)
        return try JSONDecoder().decode([Event].self, from: data)
    }
    func checkHealth() async -> Bool {
        var request = URLRequest(url: health_url)
        request.httpMethod = "GET"
        do {
            let (data, response) = try await session.data(for: request)
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                return true
            } else {
                return false
            }
        } catch {
            return false
        }
    }

}





enum EventServiceFactory {
    static func make(arguments: [String] = ProcessInfo.processInfo.arguments) -> any EventService {
        if arguments.contains("UITestSampleData") {
            return SampleEventService()
        }
        return RemoteEventService()
    }
}


struct SampleEventService: EventService {
    let events: [Event]

    init(events: [Event] = SampleEventService.defaultEvents) {
        self.events = events
    }

    func fetchEvents() async throws -> [Event] {
        events
    }
    func checkHealth() async -> Bool {
        return true
    }

    static let defaultEvents: [Event] = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM dd, yyyy"
        let baseDate = Date()
        let makeEvent: (String, Int) -> Event = { title, offset in
            Event(id: title.lowercased().replacingOccurrences(of: " ", with: "-"),
                  title: title,
                  location: "Campus Center",
                  date: formatter.string(from: Calendar.current.date(byAdding: .day, value: offset, to: baseDate) ?? baseDate),
                  time: "3:00 PM",
                  description: "UITest description for \(title)",
                  link: "https://www.macalester.edu",
                  starttime: nil,
                  endtime: nil,
                  coord: [44.937, -93.172])
        }
        return [
            makeEvent("Sample Event 1", 0),
            makeEvent("Sample Event 2", 1)
        ]
    }()
}
