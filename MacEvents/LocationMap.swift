import SwiftUI
import MapKit

struct LocationMap: View {
    let event: Event

    init(event: Event) { self.event = event }

    var body: some View {
        if let coord = event.coord, coord.count == 2 {
            let eventCoord = CLLocationCoordinate2D(latitude: coord[0], longitude: coord[1])
            let region = MKCoordinateRegion(
                center: eventCoord,
                latitudinalMeters: 600,
                longitudinalMeters: 600
            )

            ZStack(alignment: .bottomTrailing) {
                Map(initialPosition: .region(region), interactionModes: [.zoom, .pan]) {
                    Marker(event.location.isEmpty ? "Event" : event.location, coordinate: eventCoord)
                    UserAnnotation()
                }
                .mapStyle(.hybrid)
            }
        } else {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.secondarySystemBackground))
                VStack(spacing: 8) {
                    Image(systemName: "map")
                        .font(.system(size: 42))
                        .foregroundStyle(.secondary)
                    Text("Map unavailable")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
                .padding()
            }
            .frame(height: 180)
        }
    }
    
    #Preview {
        let event = Event(
            id: "10",
            title: "FreakCon",
            location: "Janet Wallace Fine Arts Center",
            date: "Saturday, May 10, 2025",
            description: "FreakCon 2025 2nd Bicentennial Anniversary",
            link: "google.com",
            coord: [44.93749, -93.16959]
        )
        
        LocationMap(event: event)
    }
}
