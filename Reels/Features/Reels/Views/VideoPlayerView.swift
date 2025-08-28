import SwiftUI
import AVKit

struct VideoPlayerView: View {
    let url: URL
    var isActive: Bool = true
    @State private var player: AVPlayer = AVPlayer()
    @State private var isReady: Bool = false
    
    // Debug: Print when isActive changes
    private var debugIsActive: Bool {
        print("🔍 VideoPlayerView isActive: \(isActive)")
        return isActive
    }
    
    var body: some View {
        VideoPlayer(player: player)
            .disabled(true) // Disable user interaction with video controls
            .allowsHitTesting(false) // Allow taps to pass through to parent NavigationLink
            .ignoresSafeArea()
            .task {
                setupPlayer()
            }
            .onChange(of: debugIsActive) { _, active in
                print("📱 Video isActive changed to: \(active)")
                if active {
                    // When becoming active, restart from beginning and play
                    player.seek(to: .zero) { _ in
                        player.play()
                        print("Video started playing")
                    }
                } else {
                    // When becoming inactive, pause and reset to beginning
                    player.pause()
                    player.seek(to: .zero)
                    print("Video paused and reset")
                }
            }
            .onDisappear {
                cleanupPlayer()
            }
    }
    
    private func setupPlayer() {
        let item = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: item)
        player.automaticallyWaitsToMinimizeStalling = true
        player.actionAtItemEnd = .none // Don't pause at end, we'll handle looping manually
        
        // Configure for HLS streaming
        if let asset = item.asset as? AVURLAsset {
            asset.resourceLoader.setDelegate(nil, queue: nil)
        }
        
        // Set volume to 0 (mute)
        player.isMuted = true
        
        // Add observer for when video ends to restart it
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: item,
            queue: .main
        ) { _ in
            // Only restart if this video is still active
            if isActive {
                player.seek(to: .zero)
                player.play()
            }
        }
        
        // Only play if this video is active
        if isActive {
            player.play()
            print("Initial play for active video")
        } else {
            print("Video setup complete but not active")
        }
    }
    
    private func cleanupPlayer() {
        // Remove observer before cleanup
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
