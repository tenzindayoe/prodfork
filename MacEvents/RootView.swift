import SwiftUI

struct RootView: View {
    @State private var favoriteEventIDs: Set<String> = []

    var body: some View {
        TabView {
            EventHome() // 👈 no arguments for now
                .tabItem {
                    Label("Home", systemImage: "house")
                }

            LikedEventsView() // 👈 placeholder
                .tabItem {
                    Label("Liked", systemImage: "heart")
                }

//            MacAI() // 👈 placeholder
//                .tabItem {
//                    Label("Mac AI", systemImage: "sparkles")
//                }
        }
    }
}
