import SwiftUI

struct LikedEventsView: View {
    // Shared liked store
    @EnvironmentObject private var liked: LikedStore

    // Data
    @State private var allEvents: [Event] = []
    @State private var loading = true
    @State private var error: String?

    // Calendar selection (DateComponents, day precision)
    @State private var selectedDays: Set<DateComponents> = []

    // MARK: - Derived

    private var upcomingLiked: [Event] {
        let today = Calendar.current.startOfDay(for: Date())
        return allEvents
            .filter { liked.contains($0.id) && $0.formatDate() >= today }
            .sorted(by: <)
    }

    private var allowedDaysComponents: Set<DateComponents> {
        let cal = Calendar.current
        return Set(upcomingLiked.map { cal.dateComponents([.year, .month, .day], from: $0.formatDate()) })
    }

    private var filteredEvents: [Event] {
        if selectedDays.isEmpty || selectedDays == allowedDaysComponents {
            return upcomingLiked
        }
        let cal = Calendar.current
        return upcomingLiked.filter { ev in
            let dc = cal.dateComponents([.year, .month, .day], from: ev.formatDate())
            return selectedDays.contains(dc)
        }
    }

    private var todayDC: DateComponents {
        Calendar.current.dateComponents([.year, .month, .day], from: .now)
    }

    // MARK: - Body
    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Liked")
                .task { await load() }
        }
    }

    // MARK: - Content
    @ViewBuilder private var content: some View {
        if loading {
            ProgressView("Loading…")
        } else if let error {
            VStack(spacing: 10) {
                Image(systemName: "exclamationmark.triangle.fill").foregroundStyle(.yellow)
                Text(error)
                Button("Retry") { Task { await load() } }
                    .buttonStyle(.borderedProminent)
            }
            .padding()
        } else {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {

                    // Calendar
                    GroupBox {
                        VStack(alignment: .leading, spacing: 10) {
                            MultiDatePicker("",
                                            selection: $selectedDays)
                                .labelsHidden()
                                .tint(.blue)
                                .onChange(of: selectedDays) { _ in
                                    // Keep only days that actually have liked events
                                    selectedDays.formIntersection(allowedDaysComponents)
                                }
                                .onAppear {
                                    // Default selection = all upcoming liked days
                                    selectedDays = allowedDaysComponents
                                }

                            if allowedDaysComponents.isEmpty {
                                Text("No upcoming liked events yet.")
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            } else {
                                Text("Only upcoming liked days are selectable.")
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            }

                            // Quick chips
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    chip("All", isOn: selectedDays == allowedDaysComponents) {
                                        selectedDays = allowedDaysComponents
                                    }
                                    chip("Today", isOn: selectedDays == [todayDC]) {
                                        selectedDays = allowedDaysComponents.contains(todayDC) ? [todayDC] : []
                                    }
                                    chip("Clear", isOn: selectedDays.isEmpty) {
                                        selectedDays = []
                                    }
                                }
                            }
                        }
                    } label: {
                        Label("Upcoming liked events calendar", systemImage: "calendar")
                    }

                    // Filtered list
                    if filteredEvents.isEmpty {
                        ContentUnavailableView("No events",
                                               systemImage: "heart.slash",
                                               description: Text("Nothing matches your current selection."))
                            .frame(maxWidth: .infinity)
                            .padding(.top, 12)
                    } else {
                        LazyVStack(alignment: .leading, spacing: 12) {
                            ForEach(filteredEvents, id: \.id) { ev in
                                NavigationLink {
                                    EventDetail(event: ev)
                                } label: {
                                    row(for: ev)
                                }
                                .buttonStyle(.plain) 
                                .contextMenu {
                                    Button(role: .destructive) {
                                        withAnimation {
                                            liked.remove(ev.id)  // will drop out of list
                                            // Clean selection if a day became empty
                                            selectedDays.formIntersection(allowedDaysComponents)
                                        }
                                    } label: {
                                        Label("Remove from Liked", systemImage: "heart.slash")
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
                .padding(.top, 12)
            }
        }
    }

    // MARK: - Row
    private func row(for ev: Event) -> some View {
        HStack(alignment: .top, spacing: 12) {
            ev.circleImage
                .resizable()
                .scaledToFill()
                .frame(width: 88, height: 66)
                .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 4) {
                Text(ev.title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                Text(ev.date)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                if !ev.location.isEmpty {
                    Text(ev.location)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Button {
                withAnimation {
                    liked.toggle(ev.id)
                    selectedDays.formIntersection(allowedDaysComponents)
                }
            } label: {
                Image(systemName: liked.contains(ev.id) ? "heart.fill" : "heart")
                    .foregroundStyle(liked.contains(ev.id) ? .red : .secondary)
                    .padding(8)
                    .background(.ultraThinMaterial, in: Circle())
            }
            .buttonStyle(.plain)
        }
        .padding(10)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14))
    }

    // MARK: - Helpers
    private func chip(_ title: String, isOn: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.footnote.weight(.semibold))
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(isOn ? Color.blue.opacity(0.15) : Color(.systemGray6),
                            in: Capsule())
        }
        .buttonStyle(.plain)
    }

    private func load() async {
        loading = true
        defer { loading = false }
        do {
            let url = URL(string: "https://mac-events-494-e4c3b3cxfhdca5fh.centralus-01.azurewebsites.net/events")!
            let (data, _) = try await URLSession.shared.data(from: url)
            let events = try JSONDecoder().decode([Event].self, from: data)
            withAnimation {
                allEvents = events
                error = nil
                selectedDays = allowedDaysComponents
            }
        } catch {
            withAnimation { self.error = "Could not load events. Please try again." }
        }
    }
}
