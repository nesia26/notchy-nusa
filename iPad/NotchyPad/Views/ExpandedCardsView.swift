import SwiftUI

public struct ExpandedCardsView: View {
    @ObservedObject var state: NotchState
    @ObservedObject var weather: WeatherManager
    @ObservedObject var music: MusicManager
    
    public var body: some View {
        VStack(spacing: 12) {
            // Tab Header Bar
            HStack(spacing: 6) {
                ForEach(NotchTab.allCases) { tab in
                    Button(action: {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                            state.selectedTab = tab
                            state.userDidInteract()
                        }
                    }) {
                        HStack(spacing: 5) {
                            Image(systemName: tab.icon)
                                .font(.system(size: 11, weight: .semibold))
                            Text(tab.rawValue)
                                .font(.system(size: 11, weight: .semibold, design: .rounded))
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            state.selectedTab == tab
                            ? Color.white.opacity(0.2)
                            : Color.clear
                        )
                        .clipShape(Capsule())
                        .foregroundColor(
                            state.selectedTab == tab
                            ? .white
                            : .white.opacity(0.55)
                        )
                    }
                }
                
                Spacer()
                
                // Close / Collapse Button
                Button(action: {
                    withAnimation(.spring(response: 0.45, dampingFraction: 0.75)) {
                        state.isExpanded = false
                        state.userDidInteract()
                    }
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white.opacity(0.6))
                        .frame(width: 26, height: 26)
                        .background(Color.white.opacity(0.1))
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, 4)
            
            Divider()
                .background(Color.white.opacity(0.12))
            
            // Selected Tab Content Card
            Group {
                switch state.selectedTab {
                case .music:
                    MusicPlayerView(music: music)
                case .timer:
                    TimerCardView()
                case .weather:
                    WeatherCardView(weather: weather)
                case .pet:
                    PetCardView(state: state)
                case .settings:
                    settingsView
                }
            }
            .transition(.opacity.combined(with: .scale(scale: 0.98)))
        }
        .padding(16)
    }
    
    private var settingsView: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Nusa Mascot Eye Glow Color")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundColor(.white.opacity(0.85))
            
            HStack(spacing: 10) {
                ForEach(NotchEyeColor.allCases) { colorOption in
                    Button(action: {
                        state.eyeColor = colorOption
                        state.userDidInteract()
                    }) {
                        Circle()
                            .fill(colorOption.primaryColor)
                            .frame(width: 32, height: 32)
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: state.eyeColor == colorOption ? 2.5 : 0)
                            )
                            .shadow(color: colorOption.primaryColor.opacity(0.6), radius: 5, x: 0, y: 0)
                    }
                }
            }
            
            Toggle("Show Wallpaper Background", isOn: $state.showWallpaper)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.85))
                .tint(state.eyeColor.primaryColor)
        }
        .padding(.vertical, 6)
    }
}
