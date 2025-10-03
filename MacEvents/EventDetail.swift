//  EventDetail.swift
//  MacEvents
//
//  Created by Iren Sanchez on 4/23/25.
//  Updated: share Macalester URL only + system share sheet

import SwiftUI
import CoreLocation
import MapKit
import UIKit

struct EventDetail: View {
    let event: Event

    @State private var showInfo = false
    @State private var showCopiedToast = false
    @State private var isGeocoding = false

    // share sheet state
    @State private var showShareSheet = false
    @State private var shareItems: [Any] = []

    private let defaultTime = "None Specified"

    // Normalize arbitrary links like "google.com" → https://google.com
    private var normalizedURL: URL? {
        let raw = event.link.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !raw.isEmpty else { return nil }
        if raw.lowercased().hasPrefix("http://") || raw.lowercased().hasPrefix("https://") {
            return URL(string: raw)
        }
        return URL(string: "https://\(raw)")
    }

    private var hasCoordinate: Bool { (event.coord?.count ?? 0) == 2 }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Map header
                if hasCoordinate {
                    LocationMap(event: event)
                        .frame(height: 300)
                        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                        .shadow(color: .black.opacity(0.12), radius: 6, x: 0, y: 2)
                        .padding(.horizontal)
                        .padding(.top, 8)
                } else {
                    ZstackFallback()
                        .frame(height: 300)
                        .padding(.horizontal)
                        .padding(.top, 8)
                }

                // Avatar overlap
                CircleImage(image: hasCoordinate ? event.circleImage : Image("MacLogoTextless"))
                    .frame(width: 120, height: 120)
                    .shadow(color: .black.opacity(0.12), radius: 4, x: 0, y: 1)
                    .offset(y: -60)
                    .padding(.bottom, -60)

                // Title / meta
                VStack(spacing: 6) {
                    Text(event.title)
                        .font(.title2.weight(.semibold))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    if !event.location.isEmpty {
                        Text(event.location)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }

                    Text(event.time ?? defaultTime)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)
                }

                // Actions (pure system style)
                HStack(spacing: 12) {
                    // Share (copy Macalester URL + present share sheet)
                    PillIconButton(title: nil, systemImage: "square.and.arrow.up") {
                        shareLink()
                    }

                    // More info sheet
                    PillIconButton(title: "More info", systemImage: "info.circle.fill") {
                        showInfo = true
                    }

                    // Directions (walking)
                    PillIconButton(title: nil, systemImage: "paperplane.fill") {
                        openWalkingDirections()
                    }
                    .disabled(!hasCoordinate && isGeocoding)
                    .opacity((!hasCoordinate && isGeocoding) ? 0.6 : 1)
                }
                .padding(.top, 8)
                .padding(.horizontal)
                .padding(.bottom, 6)

                if !event.description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("About").font(.headline)
                        Text(event.description)
                            .font(.body)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 12)
                }
            }
        }
        .sheet(isPresented: $showInfo) {
            InfoSheet(event: event, url: normalizedURL)
                .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $showShareSheet) {
            ActivityView(activityItems: shareItems)
        }
        .overlay(alignment: .top) {
            if showCopiedToast {
                CopiedToast()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
                            withAnimation(.easeOut) { showCopiedToast = false }
                        }
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .padding(.top, 8)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Actions

    /// Shares **only** the Macalester event URL and copies it to the clipboard.
    private func shareLink() {
        guard let url = normalizedURL else { return }

        // Share sheet contains just this URL
        shareItems = [url]

        // Copy to clipboard
        UIPasteboard.general.url = url
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            showCopiedToast = true
        }

        // Present the system share sheet
        showShareSheet = true
    }

    private func openWalkingDirections() {
        // If we already have coords, open directly.
        if let c = event.coord, c.count == 2 {
            let coord = CLLocationCoordinate2D(latitude: c[0], longitude: c[1])
            let pm = MKPlacemark(coordinate: coord)
            let item = MKMapItem(placemark: pm)
            item.name = event.title
            item.openInMaps(launchOptions: [
                MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking
            ])
            return
        }

        // Fallback: geocode the textual location
        guard !event.location.isEmpty else { return }
        isGeocoding = true
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(event.location) { placemarks, _ in
            defer { isGeocoding = false }
            if let coord = placemarks?.first?.location?.coordinate {
                let pm = MKPlacemark(coordinate: coord)
                let item = MKMapItem(placemark: pm)
                item.name = event.title
                item.openInMaps(launchOptions: [
                    MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking
                ])
            }
        }
    }
}

// MARK: - Small helpers

private struct ZstackFallback: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(.thinMaterial)
            Image(systemName: "map")
                .font(.system(size: 44, weight: .semibold))
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Subviews

private struct PillIconButton: View {
    var title: String?
    var systemImage: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            if let title {
                Label(title, systemImage: systemImage)
                    .labelStyle(.titleAndIcon)
            } else {
                Image(systemName: systemImage)
            }
        }
        .buttonStyle(.borderedProminent)
        .buttonBorderShape(.capsule)
        .controlSize(.large)
    }
}

private struct CopiedToast: View {
    var body: some View {
        Label("Link copied", systemImage: "checkmark.circle.fill")
            .font(.subheadline.weight(.semibold))
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(.ultraThinMaterial, in: Capsule())
            .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
            .padding(.top, 4)
    }
}

private struct InfoSheet: View {
    let event: Event
    let url: URL?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(event.title).font(.title2.bold())

                    if !event.location.isEmpty {
                        Label(event.location, systemImage: "mappin.and.ellipse")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    HStack(spacing: 8) {
                        Label(event.date, systemImage: "calendar")
                        if let time = event.time, !time.isEmpty {
                            Label(time, systemImage: "clock")
                        }
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                    Divider()

                    if !event.description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        Text(event.description)
                            .font(.body)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    if let url {
                        Link(destination: url) {
                            Label("Open website", systemImage: "safari")
                                .font(.body.weight(.semibold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(.blue.opacity(0.12), in: RoundedRectangle(cornerRadius: 12))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
            .navigationTitle("More info")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - UIKit share sheet wrapper

private struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
    }

    func updateUIViewController(_ controller: UIActivityViewController, context: Context) { }
}

// MARK: - Preview

#Preview {
    let sampleEvent = Event(
        id: "abc123",
        title: "Sample Event",
        location: "Macalester College",
        date: "Sunday, March 13, 2025",
        time: "2:00–4:00 PM",
        description: "A friendly example of an event with a longer description. Bring snacks!",
        link: "https://www.macalester.edu/calendar/event/?id=16018",
        starttime: "1400",
        endtime: "1600",
        coord: [44.93749, -93.16959]
    )
    NavigationStack { EventDetail(event: sampleEvent) }
}
