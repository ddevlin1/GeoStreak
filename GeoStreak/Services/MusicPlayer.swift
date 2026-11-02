import AVFoundation
import SwiftUI

final class MusicPlayer: ObservableObject {
    static let shared = MusicPlayer()

    private var player: AVAudioPlayer?

    /// Volume levels
    private let menuVolume: Float  = 0.85
    private let quietVolume: Float = 0.22

    private init() {
        guard let url = Bundle.main.url(forResource: "Prairie Concord", withExtension: "mp3") else { return }
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
            player = try AVAudioPlayer(contentsOf: url)
            player?.numberOfLoops = -1   // loop forever
            player?.volume = menuVolume
            player?.prepareToPlay()
        } catch {
            print("MusicPlayer: \(error.localizedDescription)")
        }
    }

    func play() {
        guard let player, !player.isPlaying else { return }
        player.play()
    }

    /// Call when entering the main menu
    func goFull() {
        guard let player else { return }
        player.setVolume(menuVolume, fadeDuration: 0.6)
    }

    /// Call when leaving the main menu (gameplay, story screens, etc.)
    func goQuiet() {
        guard let player else { return }
        player.setVolume(quietVolume, fadeDuration: 0.6)
    }
}

// MARK: - View modifier helpers

struct MusicMenuVolume: ViewModifier {
    func body(content: Content) -> some View {
        content
            .onAppear  { MusicPlayer.shared.goFull()  }
            .onDisappear { MusicPlayer.shared.goQuiet() }
    }
}

struct MusicQuietVolume: ViewModifier {
    func body(content: Content) -> some View {
        content
            .onAppear  { MusicPlayer.shared.goQuiet() }
    }
}

extension View {
    /// Use on the main menu — plays at full volume, ducks when leaving
    func menuMusic() -> some View { modifier(MusicMenuVolume()) }
    /// Use on any gameplay / story screen — ensures music is at quiet level
    func gameMusic() -> some View { modifier(MusicQuietVolume()) }
}
