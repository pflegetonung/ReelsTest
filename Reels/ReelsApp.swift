import SwiftUI

@main
struct ReelsApp: App {
    var body: some Scene {
        WindowGroup {
            TabbarView()
                .preferredColorScheme(.dark)
        }
    }
}

#Preview {
    TabbarView()
}
