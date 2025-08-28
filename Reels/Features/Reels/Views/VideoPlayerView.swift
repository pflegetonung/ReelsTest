import SwiftUI
import AVKit

struct VideoPlayerView: View {
    let url: URL
    var isActive: Bool = true
    var isMuted: Bool = true
    var isPlaying: Bool = true
    @State private var player: AVPlayer = AVPlayer()
    @State private var isReady: Bool = false
    
    var body: some View {
        VideoPlayer(player: player)
            .disabled(true) // Disable user interaction with video controls
            .allowsHitTesting(false) // Allow taps to pass through to parent overlays
            .ignoresSafeArea()
            .task {
                setupPlayer()
            }
            .onChange(of: isActive) { _, _ in
                applyState()
            }
            .onChange(of: isMuted) { _, _ in
                applyState()
            }
            .onChange(of: isPlaying) { _, _ in
                applyState()
            }
            .onDisappear {
                cleanupPlayer()
            }
    }
    
    private func setupPlayer() {
        let item = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: item)
        player.automaticallyWaitsToMinimizeStalling = true
        player.actionAtItemEnd = .none // We'll loop manually
        
        // Configure for HLS streaming
        if let asset = item.asset as? AVURLAsset {
            asset.resourceLoader.setDelegate(nil, queue: nil)
        }
        
        // Observer for looping
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: item,
            queue: .main
        ) { _ in
            if isActive {
                player.seek(to: .zero)
                if isPlaying { player.play() }
            }
        }
        
        applyState()
    }
    
    private func applyState() {
        // Mute/unmute
        player.isMuted = isMuted
        
        if isActive {
            if isPlaying {
                if player.currentTime() == .zero { player.seek(to: .zero) }
                player.play()
            } else {
                player.pause()
            }
        } else {
            player.pause()
            player.seek(to: .zero)
        }
    }
    
    private func cleanupPlayer() {
        if let currentItem = player.currentItem {
            NotificationCenter.default.removeObserver(
                self,
                name: .AVPlayerItemDidPlayToEndTime,
                object: currentItem
            )
        }
        player.pause()
        player.replaceCurrentItem(with: nil)
    }
}

