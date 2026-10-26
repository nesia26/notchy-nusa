import SwiftUI
import UIKit

public struct MainView: View {
    @StateObject private var state = NotchState()
    @StateObject private var weather = WeatherManager()
    @StateObject private var music = MusicManager()
    @StateObject private var pipManager = PiPManager()
    
    @State private var showWidgetHelp: Bool = false
    
    public var body: some View {
        GeometryReader { geo in
            ZStack {
                // Background Wallpaper
                if state.showWallpaper {
                    Image("wallpaper")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipped()
                        .ignoresSafeArea()
                } else {
                    Color(red: 0.08, green: 0.09, blue: 0.12)
                        .ignoresSafeArea()
                }
                
                // Subtle dark vignette at top
                VStack {
                    LinearGradient(
                        colors: [Color.black.opacity(0.4), Color.clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 120)
                    .ignoresSafeArea()
                    Spacer()
                }
                
                // Hidden PiP anchor view
                VStack {
                    PiPViewRepresentable(
                        pipManager: pipManager,
                        hostingController: UIHostingController(
                            rootView: FloatingPiPPillView(state: state, weather: weather, music: music)
                        )
                    )
                    .frame(width: 340, height: 46)
                    .opacity(0.001)
                    Spacer()
                }
                
                // Main Content
                VStack(spacing: 0) {
                    // Top Notch Area
                    DynamicNotchView(state: state, weather: weather, music: music)
                        .padding(.top, 8)
                    
                    // Floating Notch PiP Quick Trigger Banner
                    if pipManager.isPiPSupported {
                        Button(action: {
                            pipManager.togglePiP()
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: pipManager.isPiPActive ? "pip.exit" : "pip.enter")
                                    .font(.system(size: 13, weight: .semibold))
                                Text(
                                    pipManager.isPiPActive
                                    ? "Notch Mengambang Aktif (Tutup PiP)"
                                    : "🌟 Aktifkan Floating Notch (Selalu di Atas Semua Aplikasi / PiP)"
                                )
                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(.ultraThinMaterial)
                            .clipShape(Capsule())
                            .overlay(Capsule().stroke(state.eyeColor.primaryColor.opacity(0.4), lineWidth: 1))
                            .foregroundColor(.white)
                            .shadow(color: state.eyeColor.primaryColor.opacity(0.3), radius: 8, x: 0, y: 3)
                        }
                        .padding(.top, 14)
                    }
                    
                    Spacer()
                    
                    // Widget Tutorial & Dock
                    VStack(spacing: 12) {
                        Button(action: {
                            showWidgetHelp.toggle()
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "questionmark.circle.fill")
                                    .font(.system(size: 12))
                                Text("Cara Pasang Widget Tetap di Home Screen (Tanpa Buka App)")
                                    .font(.system(size: 11, weight: .medium, design: .rounded))
                            }
                            .foregroundColor(.white.opacity(0.75))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 5)
                            .background(Color.white.opacity(0.08))
                            .clipShape(Capsule())
                        }
                        
                        bottomDock
                    }
                    .padding(.bottom, 24)
                }
                
                // Widget Help Modal Sheet
                if showWidgetHelp {
                    Color.black.opacity(0.6).ignoresSafeArea().onTapGesture { showWidgetHelp = false }
                    
                    VStack(spacing: 16) {
                        Text("📌 Cara Pasang Widget Tetap di Home Screen")
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        VStack(alignment: .leading, spacing: 10) {
                            helpStep(num: "1", text: "Tekan & tahan (tahan lama) area kosong di Home Screen iPad sampai ikon bergoyang.")
                            helpStep(num: "2", text: "Ketuk tombol '+' di sudut kiri atas layar.")
                            helpStep(num: "3", text: "Cari 'Notchy' di daftar widget.")
                            helpStep(num: "4", text: "Pilih ukuran 'Medium' (Notchy Nusa Island) lalu ketuk 'Tambah Widget'.")
                            helpStep(num: "5", text: "Widget akan menempel tetap di Home Screen iPad tanpa perlu buka aplikasi!")
                        }
                        
                        Button(action: { showWidgetHelp = false }) {
                            Text("Mengerti")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(state.eyeColor.primaryColor)
                                .foregroundColor(.black)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .padding(.top, 6)
                    }
                    .padding(24)
                    .frame(maxWidth: 460)
                    .background(Color(red: 0.12, green: 0.13, blue: 0.16))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.15), lineWidth: 1))
                    .shadow(radius: 20)
                }
            }
            .statusBarHidden(true)
        }
    }
    
    private func helpStep(num: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Text(num)
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundColor(.black)
                .frame(width: 20, height: 20)
                .background(state.eyeColor.primaryColor)
                .clipShape(Circle())
            
            Text(text)
                .font(.system(size: 13, design: .rounded))
                .foregroundColor(.white.opacity(0.85))
        }
    }
    
    private var bottomDock: some View {
        HStack(spacing: 16) {
            dockItem(icon: "music.note", title: "Music", tab: .music)
            dockItem(icon: "timer", title: "Timer", tab: .timer)
            dockItem(icon: "cloud.sun.fill", title: "Weather", tab: .weather)
            dockItem(icon: "pawprint.fill", title: "Pet", tab: .pet)
            dockItem(icon: "gearshape.fill", title: "Settings", tab: .settings)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(Color.white.opacity(0.18), lineWidth: 0.8)
        )
        .shadow(color: Color.black.opacity(0.25), radius: 14, x: 0, y: 6)
    }
    
    private func dockItem(icon: String, title: String, tab: NotchTab) -> some View {
        Button(action: {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.72)) {
                if state.isExpanded && state.selectedTab == tab {
                    state.isExpanded = false
                } else {
                    state.selectedTab = tab
                    state.isExpanded = true
                }
                state.userDidInteract()
            }
        }) {
            VStack(spacing: 3) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                Text(title)
                    .font(.system(size: 9, weight: .medium, design: .rounded))
            }
            .frame(width: 44, height: 40)
            .foregroundColor(
                state.isExpanded && state.selectedTab == tab
                ? state.eyeColor.primaryColor
                : .white.opacity(0.8)
            )
        }
    }
}
