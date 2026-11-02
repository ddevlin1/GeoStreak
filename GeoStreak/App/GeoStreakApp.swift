import SwiftUI

@main
struct GeoStreakApp: App {
    init() {
        MusicPlayer.shared.play()
    }

    var body: some Scene {
        WindowGroup {
            LaunchView()
        }
    }
}
