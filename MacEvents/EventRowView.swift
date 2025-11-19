import SwiftUI

struct EventRowView: View {
    let event: Event

    @EnvironmentObject private var liked: LikedStore

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            event.circleImage
                .resizable()
                .scaledToFill()
                .frame(width: 80, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .lineLimit(2)

                if let time = event.time, !time.isEmpty {
                    Text(time)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Text(event.date)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if !event.location.isEmpty {
                    Label(event.location, systemImage: "mappin.and.ellipse")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer(minLength: 8)

            Button {
                liked.toggle(event.id)
            } label: {
                Image(systemName: liked.contains(event.id) ? "heart.fill" : "heart")
                    .foregroundStyle(liked.contains(event.id) ? .red : .secondary)
                    .padding(8)
                    .background(.ultraThinMaterial, in: Circle())
            }
            .buttonStyle(.plain)
        }
        .padding(10)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
    }
}
