import SwiftUI

@main
struct ReelsApp: App {
    var body: some Scene {
        WindowGroup {
            ReelsFeedView()
                .preferredColorScheme(.dark)
        }
    }
}

#Preview {
    ReelsFeedView()
}
