import SwiftUI

struct ReelsFeedView: View {
    @StateObject private var viewModel = ReelsViewModel()
    @State private var currentIndex: Int = 0
    @State private var scrollOffset: CGFloat = 0
    @State private var hasLoadedOnce: Bool = false
    
    var body: some View {
        NavigationView {
            ScrollViewReader { scrollProxy in
                GeometryReader { proxy in
                    let screenHeight = proxy.size.height
                    
                    ScrollView(.vertical) {
                        LazyVStack(spacing: 0) {
                            ForEach(Array(viewModel.videos.enumerated()), id: \.element.id) { index, video in
                                VideoCardView(
                                    video: video,
                                    isActive: index == currentIndex,
                                    onAppear: {
                                        Task { await viewModel.loadMoreIfNeeded(currentIndex: index) }
                                    }
                                )
                                .frame(width: proxy.size.width, height: screenHeight)
                                .id(index)
                                .background(
                                    GeometryReader { videoProxy in
                                        let offset = videoProxy.frame(in: .named("scroll")).minY
                                        Color.clear
                                            .preference(key: ScrollOffsetPreferenceKey.self, value: [
                                                index: offset
                                            ])
                                            .onChange(of: offset) { _, newOffset in
                                                // Check if this video is centered (within threshold)
                                                let centerThreshold: CGFloat = screenHeight * 0.3
                                                if abs(newOffset) < centerThreshold && currentIndex != index {
                                                    currentIndex = index
                                                    print("🎬 Centered video at index: \(currentIndex)")
                                                }
                                            }
                                    }
                                )
                            }
                        }
                    }
                    .coordinateSpace(name: "scroll")
                    .onPreferenceChange(ScrollOffsetPreferenceKey.self) { preferences in
                        // Find which video is currently most visible
                        var mostVisibleIndex = 0
                        var minDistance: CGFloat = .infinity
                        
                        for (index, offset) in preferences {
                            let distance = abs(offset)
                            if distance < minDistance {
                                minDistance = distance
                                mostVisibleIndex = index
                            }
                        }
                        
                        if mostVisibleIndex != currentIndex {
                            currentIndex = mostVisibleIndex
                            print("Currently playing video at index: \(currentIndex)")
                        }
                    }
                    .scrollTargetBehavior(.paging)
                    .scrollPosition(id: .constant(currentIndex))
                    .scrollIndicators(.hidden)
                    .background(Color.black.ignoresSafeArea())
                    .safeAreaInset(edge: .top) { Color.clear.frame(height: 0) }
                    .safeAreaInset(edge: .bottom) { Color.clear.frame(height: 0) }
                }
                .task {
                    if !hasLoadedOnce {
                        await viewModel.refresh()
                        hasLoadedOnce = true
                    }
                }
                .overlay(alignment: .center) {
                    if viewModel.isLoading && viewModel.videos.isEmpty {
                        ProgressView().tint(.white)
                    }
                }
                .alert("Error", isPresented: .constant(viewModel.errorMessage != nil), presenting: viewModel.errorMessage) { _ in
                    Button("OK", role: .cancel) { viewModel.errorMessage = nil }
                } message: { error in
                    Text(error)
                }
                .onAppear {
                    // Ensure we start centered on the current index
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        if viewModel.videos.indices.contains(currentIndex) {
                            scrollProxy.scrollTo(currentIndex, anchor: .center)
                        }
                    }
                }
                .onChange(of: viewModel.videos.count) { _, _ in
                    // After videos load, center on the current index
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        if viewModel.videos.indices.contains(currentIndex) {
                            scrollProxy.scrollTo(currentIndex, anchor: .center)
                        }
                    }
                }
                .onChange(of: currentIndex) { _, newIndex in
                    // When currentIndex changes, ensure we're centered
                    DispatchQueue.main.async {
                        withAnimation(.easeOut(duration: 0.3)) {
                            scrollProxy.scrollTo(newIndex, anchor: .center)
                        }
                    }
                }
                .navigationBarHidden(true)
            }
        }
    }
}

// Preference key for tracking scroll position
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: [Int: CGFloat] = [:]
    
    static func reduce(value: inout [Int: CGFloat], nextValue: () -> [Int: CGFloat]) {
        value.merge(nextValue()) { _, new in new }
    }
}

struct VideoCardView: View {
    let video: VideoItem
    let isActive: Bool
    let onAppear: () -> Void

    var body: some View {
        NavigationLink(destination: DetailedReelView(video: video)) {
            ZStack {
                // Background color for the full card
                Color.black
                
                // Rounded Video Container with padding
                if let url = video.hlsURL {
                    RoundedVideoFillView(url: url, cornerRadius: 24, isMuted: true, isPlaying: isActive)
                        .padding(24)
                } else {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(Color.gray)
                        .padding(24)
                }
                
                // HUD overlays - positioned absolutely to avoid shifting
                VStack(alignment: .leading) {
                    // Top Section - Fixed position from top
                    HStack(alignment: .top) {
                        // Profile Image (Top Leading) - Rounded Rectangle 3:4 aspect ratio
                        if let avatarURL = video.channelAvatar {
                            AsyncImage(url: avatarURL) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.gray.opacity(0.3))
                            }
                            .frame(width: 60, height: 80) // 3:4 aspect ratio
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.white, lineWidth: 2))
                        } else {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 60, height: 80) // 3:4 aspect ratio
                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.white, lineWidth: 2))
                        }
                        
                        VStack(alignment: .leading) {
                            // Description (Top Trailing)
                            Text(video.channelName)
                            Text(video.title)
                        }
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                    //                            .frame(maxWidth: 200, alignment: .trailing)
                        .shadow(color: .black, radius: 8)
                    }
                    .padding(.horizontal, 40) // Adjusted to account for video padding
                    .padding(.top, 84) // Fixed position from top (24 video padding + 60 safe area)

                    Spacer()

                    // Bottom Section - Fixed position from bottom
                    VStack(alignment: .leading, spacing: 8) {
                        // Tags
                        HStack {
                            Text("#shorts")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.black.opacity(0.3))
                                .clipShape(Capsule())
                            
                            Text("#viral")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.black.opacity(0.3))
                                .clipShape(Capsule())
                            
                            Spacer()
                        }

                        // Bottom Row: Location and Engagement
                        HStack {
                            // Location (Bottom Leading)
                            HStack(spacing: 4) {
                                Image(systemName: "location.fill")
                                    .font(.caption)
                                Text("Russia")
                                    .font(.caption)
                            }
                            .foregroundColor(.white)
                            .shadow(color: .black, radius: 8)

                            Spacer()

                            // Engagement Metrics (Bottom Trailing)
                            HStack(spacing: 16) {
                                // Views
                                HStack(spacing: 2) {
                                    Image(systemName: "eye.fill")
                                        .font(.caption)
                                    Text("\(video.numbersViews)")
                                        .font(.caption2)
                                        .fontWeight(.medium)
                                }
                                .foregroundColor(.white)
                                .shadow(color: .black, radius: 8)

                                // Likes (placeholder - API doesn't provide likes yet)
                                HStack(spacing: 2) {
                                    Image(systemName: "heart.fill")
                                        .font(.caption)
                                    Text("0")
                                        .font(.caption2)
                                        .fontWeight(.medium)
                                }
                                .foregroundColor(.white)
                                .shadow(color: .black, radius: 8)
                            }
                        }
                    }
                    .padding(.horizontal, 40) // Adjusted to account for video padding
                    .padding(.bottom, 58) // Fixed position from bottom (24 video padding + 34 safe area)
                }
            }
            .padding(.horizontal)
        }
        .frame(height: 600)
        .buttonStyle(PlainButtonStyle())
        .onAppear(perform: onAppear)
    }
}



