import SwiftUI

struct RootView: View {
    @State private var favoriteEventIDs: Set<String> = []

    var body: some View {
        TabView {
            EventHome()
                .tabItem {
                    Label("Home", systemImage: "house")
                }

            LikedEventsView()
                .tabItem {
                    Label("Liked", systemImage: "heart")
                }
            
            ScoreView()
                .tabItem {
                    Label("Score", systemImage: "trophy")
                }
        }
    }
}
