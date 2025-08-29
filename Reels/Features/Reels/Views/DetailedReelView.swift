import SwiftUI
import AVKit

struct DetailedReelView: View {
    let video: VideoItem
    @Environment(\.dismiss) private var dismiss
    @State private var isPlaying: Bool = true
    
    var body: some View {
        ZStack {
            // Video Player Background with sound and external play control
            if let url = video.hlsURL {
                VideoPlayerView(url: url, isActive: true, isMuted: false, isPlaying: isPlaying)
                    .ignoresSafeArea()
            } else {
                Color.black
                    .ignoresSafeArea()
            }
            
            // Resume icon overlay when paused
            if !isPlaying {
                Image(systemName: "play.fill")
                    .font(.system(size: 88, weight: .regular))
                    .foregroundColor(.white)
//                    .shadow(color: .black, radius: 8)
            }
            
            // Tap to toggle play/pause
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    isPlaying.toggle()
                }
            
            // Content Overlay
            VStack {
                // Top Bar with Close Button
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .shadow(color: .black, radius: 8)
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
                            .frame(width: 44, height: 44)
                            .shadow(color: .black, radius: 8)
                    }
                }
                .padding(.horizontal, 16)
//                .padding(.top, 60)
                
//                Spacer()
                
                // Bottom Content Section
                VStack(alignment: .leading, spacing: 20) {
                    // Top Section - Profile and Channel Info
                    HStack(alignment: .top, spacing: 12) {
                        // Profile Image - Rounded Rectangle 3:4 aspect ratio
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
                        
                        // Channel Info
                        VStack(alignment: .leading, spacing: 4) {
                            Text(video.channelName ?? "Unknown Channel")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .shadow(color: .black, radius: 8)
                            
                            // Location
                            HStack(spacing: 4) {
                                Image(systemName: "location.fill")
                                    .font(.caption)
                                Text("Russia")
                                    .font(.caption)
                            }
                            .foregroundColor(.white)
                            .shadow(color: .black, radius: 8)
                            
                            // Full Description
                            Text(video.title)
                                .font(.body)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                                .lineLimit(nil)
                                .multilineTextAlignment(.leading)
                                .shadow(color: .black, radius: 8)
                        }
                    }
                    
                    Spacer()
                    
                    // Bottom Section - Detailed Info
                    VStack(spacing: 16) {
                        // Friends Watching
                        HStack(spacing: 8) {
                            Image(systemName: "person.2.fill")
                                .font(.caption)
                                .foregroundColor(.white)
                                .shadow(color: .black, radius: 8)
                            
                            Text("Друзья смотрят: @dasha @anna @pavel")
                                .font(.caption)
                                .foregroundColor(.white)
                                .shadow(color: .black, radius: 8)
                            
                            Spacer()
                        }
                        
                        // Live Stream Viewers
                        HStack(spacing: 8) {
                            Image(systemName: "play.fill")
                                .font(.caption)
                                .foregroundColor(.white)
                                .shadow(color: .black, radius: 8)
                            
                            Text("15к смотрят эфир")
                                .font(.caption)
                                .foregroundColor(.white)
                                .shadow(color: .black, radius: 8)
                            
                            Spacer()
                        }
                        
                        // Group/Channel Name with Stats
                        HStack(spacing: 8) {
                            Image(systemName: "location.fill")
                                .font(.caption)
                                .foregroundColor(.white)
                                .shadow(color: .black, radius: 8)
                            
                            Text("RA'MEN")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .shadow(color: .black, radius: 8)
                            
                            Image(systemName: "arrow.up")
                                .font(.caption)
                                .foregroundColor(.green)
                                .shadow(color: .black, radius: 8)
                            
                            Image(systemName: "square.grid.2x2")
                                .font(.caption)
                                .foregroundColor(.white)
                                .shadow(color: .black, radius: 8)
                            
                            Text("(12)")
                                .font(.caption)
                                .foregroundColor(.white)
                                .shadow(color: .black, radius: 8)
                            
                            Spacer()
                        }
                        
                        // Tags
                        HStack {
                            Text("#португалия")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.black.opacity(0.3))
                                .clipShape(Capsule())
                            
                            Text("#природа")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.black.opacity(0.3))
                                .clipShape(Capsule())
                            
                            Text("#лето")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.black.opacity(0.3))
                                .clipShape(Capsule())
                            
                            Spacer()
                        }
                        
                        // Reactions
                        HStack(spacing: 12) {
                            HStack(spacing: 4) {
                                Text("😍")
                                    .font(.caption)
                                Text("10k")
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                            .foregroundColor(.white)
                            .shadow(color: .black, radius: 8)
                            
                            HStack(spacing: 4) {
                                Text("❤️")
                                    .font(.caption)
                                Text("100k")
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                            .foregroundColor(.white)
                            .shadow(color: .black, radius: 8)
                            
                            HStack(spacing: 4) {
                                Text("🙈")
                                    .font(.caption)
                                Text("5k")
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                            .foregroundColor(.white)
                            .shadow(color: .black, radius: 8)
                            
                            HStack(spacing: 4) {
                                Text("👍")
                                    .font(.caption)
                                Text("300k")
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                            .foregroundColor(.white)
                            .shadow(color: .black, radius: 8)
                            
                            HStack(spacing: 4) {
                                Text("😅")
                                    .font(.caption)
                                Text("567")
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                            .foregroundColor(.white)
                            .shadow(color: .black, radius: 8)
                            
                            Spacer()
                        }
                        
                        // Comment Input Field
                        HStack {
                            Text("Добавить комментарий")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                                .padding(.leading, 12)
                            
                            Spacer()
                            
                            Button(action: {
                                // Send comment functionality
                            }) {
                                Image(systemName: "paperplane.fill")
                                    .font(.caption)
                                    .foregroundColor(.white)
                                    .padding(.trailing, 12)
                            }
                        }
                        .padding(.vertical, 8)
                        .background(Color.black.opacity(0.3))
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 34)
            }
        }
        .navigationBarHidden(true)
    }
}
