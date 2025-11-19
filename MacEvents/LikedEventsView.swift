import SwiftUI

struct LikedEventsView: View {
    @EnvironmentObject private var liked: LikedStore

    @State private var allEvents: [Event] = []
    @State private var loading = true
    @State private var error: String?

    private let eventService: any EventService

    init(eventService: any EventService = EventServiceFactory.make()) {
        self.eventService = eventService
    }

    // MARK: - Derived Data
    private var likedUpcoming: [Event] {
        let today = Calendar.current.startOfDay(for: Date())
        return allEvents
            .filter { liked.contains($0.id) && $0.formatDate() >= today }
            .sorted(by: <)
    }

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Liked")
                .task { await load(shouldShowLoader: true) }
        }
    }

    // MARK: - Content
    @ViewBuilder private var content: some View {
        if loading {
            ProgressView("Loading…")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let error {
            VStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(.yellow)
                Text(error)
                    .multilineTextAlignment(.center)
                Button("Retry") { Task { await load(shouldShowLoader: true) } }
                    .buttonStyle(.borderedProminent)
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if likedUpcoming.isEmpty {
            ContentUnavailableView("No liked events",
                                   systemImage: "heart.slash",
                                   description: Text("Tap the heart on an event to save it here."))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
        } else {
            List {
                ForEach(likedUpcoming, id: \.id) { event in
                    NavigationLink {
                        EventDetail(event: event)
                    } label: {
                        EventRowView(event: event)
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            liked.remove(event.id)
                        } label: {
                            Label("Remove", systemImage: "trash")
                        }
                    }
                }
            }
            .listStyle(.plain)
            .refreshable { await load() }
        }
    }

    // MARK: - Networking
    @MainActor
    private func load(shouldShowLoader: Bool = false) async {
        if shouldShowLoader {
            loading = true
        }
        error = nil

        do {
            let events = try await eventService.fetchEvents()
            withAnimation {
                allEvents = events
            }
        } catch {
            if allEvents.isEmpty {
                self.error = "Could not load events. Please try again."
            }
        }

        if shouldShowLoader {
            loading = false
        }
    }
}
