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
                                .containerRelativeFrame(.vertical)
                                .id(index)
                                .background(
                                    GeometryReader { videoProxy in
                                        Color.clear
                                            .preference(key: ScrollOffsetPreferenceKey.self, value: [
                                                index: videoProxy.frame(in: .named("scroll")).minY
                                            ])
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
                            print("🎬 Currently playing video at index: \(currentIndex)")
                        }
                    }
                    .scrollTargetBehavior(.paging)
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
                    // Restore scroll position to the last active index
                    if viewModel.videos.indices.contains(currentIndex) {
                        DispatchQueue.main.async {
                            withAnimation(.easeOut) {
                                scrollProxy.scrollTo(currentIndex, anchor: .center)
                            }
                        }
                    }
                }
                .onChange(of: viewModel.videos.count) { _, _ in
                    // After videos load/refetch, ensure we are at the saved index
                    if viewModel.videos.indices.contains(currentIndex) {
                        DispatchQueue.main.async {
                            scrollProxy.scrollTo(currentIndex, anchor: .center)
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
                // Video Player - fill the entire container
                if let url = video.hlsURL {
                    VideoPlayerView(url: url, isActive: isActive)
                        .ignoresSafeArea()
                } else {
                    Color.black
                        .ignoresSafeArea()
                }

                // HUD Overlay - positioned consistently with proper safe area handling
                VStack {
                    // Top Section
                    HStack {
                        // Profile Image (Top Leading)
                        if let avatarURL = video.channelAvatar {
                            AsyncImage(url: avatarURL) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                Circle()
                                    .fill(Color.gray.opacity(0.3))
                            }
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 2))
                        } else {
                            Circle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 40, height: 40)
                                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                        }

                        Spacer()

                        // Description (Top Trailing)
                        Text(video.title)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .lineLimit(3)
                            .multilineTextAlignment(.trailing)
                            .frame(maxWidth: 200, alignment: .trailing)
                            .shadow(color: .black, radius: 2, x: 0, y: 1)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)

                    Spacer()

                    // Bottom Section
                    VStack(alignment: .leading, spacing: 8) {
                        // Tags
                        HStack {
                            Text("#shorts")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.black.opacity(0.6))
                                .clipShape(Capsule())
                                .shadow(color: .black, radius: 1, x: 0, y: 1)
                            
                            Text("#viral")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.black.opacity(0.6))
                                .clipShape(Capsule())
                                .shadow(color: .black, radius: 1, x: 0, y: 1)
                            
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
                            .foregroundColor(.white.opacity(0.6))
                            .shadow(color: .black, radius: 1, x: 0, y: 1)

                            Spacer()

                            // Engagement Metrics (Bottom Trailing)
                            HStack(spacing: 16) {
                                // Views
                                VStack(spacing: 2) {
                                    Image(systemName: "eye.fill")
                                        .font(.caption)
                                    Text("\(video.numbersViews)")
                                        .font(.caption2)
                                        .fontWeight(.medium)
                                }
                                .foregroundColor(.white)
                                .shadow(color: .black, radius: 1, x: 0, y: 1)

                                // Likes (placeholder - API doesn't provide likes yet)
                                VStack(spacing: 2) {
                                    Image(systemName: "heart.fill")
                                        .font(.caption)
                                    Text("0")
                                        .font(.caption2)
                                        .fontWeight(.medium)
                                }
                                .foregroundColor(.white)
                                .shadow(color: .black, radius: 1, x: 0, y: 1)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                }
                .padding(.top, 60) // Add consistent top padding to account for safe area
                .padding(.bottom, 34) // Add consistent bottom padding to account for safe area
                
                // Invisible tap area that covers the entire video
                Color.clear
                    .contentShape(Rectangle())
            }
        }
        .buttonStyle(PlainButtonStyle()) // Prevents default button styling
        .onAppear(perform: onAppear)
    }
}


