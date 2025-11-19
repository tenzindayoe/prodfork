import SwiftUI
import MapKit
import CoreLocation
import UIKit

struct EventDetail: View {
    let event: Event

    @EnvironmentObject private var liked: LikedStore
    @State private var showingShareSheet = false

    private var eventURL: URL? { URL(string: event.link) }
    private var hasCoordinates: Bool { (event.coord?.count ?? 0) == 2 }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                if hasCoordinates {
                    hero
                }
                summaryCard
                actionButtons
                descriptionCard
            }
            .padding()
        }
        .navigationTitle("Event Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { toolbarButtons }
        .sheet(isPresented: $showingShareSheet) {
            if let url = eventURL {
                ActivityView(activityItems: [url])
            }
        }
    }

    // MARK: - Hero
    private var hero: some View {
        LocationMap(event: event)
            .frame(height: 240)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .overlay(alignment: .topTrailing) { likeBadge }
    }

    private var likeBadge: some View {
        Button {
            liked.toggle(event.id)
        } label: {
            Image(systemName: liked.contains(event.id) ? "heart.fill" : "heart")
                .font(.title2)
                .foregroundStyle(liked.contains(event.id) ? .red : .white)
                .padding(10)
                .background(Color.black.opacity(0.4), in: Circle())
        }
        .buttonStyle(.plain)
        .padding(12)
    }

    // MARK: - Summary
    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(event.title)
                .font(.title2.bold())
            if !event.location.isEmpty {
                Label(event.location, systemImage: "mappin.and.ellipse")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Label(event.date, systemImage: "calendar")
                .font(.subheadline)
            if let time = event.time, !time.isEmpty {
                Label(time, systemImage: "clock")
                    .font(.subheadline)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 18))
    }

    // MARK: - Actions
    @ViewBuilder
    private var actionButtons: some View {
        VStack(spacing: 12) {
            if let url = eventURL {
                Link(destination: url) {
                    Label("Open website", systemImage: "safari")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.blue.opacity(0.15), in: RoundedRectangle(cornerRadius: 14))
                }
                .buttonStyle(.plain)
            }

            if let coords = event.coord, coords.count == 2 {
                Button {
                    openWalkingDirections(to: coords)
                } label: {
                    Label("Directions", systemImage: "map")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.green.opacity(0.15), in: RoundedRectangle(cornerRadius: 14))
                }
            }
        }
    }

    // MARK: - Description
    private var descriptionCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("About")
                .font(.headline)
            Text(event.description.isEmpty ? "No description provided." : event.description)
                .font(.body)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 18))
    }

    // MARK: - Toolbar
    private var toolbarButtons: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            if eventURL != nil {
                Button {
                    showingShareSheet = true
                } label: {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
    }

    // MARK: - Helpers
    private func openWalkingDirections(to coordinates: [Double]) {
        guard coordinates.count == 2 else { return }
        let destination = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: coordinates[0], longitude: coordinates[1])))
        destination.name = event.location
        destination.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking])
    }
}

// MARK: - Share Sheet Wrapper

struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ controller: UIActivityViewController, context: Context) { }
}

#Preview {
    let formatter = DateFormatter()
    formatter.dateFormat = "EEEE, MMMM dd, yyyy"
    let event = Event(id: "preview",
                      title: "Sample Preview Event",
                      location: "Campus Center",
                      date: formatter.string(from: Date().addingTimeInterval(86400)),
                      time: "2:00 PM",
                      description: "Preview description",
                      link: "https://macalester.edu",
                      starttime: nil,
                      endtime: nil,
                      coord: [44.937, -93.172])
    return NavigationStack {
        EventDetail(event: event)
            .environmentObject(LikedStore())
    }
}
