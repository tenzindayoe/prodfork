import SwiftUI
import CoreLocation
import UserNotifications

struct EventHome: View {
    private let locationManager = CLLocationManager()

    // Shared liked store (provided from App)
    @EnvironmentObject private var liked: LikedStore

    // MARK: - State
    @State private var allEvents: [Event] = []
    @State private var isLoading = true
    @State private var errorMessage: String?

    // MARK: - Grouped Events
    private var todayEvents: [Event] { filterEvents(for: Date()) }
    private var tomorrowEvents: [Event] {
        filterEvents(for: Calendar.current.date(byAdding: .day, value: 1, to: Date())!)
    }
    private var futureEvents: [Event] {
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        return allEvents.filter { $0.formatDate() > tomorrow }.sorted(by: <)
    }

    var body: some View {
        NavigationStack {
            eventContent
                .navigationTitle("MacEvents")
        }
        .onAppear { locationManager.requestWhenInUseAuthorization() }
        .task {
            NotificationManager.shared.requestPermission()
            await loadEvents()
        }
    }

    // MARK: - Event Content
    private var eventContent: some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()

            if isLoading {
                ProgressView("Loading Events…")
                    .controlSize(.large)
            } else if let errorMessage {
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(.yellow)
                    Text(errorMessage)
                        .font(.headline)
                        .multilineTextAlignment(.center)
                    Button("Retry") { Task { await loadEvents() } }
                        .buttonStyle(.borderedProminent)
                }
                .padding()
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 32) {

                        // Today
                        if !todayEvents.isEmpty {
                            sectionHeader("Today")
                            VStack(spacing: 20) {
                                ForEach(todayEvents, id: \.id) { event in
                                    NavigationLink {
                                        EventDetail(event: event)
                                    } label: {
                                        largeCard(for: event)
                                    }
                                    .buttonStyle(.plain)
                                    
                                }
                            }
                            .padding(.horizontal)
                        }

                        // Tomorrow
                        if !tomorrowEvents.isEmpty {
                            sectionHeader("Tomorrow")
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(tomorrowEvents, id: \.id) { event in
                                        NavigationLink {
                                            EventDetail(event: event)
                                        } label: {
                                            mediumCard(for: event)
                                                .frame(width: 250)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }

                        // Future
                        if !futureEvents.isEmpty {
                            sectionHeader("Future Events")
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                                ForEach(futureEvents, id: \.id) { event in
                                    NavigationLink {
                                        EventDetail(event: event)
                                    } label: {
                                        smallCard(for: event)
                                    }
                                    .buttonStyle(.plain) 
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.top, 20)
                }
            }
        }
    }

    // MARK: - Section Header
    private func sectionHeader(_ title: String) -> some View {
        Text(title).font(.title2.bold()).padding(.horizontal)
    }

    // MARK: - Card Styles
    private func likeButton(for event: Event) -> some View {
        Button {
            liked.toggle(event.id)
        } label: {
            Image(systemName: liked.contains(event.id) ? "heart.fill" : "heart")
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(liked.contains(event.id) ? .red : .secondary)
                .padding(8)
                .background(.ultraThinMaterial, in: Circle())
        }
        .buttonStyle(.plain)
    }

    private func largeCard(for event: Event) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack(alignment: .topTrailing) {
                event.widgetImage
                    .resizable()
                    .scaledToFill()
                    .frame(height: 200)
                    .clipped()
                    .cornerRadius(16)
                likeButton(for: event).padding(10)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(event.title).font(.headline).lineLimit(2)
                if let t = event.time, !t.isEmpty {
                    Text(t).font(.subheadline).foregroundStyle(.secondary)
                }
                if !event.location.isEmpty {
                    Label(event.location, systemImage: "mappin.and.ellipse")
                        .font(.caption).foregroundStyle(.secondary)
                }
            }
        }
        .background(.ultraThinMaterial)
        .cornerRadius(16)
        .shadow(radius: 4)
    }

    private func mediumCard(for event: Event) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            ZStack(alignment: .topTrailing) {
                event.circleImage
                    .resizable()
                    .scaledToFill()
                    .frame(height: 120)
                    .clipped()
                    .cornerRadius(12)
                likeButton(for: event).padding(8)
            }
            Text(event.title).font(.headline).lineLimit(1)
            if let t = event.time, !t.isEmpty {
                Text(t).font(.subheadline).foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(16)
        .shadow(radius: 2)
    }

    private func smallCard(for event: Event) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            ZStack(alignment: .topTrailing) {
                event.circleImage
                    .resizable()
                    .scaledToFill()
                    .frame(height: 100)
                    .cornerRadius(12)
                likeButton(for: event).padding(6)
            }
            Text(event.title).font(.subheadline.bold()).lineLimit(1)
            Text(event.date).font(.caption).foregroundStyle(.secondary)
        }
        .padding(8)
        .background(.ultraThinMaterial)
        .cornerRadius(12)
        .shadow(radius: 1)
    }

    // MARK: - Helpers
    private func filterEvents(for day: Date) -> [Event] {
        allEvents.filter { Calendar.current.isDate($0.formatDate(), inSameDayAs: day) }
    }

    private func loadEvents() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let url = URL(string: "https://mac-events-494-e4c3b3cxfhdca5fh.centralus-01.azurewebsites.net/events")!
            let (data, _) = try await URLSession.shared.data(from: url)
            let events = try JSONDecoder().decode([Event].self, from: data)
            withAnimation {
                allEvents = events
                errorMessage = nil
            }
        } catch {
            withAnimation {
                errorMessage = "Could not load events. Please try again."
            }
        }
    }
}
