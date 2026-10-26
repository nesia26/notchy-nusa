import SwiftUI

public struct DynamicNotchView: View {
    @ObservedObject var state: NotchState
    @ObservedObject var weather: WeatherManager
    @ObservedObject var music: MusicManager
    
    public var body: some View {
        ZStack {
            // Main Notch Container Body
            RoundedRectangle(cornerRadius: state.isExpanded ? 28 : 20, style: .continuous)
                .fill(Color.black.opacity(0.92))
                .overlay(
                    RoundedRectangle(cornerRadius: state.isExpanded ? 28 : 20, style: .continuous)
                        .stroke(Color.white.opacity(0.12), lineWidth: 0.8)
                )
                .shadow(color: Color.black.opacity(0.45), radius: 18, x: 0, y: 8)
            
            if state.isExpanded {
                ExpandedCardsView(state: state, weather: weather, music: music)
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
            } else {
                compactPillContent
                    .transition(.opacity)
            }
        }
        .frame(
            width: state.isExpanded ? 580 : 340,
            height: state.isExpanded ? 230 : 42
        )
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.72)) {
                state.isExpanded.toggle()
                state.userDidInteract()
            }
        }
    }
    
    // Compact pill view showing Album Art + Weather + Mascot Eyes + Equalizer
    private var compactPillContent: some View {
        HStack(spacing: 12) {
            // Left: Album Art & Weather
            HStack(spacing: 8) {
                // Mini real album disc or gradient placeholder
                ZStack {
                    if let art = music.currentTrack.artwork {
                        Image(uiImage: art)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 22, height: 22)
                            .clipShape(Circle())
                    } else {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.pink, Color.purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 22, height: 22)
                        
                        Image(systemName: "music.note")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                
                // Weather condition icon & temperature
                HStack(spacing: 4) {
                    PixelWeatherIcon(
                        weatherCode: weather.currentWeather.weatherCode,
                        size: 18
                    )
                    
                    Text("\(weather.currentWeather.temperature)°")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
            }
            .padding(.leading, 12)
            
            Spacer()
            
            // Center: Signature Nusa Mascot Eyes
            MascotEyeView(state: state, isHoveringOrActive: music.isPlaying && !state.isIdle)
            
            Spacer()
            
            // Right: Animated Equalizer audio visualizer bars
            HStack(spacing: 2.5) {
                equalizerBar(maxHeight: 14, duration: 0.45)
                equalizerBar(maxHeight: 18, duration: 0.35)
                equalizerBar(maxHeight: 10, duration: 0.55)
                equalizerBar(maxHeight: 16, duration: 0.4)
            }
            .padding(.trailing, 14)
        }
    }
    
    private func equalizerBar(maxHeight: CGFloat, duration: Double) -> some View {
        EqualizerBarView(
            color: state.eyeColor.primaryColor,
            maxHeight: maxHeight,
            duration: duration,
            isPlaying: music.isPlaying
        )
    }
}

struct EqualizerBarView: View {
    let color: Color
    let maxHeight: CGFloat
    let duration: Double
    let isPlaying: Bool
    
    @State private var barHeight: CGFloat = 6
    
    var body: some View {
        Capsule()
            .fill(color)
            .frame(width: 2.5, height: isPlaying ? barHeight : 4)
            .onAppear {
                if isPlaying {
                    withAnimation(
                        .easeInOut(duration: duration)
                        .repeatForever(autoreverses: true)
                    ) {
                        barHeight = maxHeight
                    }
                }
            }
    }
}
