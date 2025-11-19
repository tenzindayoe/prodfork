import SwiftUI

@MainActor
struct EventHome: View {
    @EnvironmentObject private var liked: LikedStore
    @StateObject private var viewModel: EventFeedViewModel

    init(viewModel: EventFeedViewModel? = nil) {
        _viewModel = StateObject(wrappedValue: viewModel ?? EventFeedViewModel())
    }

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("MacEvents")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            Task { await viewModel.loadEvents(force: true) }
                        } label: {
                            if viewModel.isLoading {
                                ProgressView()
                                    .controlSize(.small)
                            } else {
                                Image(systemName: "arrow.clockwise")
                            }
                        }
                        .accessibilityLabel("Reload events")
                    }
                }
        }
        .task { await viewModel.loadIfNeeded() }
        .refreshable { await viewModel.loadEvents(force: true) }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading && viewModel.events.isEmpty {
            ProgressView("Loading Events…")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let message = viewModel.errorMessage, viewModel.events.isEmpty {
            errorState(message)
        } else if viewModel.sections().isEmpty {
            ContentUnavailableView("No events",
                                   systemImage: "calendar.badge.exclamationmark",
                                   description: Text("Pull to refresh to check for new campus events."))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
        } else {
            sectionsList
        }
    }

    private var sectionsList: some View {
        let sections = viewModel.sections()

        return List {
            if !sections.today.isEmpty {
                Section("Today") {
                    eventRows(for: sections.today)
                }
            }

            if !sections.tomorrow.isEmpty {
                Section("Tomorrow") {
                    eventRows(for: sections.tomorrow)
                }
            }

            if !sections.future.isEmpty {
                Section("Upcoming") {
                    eventRows(for: sections.future)
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    private func eventRows(for events: [Event]) -> some View {
        ForEach(events, id: \.id) { event in
            NavigationLink {
                EventDetail(event: event)
            } label: {
                EventRowView(event: event)
            }
            .listRowSeparator(.hidden)
        }
    }

    private func errorState(_ message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 32))
                .foregroundStyle(.yellow)
            Text(message)
                .font(.headline)
                .multilineTextAlignment(.center)
            Button("Retry") { Task { await viewModel.loadEvents(force: true) } }
                .buttonStyle(.borderedProminent)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
