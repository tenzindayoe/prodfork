import SwiftUI

struct RootView: View {
    @State private var favoriteEventIDs: Set<String> = []

    var body: some View {
        TabView {
            EventHome()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            
            ChatView()
                .tabItem {
                    Label("Ask Mac", systemImage: "bubble.left.and.bubble.right")
                }

            LikedEventsView()
                .tabItem {
                    Label("Liked", systemImage: "heart")
                }
        }
    }
}
