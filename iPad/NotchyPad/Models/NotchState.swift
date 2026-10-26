import SwiftUI
import Combine

public enum NotchEyeColor: String, CaseIterable, Identifiable {
    case cyan = "Cyan Glow"
    case blue = "Electric Blue"
    case green = "Emerald"
    case pink = "Neon Pink"
    case amber = "Amber Gold"
    case white = "Pure White"
    
    public var id: String { rawValue }
    
    public var primaryColor: Color {
        switch self {
        case .cyan: return Color(red: 0.2, green: 0.9, blue: 1.0)
        case .blue: return Color(red: 0.2, green: 0.5, blue: 1.0)
        case .green: return Color(red: 0.3, green: 0.95, blue: 0.6)
        case .pink: return Color(red: 1.0, green: 0.3, blue: 0.7)
        case .amber: return Color(red: 1.0, green: 0.75, blue: 0.2)
        case .white: return Color.white
        }
    }
}

public enum NotchTab: String, CaseIterable, Identifiable {
    case music = "Music"
    case timer = "Timer"
    case weather = "Weather"
    case pet = "Pet"
    case settings = "Settings"
    
    public var id: String { rawValue }
    
    public var icon: String {
        switch self {
        case .music: return "music.note"
        case .timer: return "timer"
        case .weather: return "cloud.sun.fill"
        case .pet: return "pawprint.fill"
        case .settings: return "gearshape.fill"
        }
    }
}

public class NotchState: ObservableObject {
    @Published public var isExpanded: Bool = false
    @Published public var selectedTab: NotchTab = .music
    @Published public var eyeColor: NotchEyeColor = .cyan
    @Published public var showWallpaper: Bool = true
    @Published public var isIdle: Bool = false
    
    private var idleTimer: Timer?
    private var lastInteraction: Date = Date()
    
    public init() {
        startIdleTracking()
    }
    
    public func userDidInteract() {
        lastInteraction = Date()
        if isIdle {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                isIdle = false
            }
        }
    }
    
    private func startIdleTracking() {
        idleTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if Date().timeIntervalSince(self.lastInteraction) > 20.0 && !self.isExpanded {
                withAnimation(.easeInOut(duration: 0.5)) {
                    self.isIdle = true
                }
            }
        }
    }
}
