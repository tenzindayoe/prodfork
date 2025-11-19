import Testing
import Foundation
@testable import MacEvents

struct EventFeedViewModelTests {

    private func makeEvent(id: String, daysFromToday: Int) -> Event {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM dd, yyyy"
        let date = Calendar.current.date(byAdding: .day, value: daysFromToday, to: Date()) ?? Date()
        return Event(id: id,
                     title: "Event \(id)",
                     location: "Campus",
                     date: formatter.string(from: date),
                     time: "5:00 PM",
                     description: "Description for \(id)",
                     link: "https://example.com",
                     starttime: nil,
                     endtime: nil,
                     coord: nil)
    }

    private struct StubService: EventService {
        let events: [Event]
        func fetchEvents() async throws -> [Event] { events }
        func checkHealth() async -> Bool {
            return true
        }
    }

    @Test @MainActor
    func loadClearsErrors() async {
        let events = [makeEvent(id: "A", daysFromToday: 0), makeEvent(id: "B", daysFromToday: 1)]
        let vm = EventFeedViewModel(service: StubService(events: events))
        await vm.loadEvents(force: true)
        #expect(vm.events.count == 2)
        #expect(vm.errorMessage == nil)
    }

    @Test @MainActor
    func sectioningRespectsDates() async {
        let events = [
            makeEvent(id: "today", daysFromToday: 0),
            makeEvent(id: "tomorrow", daysFromToday: 1),
            makeEvent(id: "future", daysFromToday: 3)
        ]
        let vm = EventFeedViewModel(service: StubService(events: events))
        await vm.loadEvents(force: true)
        let sections = vm.sections(referenceDate: Date())
        #expect(sections.today.map { $0.id } == ["today"])
        #expect(sections.tomorrow.map { $0.id } == ["tomorrow"])
        #expect(sections.future.map { $0.id } == ["future"])
    }
}
