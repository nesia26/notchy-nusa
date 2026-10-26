import SwiftUI

public struct MusicPlayerView: View {
    @ObservedObject var music: MusicManager
    
    public var body: some View {
        VStack(spacing: 14) {
            HStack(spacing: 16) {
                // Real Album Artwork or Music Placeholder
                ZStack {
                    if let artwork = music.currentTrack.artwork {
                        Image(uiImage: artwork)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 58, height: 58)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    } else {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                LinearGradient(
                                    colors: [Color.pink.opacity(0.8), Color.purple.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 58, height: 58)
                        
                        Image(systemName: "music.note")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                    }
                }
                .shadow(color: Color.black.opacity(0.3), radius: 6, x: 0, y: 3)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(music.currentTrack.title)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    Text(music.currentTrack.artist)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.65))
                        .lineLimit(1)
                }
                
                Spacer()
                
                // Real System Output Volume
                HStack(spacing: 6) {
                    Image(systemName: volumeIcon)
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.7))
                    Text("\(Int(music.volume * 100))%")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color.white.opacity(0.08))
                .clipShape(Capsule())
            }
            
            // Progress Bar (Active if track duration > 0)
            if music.currentTrack.hasTrack && music.currentTrack.duration > 0 {
                VStack(spacing: 4) {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.white.opacity(0.15))
                                .frame(height: 4)
                            
                            let progress = CGFloat(music.currentTime / max(music.currentTrack.duration, 1.0))
                            Capsule()
                                .fill(Color.white)
                                .frame(width: geo.size.width * min(max(progress, 0.0), 1.0), height: 4)
                        }
                    }
                    .frame(height: 4)
                    
                    HStack {
                        Text(formatTime(music.currentTime))
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(.white.opacity(0.5))
                        Spacer()
                        Text(formatTime(music.currentTrack.duration))
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(.white.opacity(0.5))
                    }
                }
            } else {
                HStack {
                    Text("💡 Putar lagu di Apple Music / Spotify di iPad kamu untuk sinkron otomatis.")
                        .font(.system(size: 11, design: .rounded))
                        .foregroundColor(.white.opacity(0.55))
                    Spacer()
                }
                .padding(.vertical, 2)
            }
            
            // Real Media Controls
            HStack(spacing: 36) {
                Button(action: music.prevTrack) {
                    Image(systemName: "backward.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.white.opacity(music.currentTrack.hasTrack ? 1.0 : 0.4))
                }
                .disabled(!music.currentTrack.hasTrack)
                
                Button(action: music.togglePlayPause) {
                    Image(systemName: music.isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.black)
                        .frame(width: 50, height: 50)
                        .background(Color.white)
                        .clipShape(Circle())
                }
                
                Button(action: music.nextTrack) {
                    Image(systemName: "forward.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.white.opacity(music.currentTrack.hasTrack ? 1.0 : 0.4))
                }
                .disabled(!music.currentTrack.hasTrack)
            }
        }
        .padding(.vertical, 4)
    }
    
    private var volumeIcon: String {
        if music.volume == 0 { return "speaker.slash.fill" }
        if music.volume < 0.33 { return "speaker.wave.1.fill" }
        if music.volume < 0.66 { return "speaker.wave.2.fill" }
        return "speaker.wave.3.fill"
    }
    
    private func formatTime(_ seconds: Double) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d:%02d", mins, secs)
    }
}
