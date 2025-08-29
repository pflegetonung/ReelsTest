import SwiftUI
import AVFoundation

struct RoundedVideoFillView: View {
    let url: URL
    var cornerRadius: CGFloat = 24
    var isMuted: Bool = true
    var isPlaying: Bool = true
    
    @State private var player: AVPlayer = AVPlayer()
    
    var body: some View {
        PlayerLayerContainer(player: player)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .contentShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .task { setupPlayer() }
            .onChange(of: isMuted) { _, _ in applyState() }
            .onChange(of: isPlaying) { _, _ in applyState() }
            .onDisappear { cleanupPlayer() }
    }
    
    private func setupPlayer() {
        let item = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: item)
        player.isMuted = isMuted
        player.automaticallyWaitsToMinimizeStalling = true
        
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: item, queue: .main) { _ in
            player.seek(to: .zero)
            if isPlaying { player.play() }
        }
        applyState()
    }
    
    private func applyState() {
        player.isMuted = isMuted
        if isPlaying {
            player.play()
        } else {
            player.pause()
        }
    }
    
    private func cleanupPlayer() {
        if let currentItem = player.currentItem {
            NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: currentItem)
        }
        player.pause()
        player.replaceCurrentItem(with: nil)
    }
}

private struct PlayerLayerContainer: UIViewRepresentable {
    let player: AVPlayer
    
    func makeUIView(context: Context) -> PlayerView {
        let view = PlayerView()
        view.playerLayer.player = player
        view.playerLayer.videoGravity = .resizeAspectFill
        view.isUserInteractionEnabled = false
        return view
    }
    
    func updateUIView(_ uiView: PlayerView, context: Context) {
        uiView.playerLayer.player = player
        uiView.playerLayer.videoGravity = .resizeAspectFill
    }
}

private final class PlayerView: UIView {
    override static var layerClass: AnyClass { AVPlayerLayer.self }
    var playerLayer: AVPlayerLayer { layer as! AVPlayerLayer }
}
