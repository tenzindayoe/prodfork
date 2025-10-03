import SwiftUI
import MapKit

struct LocationMap: View {
    let event: Event

    init(event: Event) { self.event = event }

    var body: some View {
        // Safely read lat/lon
        let lat = event.coord?[0] ?? 44.937913
        let lon = event.coord?[1] ?? -93.168521
        let eventCoord = CLLocationCoordinate2D(latitude: lat, longitude: lon)

        let region = MKCoordinateRegion(
            center: eventCoord,
            latitudinalMeters: 600,
            longitudinalMeters: 600
        )

        ZStack(alignment: .bottomTrailing) {
            Map(initialPosition: .region(region), interactionModes: [.zoom, .pan]) {
                Marker(event.location, coordinate: eventCoord)
                UserAnnotation()
            }
            .mapStyle(.imagery)
            Button {
                let item = MKMapItem(placemark: MKPlacemark(coordinate: eventCoord))
                item.name = event.location
                item.openInMaps(launchOptions: [
                    MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking
                ])
            } label: {
                Label("Walk", systemImage: "figure.walk")
                    .padding(8)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
            }
            .padding()
        }
    }
}
