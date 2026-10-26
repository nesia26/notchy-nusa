import SwiftUI

public struct FloatingPiPPillView: View {
    @ObservedObject var state: NotchState
    @ObservedObject var weather: WeatherManager
    @ObservedObject var music: MusicManager

    public var body: some View {
        HStack(spacing: 12) {
            // Left: Real Album Art & Weather
            HStack(spacing: 8) {
                ZStack {
                    if let art = music.currentTrack.artwork {
                        Image(uiImage: art)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 22, height: 22)
                            .clipShape(Circle())
                    } else {
                        Circle()
                            .fill(LinearGradient(colors: [.pink, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 22, height: 22)
                        Image(systemName: "music.note")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                
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

            // Center: Nusa Mascot Eyes ^^
            MascotEyeView(state: state, isHoveringOrActive: music.isPlaying && !state.isIdle)

            Spacer()

            // Right: Audio visualizer bars
            HStack(spacing: 2.5) {
                Capsule().fill(state.eyeColor.primaryColor).frame(width: 2.5, height: 12)
                Capsule().fill(state.eyeColor.primaryColor).frame(width: 2.5, height: 16)
                Capsule().fill(state.eyeColor.primaryColor).frame(width: 2.5, height: 10)
                Capsule().fill(state.eyeColor.primaryColor).frame(width: 2.5, height: 14)
            }
            .padding(.trailing, 14)
        }
        .frame(width: 340, height: 44)
        .background(Color.black.opacity(0.95))
        .clipShape(Capsule())
        .overlay(Capsule().stroke(Color.white.opacity(0.18), lineWidth: 0.8))
    }
}
