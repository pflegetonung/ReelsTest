import SwiftUI
import AVKit

struct DetailedReelView: View {
    let video: VideoItem
    @Environment(\.dismiss) private var dismiss
    @State private var player: AVPlayer = AVPlayer()
    
    var body: some View {
        ZStack {
            // Video Player Background
            if let url = video.hlsURL {
                VideoPlayerView(url: url, isActive: true)
                    .ignoresSafeArea()
            } else {
                Color.black
                    .ignoresSafeArea()
            }
            
            // Content Overlay
            VStack {
                // Top Bar with Close Button
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(Color.black.opacity(0.6))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    // Share Button
                    Button(action: {
                        // Share functionality
                    }) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(Color.black.opacity(0.6))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 60)
                
                Spacer()
                
                // Bottom Content Section
                VStack(alignment: .leading, spacing: 16) {
                    // User Info Section
                    HStack(spacing: 12) {
                        // Profile Image
                        if let avatarURL = video.channelAvatar {
                            AsyncImage(url: avatarURL) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                Circle()
                                    .fill(Color.gray.opacity(0.3))
                            }
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 2))
                        } else {
                            Circle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 50, height: 50)
                                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                        }
                        
                        // User Info
                        VStack(alignment: .leading, spacing: 4) {
                            Text(video.channelName ?? "Unknown Channel")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .shadow(color: .black, radius: 2, x: 0, y: 1)
                            
                            Text("\(video.numbersViews) views")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                                .shadow(color: .black, radius: 1, x: 0, y: 1)
                        }
                        
                        Spacer()
                        
                        // Follow Button
                        Button(action: {
                            // Follow functionality
                        }) {
                            Text("Follow")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color.red)
                                .clipShape(Capsule())
                        }
                    }
                    
                    // Description
                    Text(video.title)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .lineLimit(nil)
                        .multilineTextAlignment(.leading)
                        .shadow(color: .black, radius: 2, x: 0, y: 1)
                    
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
                    
                    // Engagement Section
                    HStack(spacing: 24) {
                                                    // Like Button
                            Button(action: {
                                // Like functionality
                            }) {
                                VStack(spacing: 4) {
                                    Image(systemName: "heart")
                                        .font(.title2)
                                    Text("0")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                }
                                .foregroundColor(.white)
                                .shadow(color: .black, radius: 1, x: 0, y: 1)
                            }
                            
                            // Comment Button
                            Button(action: {
                                // Comment functionality
                            }) {
                                VStack(spacing: 4) {
                                    Image(systemName: "message")
                                        .font(.title2)
                                    Text("0")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                }
                                .foregroundColor(.white)
                                .shadow(color: .black, radius: 1, x: 0, y: 1)
                            }
                            
                            // Share Button
                            Button(action: {
                                // Share functionality
                            }) {
                                VStack(spacing: 4) {
                                    Image(systemName: "square.and.arrow.up")
                                        .font(.title2)
                                    Text("Share")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                }
                                .foregroundColor(.white)
                                .shadow(color: .black, radius: 1, x: 0, y: 1)
                            }
                        
                        Spacer()
                        
                        // Location
                        HStack(spacing: 4) {
                            Image(systemName: "location.fill")
                                .font(.caption)
                            Text("Russia")
                                .font(.caption)
                        }
                        .foregroundColor(.white.opacity(0.6))
                        .shadow(color: .black, radius: 1, x: 0, y: 1)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 34)
            }
        }
        .navigationBarHidden(true)
    }
}
