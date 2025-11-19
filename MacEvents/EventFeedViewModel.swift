import Foundation
import Combine

@MainActor
final class EventFeedViewModel: ObservableObject {
    struct Sections: Equatable {
        let today: [Event]
        let tomorrow: [Event]
        let future: [Event]

        var isEmpty: Bool { today.isEmpty && tomorrow.isEmpty && future.isEmpty }
    }

    @Published private(set) var events: [Event] = []
    @Published private(set) var isLoading = false
    @Published private(set) var lastUpdated: Date?
    @Published var errorMessage: String?

    private let service: any EventService
    private let calendar: Calendar

    init(service: any EventService = EventServiceFactory.make(), calendar: Calendar = .current) {
        self.service = service
        self.calendar = calendar
    }

    func loadIfNeeded() async {
        guard events.isEmpty else { return }
        await loadEvents(force: true)
    }

    func loadEvents(force: Bool = false) async {
        if isLoading && !force { return }
        isLoading = true
        defer { isLoading = false }
        do {
            let fetched = try await service.fetchEvents()
            events = fetched.sorted(by: <)
            lastUpdated = Date()
            errorMessage = nil
        } catch {
            if events.isEmpty {
                errorMessage = "Could not load events. Please try again."
            }
        }
    }

    func sections(referenceDate: Date = Date()) -> Sections {
        let startOfDay = calendar.startOfDay(for: referenceDate)
        let today = events(on: startOfDay)
        let tomorrowDate = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? startOfDay
        let tomorrow = events(on: tomorrowDate)
        let futureStart = calendar.date(byAdding: .day, value: 2, to: startOfDay) ?? tomorrowDate
        let future = events
            .filter { $0.formatDate() >= futureStart }
            .sorted(by: <)
        return Sections(today: today, tomorrow: tomorrow, future: future)
    }

    private func events(on date: Date) -> [Event] {
        events
            .filter { calendar.isDate($0.formatDate(), inSameDayAs: date) }
            .sorted(by: <)
    }
}
