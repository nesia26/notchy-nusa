import Foundation
import SwiftUI
import AppKit
import SQLite3

// MARK: - Weather Types & Manager

enum WeatherTempUnit: String, CaseIterable, Codable {
    case celsius = "Celsius (°C)"
    case fahrenheit = "Fahrenheit (°F)"

    var symbol: String {
        switch self {
        case .celsius: return "°C"
        case .fahrenheit: return "°F"
        }
    }
}

struct WeatherData: Equatable {
    let temperature: Double
    let apparentTemperature: Double
    let humidity: Int
    let weatherCode: Int
    let isDay: Bool
    let city: String
    let region: String
    let country: String
    let latitude: Double
    let longitude: Double
    let fetchedAt: Date
    var windSpeed: Double = 0.0

    var sfSymbolName: String {
        switch weatherCode {
        case 0, 1:
            return isDay ? "sun.max.fill" : "moon.stars.fill"
        case 2:
            return isDay ? "cloud.sun.fill" : "cloud.moon.fill"
        case 3:
            return "cloud.fill"
        case 45, 48:
            return "cloud.fog.fill"
        case 51, 53, 55:
            return "cloud.drizzle.fill"
        case 61, 63:
            return "cloud.rain.fill"
        case 65:
            return "cloud.heavyrain.fill"
        case 71, 73, 75, 77:
            return "snowflake"
        case 80, 81:
            return "cloud.sun.rain.fill"
        case 82:
            return "cloud.heavyrain.fill"
        case 85, 86:
            return "cloud.snow.fill"
        case 95, 96, 99:
            return "cloud.bolt.rain.fill"
        default:
            return isDay ? "sun.max.fill" : "moon.stars.fill"
        }
    }

    var symbolColor: Color {
        switch weatherCode {
        case 0, 1, 2:
            return isDay ? Color.yellow : Color.cyan
        case 3:
            return Color.gray.opacity(0.85)
        case 45, 48:
            return Color.gray.opacity(0.7)
        case 51, 53, 55, 61, 63, 65, 80, 81, 82:
            return Color(red: 0.4, green: 0.75, blue: 1.0)
        case 71, 73, 75, 77, 85, 86:
            return Color.white.opacity(0.9)
        case 95, 96, 99:
            return Color.yellow
        default:
            return Color.yellow
        }
    }
}

// MARK: - Weather Condition Category
enum WeatherCategory {
    case sunny
    case clearNight
    case cloudy
    case rainy
    case thunderstorm
    case windy
    case snowy
    case foggy
    
    static func from(weatherCode: Int, isDay: Bool, windSpeed: Double = 0.0) -> WeatherCategory {
        if windSpeed >= 28.0 && (weatherCode == 0 || weatherCode == 1 || weatherCode == 2 || weatherCode == 3) {
            return .windy
        }
        switch weatherCode {
        case 0, 1:
            return isDay ? .sunny : .clearNight
        case 2, 3:
            return .cloudy
        case 45, 48:
            return .foggy
        case 51, 53, 55, 61, 63, 65, 80, 81, 82:
            return .rainy
        case 71, 73, 75, 77, 85, 86:
            return .snowy
        case 95, 96, 99:
            return .thunderstorm
        default:
            return isDay ? .sunny : .clearNight
        }
    }
}

// MARK: - Animated Weather Shapes

struct CloudShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width
        let h = rect.height
        p.addEllipse(in: CGRect(x: w * 0.08, y: h * 0.36, width: w * 0.42, height: h * 0.54))
        p.addEllipse(in: CGRect(x: w * 0.30, y: h * 0.16, width: w * 0.44, height: h * 0.74))
        p.addEllipse(in: CGRect(x: w * 0.54, y: h * 0.34, width: w * 0.38, height: h * 0.56))
        p.addRoundedRect(in: CGRect(x: w * 0.16, y: h * 0.50, width: w * 0.68, height: h * 0.40), cornerSize: CGSize(width: h * 0.18, height: h * 0.18))
        return p
    }
}

struct LightningBoltShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width
        let h = rect.height
        p.move(to: CGPoint(x: w * 0.58, y: 0))
        p.addLine(to: CGPoint(x: w * 0.22, y: h * 0.52))
        p.addLine(to: CGPoint(x: w * 0.52, y: h * 0.52))
        p.addLine(to: CGPoint(x: w * 0.38, y: h))
        p.addLine(to: CGPoint(x: w * 0.82, y: h * 0.42))
        p.addLine(to: CGPoint(x: w * 0.52, y: h * 0.42))
        p.closeSubpath()
        return p
    }
}

struct SunRaysShape: Shape {
    var rayCount: Int = 8
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let innerR = rect.width * 0.32
        let outerR = rect.width * 0.48
        for i in 0..<rayCount {
            let angle = (Double(i) * 2.0 * .pi / Double(rayCount))
            let p1 = CGPoint(
                x: center.x + CGFloat(cos(angle)) * innerR,
                y: center.y + CGFloat(sin(angle)) * innerR
            )
            let p2 = CGPoint(
                x: center.x + CGFloat(cos(angle)) * outerR,
                y: center.y + CGFloat(sin(angle)) * outerR
            )
            p.move(to: p1)
            p.addLine(to: p2)
        }
        return p
    }
}

struct WindGustShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width
        let h = rect.height
        p.move(to: CGPoint(x: 0, y: h * 0.5))
        p.addQuadCurve(to: CGPoint(x: w * 0.72, y: h * 0.38), control: CGPoint(x: w * 0.38, y: h * 0.20))
        p.addQuadCurve(to: CGPoint(x: w, y: h * 0.28), control: CGPoint(x: w * 0.88, y: h * 0.50))
        return p
    }
}

// MARK: - Animated Weather Icon View

public struct AnimatedWeatherIconView: View {
    public let weatherCode: Int
    public let isDay: Bool
    public var windSpeed: Double = 0.0
    public var size: CGFloat = 14

    @State private var sunRotation: Double = 0
    @State private var cloudDriftBack: Bool = false
    @State private var cloudFloatFront: Bool = false
    @State private var lightningFlash: Double = 0.0
    @State private var windPhase: CGFloat = 0.0
    @State private var moonGlow: Bool = false

    private var category: WeatherCategory {
        WeatherCategory.from(weatherCode: weatherCode, isDay: isDay, windSpeed: windSpeed)
    }

    public var body: some View {
        ZStack {
            switch category {
            case .sunny:
                sunnyView
            case .clearNight:
                clearNightView
            case .cloudy:
                cloudyView
            case .rainy:
                rainyView
            case .thunderstorm:
                thunderstormView
            case .windy:
                windyView
            case .snowy:
                snowyView
            case .foggy:
                foggyView
            }
        }
        .frame(width: size, height: size)
        .clipped()
        .onAppear {
            startAnimations()
        }
    }

    // 1. Cerah: Matahari Berputar
    private var sunnyView: some View {
        ZStack {
            SunRaysShape(rayCount: 8)
                .stroke(
                    LinearGradient(
                        colors: [Color(red: 255/255, green: 215/255, blue: 0/255), Color(red: 255/255, green: 165/255, blue: 0/255)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: max(1.1, size * 0.09), lineCap: .round)
                )
                .frame(width: size, height: size)
                .rotationEffect(.degrees(sunRotation))

            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color(red: 255/255, green: 235/255, blue: 59/255), Color(red: 255/255, green: 179/255, blue: 0/255)],
                        center: .center,
                        startRadius: 0,
                        endRadius: size * 0.25
                    )
                )
                .frame(width: size * 0.48, height: size * 0.48)
                .shadow(color: Color.orange.opacity(0.6), radius: 2)
        }
    }

    // 2. Malam Cerah: Bulan & Bintang Berkelap-kelip
    private var clearNightView: some View {
        ZStack {
            Image(systemName: "moon.fill")
                .resizable()
                .scaledToFit()
                .frame(width: size * 0.65, height: size * 0.65)
                .foregroundColor(Color(red: 254/255, green: 240/255, blue: 138/255))
                .shadow(color: Color(red: 254/255, green: 240/255, blue: 138/255).opacity(0.6), radius: moonGlow ? 3 : 1)
                .offset(x: -size * 0.08, y: -size * 0.05)

            Circle()
                .fill(Color.white)
                .frame(width: max(1.2, size * 0.10), height: max(1.2, size * 0.10))
                .opacity(moonGlow ? 1.0 : 0.25)
                .scaleEffect(moonGlow ? 1.2 : 0.7)
                .offset(x: size * 0.28, y: -size * 0.22)

            Circle()
                .fill(Color(red: 186/255, green: 230/255, blue: 253/255))
                .frame(width: max(1.0, size * 0.08), height: max(1.0, size * 0.08))
                .opacity(moonGlow ? 0.3 : 0.95)
                .scaleEffect(moonGlow ? 0.8 : 1.1)
                .offset(x: size * 0.32, y: size * 0.18)
        }
    }

    // 3. Mendung: Awan Melayang Halus
    private var cloudyView: some View {
        ZStack {
            CloudShape()
                .fill(Color(red: 100/255, green: 116/255, blue: 139/255).opacity(0.75))
                .frame(width: size * 0.82, height: size * 0.52)
                .offset(x: cloudDriftBack ? size * 0.08 : -size * 0.05, y: -size * 0.08)

            CloudShape()
                .fill(
                    LinearGradient(
                        colors: [Color(red: 226/255, green: 232/255, blue: 240/255), Color(red: 148/255, green: 163/255, blue: 184/255)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: size * 0.88, height: size * 0.56)
                .offset(x: -size * 0.04, y: cloudFloatFront ? -size * 0.04 : size * 0.04)
        }
    }

    // 4. Hujan: Rintik-rintik Titik Hujan
    private var rainyView: some View {
        ZStack {
            CloudShape()
                .fill(
                    LinearGradient(
                        colors: [Color(red: 148/255, green: 163/255, blue: 184/255), Color(red: 100/255, green: 116/255, blue: 139/255)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: size * 0.88, height: size * 0.54)
                .offset(y: -size * 0.18)

            HStack(spacing: size * 0.14) {
                RainDropTimeline(delay: 0.0, size: size, slant: windSpeed > 15 ? 12 : 0)
                RainDropTimeline(delay: 0.28, size: size, slant: windSpeed > 15 ? 12 : 0)
                RainDropTimeline(delay: 0.56, size: size, slant: windSpeed > 15 ? 12 : 0)
            }
            .offset(y: size * 0.20)
        }
    }

    // 5. Petir: Kilat Menyambar & Awan Badai
    private var thunderstormView: some View {
        ZStack {
            CloudShape()
                .fill(
                    LinearGradient(
                        colors: [
                            lightningFlash > 0.4 ? Color(red: 120/255, green: 135/255, blue: 165/255) : Color(red: 71/255, green: 85/255, blue: 105/255),
                            Color(red: 30/255, green: 41/255, blue: 59/255)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: size * 0.90, height: size * 0.56)
                .offset(y: -size * 0.18)
                .shadow(color: Color.yellow.opacity(lightningFlash * 0.5), radius: 3)

            HStack(spacing: size * 0.18) {
                RainDropTimeline(delay: 0.0, size: size, slant: 6)
                RainDropTimeline(delay: 0.35, size: size, slant: 6)
            }
            .offset(y: size * 0.22)

            LightningBoltShape()
                .fill(
                    LinearGradient(
                        colors: [Color.white, Color(red: 254/255, green: 240/255, blue: 138/255), Color(red: 250/255, green: 204/255, blue: 21/255)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: size * 0.46, height: size * 0.56)
                .offset(x: size * 0.02, y: size * 0.10)
                .opacity(lightningFlash)
                .scaleEffect(lightningFlash > 0.1 ? 1.05 : 0.9)
                .shadow(color: Color.yellow.opacity(0.85), radius: 2.5)
        }
    }

    // 6. Angin: Hembusan Angin Dinamis
    private var windyView: some View {
        ZStack {
            VStack(spacing: size * 0.18) {
                WindGustShape()
                    .stroke(
                        Color(red: 165/255, green: 243/255, blue: 252/255).opacity(0.9),
                        style: StrokeStyle(lineWidth: max(1.1, size * 0.08), lineCap: .round)
                    )
                    .frame(width: size * 0.85, height: size * 0.22)
                    .offset(x: (windPhase - 0.5) * (size * 0.35))

                WindGustShape()
                    .stroke(
                        Color.white.opacity(0.85),
                        style: StrokeStyle(lineWidth: max(1.2, size * 0.09), lineCap: .round)
                    )
                    .frame(width: size * 0.95, height: size * 0.24)
                    .offset(x: (0.5 - windPhase) * (size * 0.30))

                WindGustShape()
                    .stroke(
                        Color(red: 186/255, green: 230/255, blue: 253/255).opacity(0.75),
                        style: StrokeStyle(lineWidth: max(1.0, size * 0.07), lineCap: .round)
                    )
                    .frame(width: size * 0.70, height: size * 0.20)
                    .offset(x: (windPhase - 0.5) * (size * 0.25))
            }
        }
    }

    // 7. Salju: Butiran Salju Melayang
    private var snowyView: some View {
        ZStack {
            CloudShape()
                .fill(Color(red: 148/255, green: 163/255, blue: 184/255))
                .frame(width: size * 0.86, height: size * 0.54)
                .offset(y: -size * 0.18)

            HStack(spacing: size * 0.16) {
                SnowFlakeTimeline(delay: 0.0, size: size)
                SnowFlakeTimeline(delay: 0.38, size: size)
                SnowFlakeTimeline(delay: 0.76, size: size)
            }
            .offset(y: size * 0.20)
        }
    }

    // 8. Kabut: Garis Kabut Mengambang
    private var foggyView: some View {
        VStack(spacing: size * 0.14) {
            RoundedRectangle(cornerRadius: size * 0.05)
                .fill(Color.white.opacity(0.8))
                .frame(width: size * 0.85, height: max(1.2, size * 0.08))
                .offset(x: cloudDriftBack ? size * 0.06 : -size * 0.06)

            RoundedRectangle(cornerRadius: size * 0.05)
                .fill(Color(red: 203/255, green: 213/255, blue: 225/255).opacity(0.9))
                .frame(width: size * 0.95, height: max(1.2, size * 0.09))
                .offset(x: cloudDriftBack ? -size * 0.08 : size * 0.08)

            RoundedRectangle(cornerRadius: size * 0.05)
                .fill(Color.white.opacity(0.7))
                .frame(width: size * 0.75, height: max(1.1, size * 0.08))
                .offset(x: cloudDriftBack ? size * 0.05 : -size * 0.05)
        }
    }

    private func startAnimations() {
        withAnimation(.linear(duration: 9.0).repeatForever(autoreverses: false)) {
            sunRotation = 360
        }
        withAnimation(.easeInOut(duration: 3.2).repeatForever(autoreverses: true)) {
            cloudDriftBack = true
        }
        withAnimation(.easeInOut(duration: 2.1).repeatForever(autoreverses: true)) {
            cloudFloatFront = true
        }
        withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
            moonGlow = true
        }
        withAnimation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true)) {
            windPhase = 1.0
        }

        if category == .thunderstorm {
            Timer.scheduledTimer(withTimeInterval: 2.8, repeats: true) { _ in
                withAnimation(.easeIn(duration: 0.08)) {
                    lightningFlash = 1.0
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.10) {
                    withAnimation(.easeOut(duration: 0.06)) {
                        lightningFlash = 0.2
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                    withAnimation(.easeIn(duration: 0.07)) {
                        lightningFlash = 1.0
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.32) {
                    withAnimation(.easeOut(duration: 0.15)) {
                        lightningFlash = 0.0
                    }
                }
            }
        }
    }
}

// MARK: - Rain Drop Timeline

struct RainDropTimeline: View {
    let delay: Double
    let size: CGFloat
    var slant: Double = 0.0
    @State private var progress: CGFloat = 0.0

    var body: some View {
        Capsule()
            .fill(Color(red: 56/255, green: 189/255, blue: 248/255))
            .frame(width: max(1.1, size * 0.09), height: max(2.2, size * 0.20))
            .rotationEffect(.degrees(slant))
            .offset(
                x: CGFloat(slant * 0.08 * Double(progress)),
                y: progress * (size * 0.36)
            )
            .opacity(progress < 0.15 ? progress * 6.6 : (progress > 0.75 ? (1.0 - progress) * 4.0 : 1.0))
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 0.72)
                    .repeatForever(autoreverses: false)
                    .delay(delay)
                ) {
                    progress = 1.0
                }
            }
    }
}

// MARK: - Snowflake Timeline

struct SnowFlakeTimeline: View {
    let delay: Double
    let size: CGFloat
    @State private var progress: CGFloat = 0.0

    var body: some View {
        Circle()
            .fill(Color.white.opacity(0.95))
            .frame(width: max(1.2, size * 0.11), height: max(1.2, size * 0.11))
            .offset(
                x: CGFloat(sin(Double(progress) * .pi * 2.0)) * (size * 0.10),
                y: progress * (size * 0.34)
            )
            .opacity(progress < 0.15 ? progress * 6.6 : (progress > 0.80 ? (1.0 - progress) * 5.0 : 1.0))
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 1.25)
                    .repeatForever(autoreverses: false)
                    .delay(delay)
                ) {
                    progress = 1.0
                }
            }
    }
}

// MARK: - Weather Manager

@Observable
final class WeatherManager {
    static let shared = WeatherManager()

    var currentWeather: WeatherData?
    var isLoading: Bool = false
    var lastError: String? = nil

    private var refreshTimer: Timer?
    private var isFetching = false

    private init() {
        Task { [weak self] in
            await self?.refreshWeather()
        }
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            Task { [weak self] in
                await self?.refreshWeather()
            }
        }
    }

    func refreshWeather() async {
        guard !isFetching else { return }
        isFetching = true
        isLoading = true

        if let appleWeather = fetchFromAppleWeather() {
            await MainActor.run {
                self.currentWeather = appleWeather
                self.isLoading = false
                self.isFetching = false
            }
            return
        }

        do {
            let loc = try await resolveLocation()
            let w = try await fetchOpenMeteo(lat: loc.lat, lon: loc.lon, city: loc.city, region: loc.region, country: loc.country)
            await MainActor.run {
                self.currentWeather = w
                self.isLoading = false
                self.isFetching = false
            }
        } catch {
            await MainActor.run {
                self.lastError = error.localizedDescription
                self.isLoading = false
                self.isFetching = false
            }
        }
    }

    private func fetchFromAppleWeather() -> WeatherData? {
        if let fromUI = fetchAppleWeatherUI() {
            return fromUI
        }
        if let fromDB = fetchAppleWeatherDB() {
            return fromDB
        }
        return nil
    }

    private func fetchAppleWeatherUI() -> WeatherData? {
        let apps = NSWorkspace.shared.runningApplications.filter {
            $0.bundleIdentifier == "com.apple.weather" || $0.localizedName == "Cuaca" || $0.localizedName == "Weather"
        }
        guard let app = apps.first else { return nil }

        let appElem = AXUIElementCreateApplication(app.processIdentifier)
        var windowsVal: AnyObject?
        guard AXUIElementCopyAttributeValue(appElem, kAXWindowsAttribute as CFString, &windowsVal) == .success,
              let windows = windowsVal as? [AXUIElement],
              let w = windows.first else {
            return nil
        }

        var titleVal: AnyObject?
        AXUIElementCopyAttributeValue(w, kAXTitleAttribute as CFString, &titleVal)
        let city = (titleVal as? String) ?? "Kota Palembang"

        var found: WeatherData? = nil

        func search(_ elem: AXUIElement) {
            if found != nil { return }
            var descVal: AnyObject?
            AXUIElementCopyAttributeValue(elem, kAXDescriptionAttribute as CFString, &descVal)
            if let desc = descVal as? String {
                let pattern = #"(\\d+)\\s*(?:derajat\\s*Celsius|derajat|°)"#
                if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
                    let nsStr = desc as NSString
                    if let match = regex.firstMatch(in: desc, range: NSRange(location: 0, length: nsStr.length)) {
                        let tempStr = nsStr.substring(with: match.range(at: 1))
                        if let temp = Double(tempStr) {
                            let lower = desc.lowercased()
                            let isRain = lower.contains("hujan") || lower.contains("gerimis") || lower.contains("rain")
                            let isThunder = lower.contains("petir") || lower.contains("badai") || lower.contains("thunder")
                            let isCloudy = lower.contains("berawan") || lower.contains("mendung") || lower.contains("cloud")
                            let isClear = (lower.contains("cerah") || lower.contains("clear")) && !isCloudy
                            let code = isThunder ? 95 : (isRain ? 61 : (isClear ? 0 : (isCloudy ? 2 : 3)))

                            let detectedCity = desc.components(separatedBy: ",").first?.trimmingCharacters(in: .whitespacesAndNewlines) ?? city

                            found = WeatherData(
                                temperature: temp,
                                apparentTemperature: temp,
                                humidity: 75,
                                weatherCode: code,
                                isDay: true,
                                city: detectedCity.isEmpty ? city : detectedCity,
                                region: "Indonesia",
                                country: "Indonesia",
                                latitude: -2.99,
                                longitude: 104.76,
                                fetchedAt: Date(),
                                windSpeed: 8.0
                            )
                            return
                        }
                    }
                }
            }
            var childrenVal: AnyObject?
            AXUIElementCopyAttributeValue(elem, kAXChildrenAttribute as CFString, &childrenVal)
            if let children = childrenVal as? [AXUIElement] {
                for c in children {
                    search(c)
                    if found != nil { return }
                }
            }
        }

        search(w)
        return found
    }

    private func fetchAppleWeatherDB() -> WeatherData? {
        let home = FileManager.default.homeDirectoryForCurrentUser
        let dbPath = home.appendingPathComponent("Library/Weather/weather-data.db").path
        var db: OpaquePointer?
        guard sqlite3_open_v2(dbPath, &db, SQLITE_OPEN_READONLY, nil) == SQLITE_OK else { return nil }
        defer { sqlite3_close(db) }

        var lat = -2.99
        var lon = 104.76
        var cityName = "Kota Palembang"
        var tempFound: Double? = nil

        // 1. Get latest coordinates from currentWeather
        var cStmt: OpaquePointer?
        let cQuery = "SELECT latitude, longitude, model FROM currentWeather ORDER BY modified DESC LIMIT 1;"
        if sqlite3_prepare_v2(db, cQuery, -1, &cStmt, nil) == SQLITE_OK {
            if sqlite3_step(cStmt) == SQLITE_ROW {
                lat = sqlite3_column_double(cStmt, 0)
                lon = sqlite3_column_double(cStmt, 1)
                if let blob = sqlite3_column_blob(cStmt, 2) {
                    let bytes = sqlite3_column_bytes(cStmt, 2)
                    if bytes >= 462 {
                        let d = blob.advanced(by: 454).assumingMemoryBound(to: Double.self).pointee
                        if d > -50 && d < 60 {
                            tempFound = d
                        }
                    }
                }
            }
            sqlite3_finalize(cStmt)
        }

        // 2. Check hourForecast for current hour (most accurate real-time temperature)
        let now = Date().timeIntervalSince1970
        var hStmt: OpaquePointer?
        let hQuery = "SELECT model FROM hourForecast WHERE abs(startsAt - ?) < 3600 ORDER BY abs(startsAt - ?) ASC LIMIT 1;"
        if sqlite3_prepare_v2(db, hQuery, -1, &hStmt, nil) == SQLITE_OK {
            sqlite3_bind_double(hStmt, 1, now)
            sqlite3_bind_double(hStmt, 2, now)
            if sqlite3_step(hStmt) == SQLITE_ROW {
                if let blob = sqlite3_column_blob(hStmt, 0) {
                    let bytes = sqlite3_column_bytes(hStmt, 0)
                    if bytes >= 104 {
                        let d = blob.advanced(by: 96).assumingMemoryBound(to: Double.self).pointee
                        if d > -50 && d < 60 {
                            tempFound = d
                        }
                    }
                }
            }
            sqlite3_finalize(hStmt)
        }

        guard let temperature = tempFound else { return nil }

        // 3. Extract city name from locationInfo
        var lStmt: OpaquePointer?
        let lQuery = "SELECT model FROM locationInfo WHERE abs(latitude - ?) < 0.1 AND abs(longitude - ?) < 0.1 LIMIT 1;"
        if sqlite3_prepare_v2(db, lQuery, -1, &lStmt, nil) == SQLITE_OK {
            sqlite3_bind_double(lStmt, 1, lat)
            sqlite3_bind_double(lStmt, 2, lon)
            if sqlite3_step(lStmt) == SQLITE_ROW {
                if let blob = sqlite3_column_blob(lStmt, 0) {
                    let bytes = sqlite3_column_bytes(lStmt, 0)
                    let data = Data(bytes: blob, count: Int(bytes))
                    if let str = String(data: data, encoding: .ascii) {
                        let regex = try? NSRegularExpression(pattern: "(Kota [A-Za-z ]+|Palembang|Jakarta)")
                        let ns = str as NSString
                        if let match = regex?.firstMatch(in: str, range: NSRange(location: 0, length: ns.length)) {
                            cityName = ns.substring(with: match.range(at: 1))
                        }
                    }
                }
            }
            sqlite3_finalize(lStmt)
        }

        return WeatherData(
            temperature: temperature,
            apparentTemperature: temperature,
            humidity: 78,
            weatherCode: 2,
            isDay: true,
            city: cityName,
            region: "Indonesia",
            country: "Indonesia",
            latitude: lat,
            longitude: lon,
            fetchedAt: Date(),
            windSpeed: 8.0
        )
    }

    private func extractDouble(from str: String, key: String) -> Double? {
        guard let range = str.range(of: "\"" + key + "\"") else { return nil }
        let sub = str[range.upperBound...]
        let regex = try? NSRegularExpression(pattern: #":\s*(-?\d+(?:\.\d+)?)"#, options: [])
        let ns = String(sub) as NSString
        if let match = regex?.firstMatch(in: String(sub), range: NSRange(location: 0, length: min(ns.length, 50))) {
            return Double(ns.substring(with: match.range(at: 1)))
        }
        return nil
    }

    private func extractInt(from str: String, key: String) -> Int? {
        if let d = extractDouble(from: str, key: key) {
            return Int(d)
        }
        return nil
    }

    private struct IPLocation {
        let lat: Double
        let lon: Double
        let city: String
        let region: String
        let country: String
    }

    private func resolveLocation() async throws -> IPLocation {
        let home = FileManager.default.homeDirectoryForCurrentUser
        let dbPath = home.appendingPathComponent("Library/Weather/weather-data.db").path
        var db: OpaquePointer?
        if sqlite3_open_v2(dbPath, &db, SQLITE_OPEN_READONLY, nil) == SQLITE_OK {
            defer { sqlite3_close(db) }
            var stmt: OpaquePointer?
            if sqlite3_prepare_v2(db, "SELECT latitude, longitude FROM currentWeather ORDER BY modified DESC LIMIT 1;", -1, &stmt, nil) == SQLITE_OK {
                if sqlite3_step(stmt) == SQLITE_ROW {
                    let lat = sqlite3_column_double(stmt, 0)
                    let lon = sqlite3_column_double(stmt, 1)
                    sqlite3_finalize(stmt)
                    return IPLocation(
                        lat: lat,
                        lon: lon,
                        city: "Kota Palembang",
                        region: "Sumatera Selatan",
                        country: "Indonesia"
                    )
                }
                sqlite3_finalize(stmt)
            }
        }

        if let savedCity = UserDefaults.standard.string(forKey: "settings.weather.city"),
           !savedCity.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            if let loc = try? await geocodeCity(savedCity) {
                return loc
            }
        }

        if let loc = try? await ipGeolocation() {
            return loc
        }

        return IPLocation(
            lat: -2.99,
            lon: 104.76,
            city: "Kota Palembang",
            region: "Sumatera Selatan",
            country: "Indonesia"
        )
    }

    private func geocodeCity(_ query: String) async throws -> IPLocation {
        let clean = query.components(separatedBy: ",").first ?? query
        let encoded = clean.trimmingCharacters(in: .whitespacesAndNewlines).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? clean
        guard let url = URL(string: "https://geocoding-api.open-meteo.com/v1/search?name=\(encoded)&count=1&language=id&format=json") else {
            throw URLError(.badURL)
        }
        var req = URLRequest(url: url)
        req.timeoutInterval = 8.0
        let (data, _) = try await URLSession.shared.data(for: req)
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let results = json["results"] as? [[String: Any]],
              let first = results.first,
              let lat = first["latitude"] as? Double,
              let lon = first["longitude"] as? Double else {
            throw URLError(.cannotParseResponse)
        }

        return IPLocation(
            lat: lat,
            lon: lon,
            city: (first["name"] as? String) ?? clean,
            region: (first["admin1"] as? String) ?? "",
            country: (first["country"] as? String) ?? ""
        )
    }

    private func ipGeolocation() async throws -> IPLocation {
        guard let url = URL(string: "http://ip-api.com/json/?fields=status,country,regionName,city,lat,lon") else {
            throw URLError(.badURL)
        }
        var req = URLRequest(url: url)
        req.timeoutInterval = 6.0
        let (data, _) = try await URLSession.shared.data(for: req)
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              (json["status"] as? String) == "success",
              let lat = json["lat"] as? Double,
              let lon = json["lon"] as? Double else {
            throw URLError(.cannotParseResponse)
        }

        return IPLocation(
            lat: lat,
            lon: lon,
            city: (json["city"] as? String) ?? "Unknown",
            region: (json["regionName"] as? String) ?? "",
            country: (json["country"] as? String) ?? ""
        )
    }

    private func fetchOpenMeteo(lat: Double, lon: Double, city: String, region: String, country: String) async throws -> WeatherData {
        let urlStr = String(
            format: "https://api.open-meteo.com/v1/forecast?latitude=%.4f&longitude=%.4f&current=temperature_2m,relative_humidity_2m,apparent_temperature,is_day,weather_code,wind_speed_10m&timezone=auto",
            lat, lon
        )
        guard let url = URL(string: urlStr) else {
            throw URLError(.badURL)
        }
        var req = URLRequest(url: url)
        req.timeoutInterval = 10.0
        let (data, _) = try await URLSession.shared.data(for: req)
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let current = json["current"] as? [String: Any],
              let temp = current["temperature_2m"] as? Double,
              let apparentTemp = current["apparent_temperature"] as? Double,
              let humidity = current["relative_humidity_2m"] as? Int,
              let isDayInt = current["is_day"] as? Int,
              let weatherCode = current["weather_code"] as? Int else {
            throw URLError(.cannotParseResponse)
        }
        let windSpeed = (current["wind_speed_10m"] as? Double) ?? 0.0
        return WeatherData(
            temperature: temp,
            apparentTemperature: apparentTemp,
            humidity: humidity,
            weatherCode: weatherCode,
            isDay: isDayInt == 1,
            city: city,
            region: region,
            country: country,
            latitude: lat,
            longitude: lon,
            fetchedAt: Date(),
            windSpeed: windSpeed
        )
    }
}

// MARK: - Nusa Mascot Eye Animation

struct HappyArcShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.maxY),
            control: CGPoint(x: rect.midX, y: rect.minY)
        )
        return path
    }
}

struct SleepingEyeShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY + 2))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.minY + 2),
            control: CGPoint(x: rect.midX, y: rect.maxY)
        )
        return path
    }
}

struct MascotEyeView: View {
    var isHovering: Bool = false

    @State private var blinkScaleY: CGFloat = 1.0
    @State private var eyeOffsetX: CGFloat = 0.0
    @State private var eyeOffsetY: CGFloat = 0.0
    @State private var isSleeping: Bool = false
    @State private var isHappy: Bool = false
    @State private var sleepBreathingScale: CGFloat = 1.0
    @State private var lastActivityTime: Date = Date()
    @State private var sleepZOffset: CGFloat = 0.0
    @State private var sleepZOpacity: Double = 0.0

    @State private var blinkTimer: Timer?
    @State private var glanceTimer: Timer?
    @State private var idleCheckTimer: Timer?
    @State private var sleepZTimer: Timer?

    private let eyeWidth: CGFloat = 6.8
    private let eyeHeight: CGFloat = 11.0
    private let eyeGap: CGFloat = 8.5

    var body: some View {
        ZStack {
            RadialGradient(
                colors: [
                    Color(red: 120/255, green: 190/255, blue: 1.0).opacity(0.22),
                    Color.clear
                ],
                center: .center,
                startRadius: 2,
                endRadius: 14
            )
            .frame(width: 32, height: 20)

            if isSleeping {
                Text("z")
                    .font(.system(size: 7, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 140/255, green: 200/255, blue: 1.0).opacity(sleepZOpacity))
                    .offset(x: 12, y: sleepZOffset)
            }

            HStack(spacing: eyeGap) {
                singleEye()
                singleEye()
            }
            .offset(x: eyeOffsetX, y: eyeOffsetY)
            .scaleEffect(isSleeping ? sleepBreathingScale : 1.0)
        }
        .frame(width: 28, height: 18)
        .onAppear { startTimers() }
        .onDisappear { stopTimers() }
        .onChange(of: isHovering) { _, hovering in
            if hovering { handleHoverWakeUp() }
        }
    }

    @ViewBuilder
    private func singleEye() -> some View {
        if isHappy && !isSleeping {
            HappyArcShape()
                .stroke(Color.white, style: StrokeStyle(lineWidth: 2.0, lineCap: .round))
                .frame(width: eyeWidth * 1.15, height: eyeHeight * 0.65)
                .shadow(color: Color(red: 120/255, green: 190/255, blue: 1.0).opacity(0.85), radius: 2.5)
                .shadow(color: Color(red: 80/255, green: 140/255, blue: 1.0).opacity(0.40), radius: 5.0)
        } else if isSleeping {
            SleepingEyeShape()
                .stroke(Color(red: 150/255, green: 205/255, blue: 1.0), style: StrokeStyle(lineWidth: 1.8, lineCap: .round))
                .frame(width: eyeWidth * 1.1, height: eyeHeight * 0.5)
                .shadow(color: Color(red: 100/255, green: 170/255, blue: 1.0).opacity(0.55), radius: 2.0)
        } else {
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white,
                            Color(red: 140/255, green: 205/255, blue: 1.0)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: eyeWidth, height: eyeHeight)
                .scaleEffect(y: blinkScaleY, anchor: .center)
                .shadow(color: Color(red: 120/255, green: 190/255, blue: 1.0).opacity(0.85), radius: 2.5)
                .shadow(color: Color(red: 80/255, green: 140/255, blue: 1.0).opacity(0.40), radius: 5.5)
        }
    }

    private func startTimers() {
        scheduleNextBlink()
        scheduleNextGlance()

        idleCheckTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [self] _ in
            let idleTime = Date().timeIntervalSince(lastActivityTime)
            if idleTime > 40.0 && !isSleeping && !isHovering {
                enterSleep()
            }
        }
    }

    private func stopTimers() {
        blinkTimer?.invalidate(); blinkTimer = nil
        glanceTimer?.invalidate(); glanceTimer = nil
        idleCheckTimer?.invalidate(); idleCheckTimer = nil
        sleepZTimer?.invalidate(); sleepZTimer = nil
    }

    private func scheduleNextBlink() {
        let interval = Double.random(in: 2.0...4.5)
        blinkTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { [self] _ in
            triggerBlink()
        }
    }

    private func triggerBlink() {
        guard !isSleeping, !isHappy else {
            scheduleNextBlink()
            return
        }

        withAnimation(.easeIn(duration: 0.08)) {
            blinkScaleY = 0.05
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.09) {
            withAnimation(.easeOut(duration: 0.11)) {
                self.blinkScaleY = 1.0
            }

            if Double.random(in: 0...1) < 0.22 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.16) {
                    withAnimation(.easeIn(duration: 0.07)) { self.blinkScaleY = 0.05 }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
                        withAnimation(.easeOut(duration: 0.10)) { self.blinkScaleY = 1.0 }
                        self.scheduleNextBlink()
                    }
                }
            } else {
                self.scheduleNextBlink()
            }
        }
    }

    private func scheduleNextGlance() {
        let interval = Double.random(in: 3.5...7.0)
        glanceTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { [self] _ in
            triggerGlance()
        }
    }

    private func triggerGlance() {
        guard !isSleeping, !isHappy else {
            scheduleNextGlance()
            return
        }

        let glances: [(CGFloat, CGFloat)] = [
            (-2.0, 0.0),
            (2.0, 0.0),
            (-1.5, -1.0),
            (1.5, -1.0),
            (0.0, 0.0)
        ]
        let target = glances.randomElement() ?? (0.0, 0.0)

        withAnimation(.spring(response: 0.22, dampingFraction: 0.72)) {
            eyeOffsetX = target.0
            eyeOffsetY = target.1
        }

        let holdDuration = Double.random(in: 0.8...1.8)
        DispatchQueue.main.asyncAfter(deadline: .now() + holdDuration) {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.75)) {
                self.eyeOffsetX = 0.0
                self.eyeOffsetY = 0.0
            }
            self.scheduleNextGlance()
        }
    }

    func handleHoverWakeUp() {
        lastActivityTime = Date()
        if isSleeping {
            wakeUp()
        }
        withAnimation(.spring(response: 0.28, dampingFraction: 0.65)) {
            isHappy = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.easeInOut(duration: 0.3)) {
                self.isHappy = false
            }
        }
    }

    private func enterSleep() {
        withAnimation(.easeInOut(duration: 0.5)) {
            isSleeping = true
            eyeOffsetX = 0
            eyeOffsetY = 0
        }
        startSleepBreathing()
        startSleepZAnimation()
    }

    private func wakeUp() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
            isSleeping = false
            sleepBreathingScale = 1.0
        }
        sleepZTimer?.invalidate()
        sleepZTimer = nil
        sleepZOpacity = 0.0
    }

    private func startSleepBreathing() {
        guard isSleeping else { return }
        withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
            sleepBreathingScale = 1.08
        }
    }

    private func startSleepZAnimation() {
        sleepZTimer = Timer.scheduledTimer(withTimeInterval: 2.4, repeats: true) { [self] _ in
            guard isSleeping else { return }
            sleepZOffset = 0.0
            sleepZOpacity = 0.8
            withAnimation(.easeOut(duration: 2.0)) {
                sleepZOffset = -10.0
                sleepZOpacity = 0.0
            }
        }
    }
}

// MARK: - Combined Nusa Notch Overlay View

struct NusaPillOverlayView: View {
    private var weather = WeatherManager.shared
    var isHovering: Bool

    init(isHovering: Bool = false) {
        self.isHovering = isHovering
    }

    var body: some View {
        HStack(spacing: 5) {
            // Weather indicator on the left with Animated Weather Icon
            HStack(spacing: 3) {
                if let data = weather.currentWeather {
                    AnimatedWeatherIconView(
                        weatherCode: data.weatherCode,
                        isDay: data.isDay,
                        windSpeed: data.windSpeed,
                        size: 15
                    )
                    Text("\(Int(round(data.temperature)))°")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundColor(.white.opacity(0.92))
                } else {
                    ProgressView()
                        .scaleEffect(0.4)
                        .frame(width: 12, height: 12)
                }
            }
            .padding(.leading, 6)

            Spacer()

            // Animated glowing Nusa eyes on the right
            MascotEyeView(isHovering: isHovering)
                .padding(.trailing, 6)
        }
        .frame(width: 120, height: 28)
        .background(Color.clear)
    }
}

// MARK: - AppKit Hit-Through View

class ClickThroughHostingView<Content: View>: NSHostingView<Content> {
    override func hitTest(_ point: NSPoint) -> NSView? {
        return nil
    }
}

// MARK: - Plugin Injector

@objc public class NusaNotchPlugin: NSObject {
    private static var instance: NusaNotchPlugin?
    private var hostingView: ClickThroughHostingView<NusaPillOverlayView>?
    private var monitorTimer: Timer?
    private var isMouseNearby = false

    @objc public static func loadPlugin() {
        // Enforce anti-update defaults on launch
        UserDefaults.standard.set(false, forKey: "SUEnableAutomaticChecks")
        UserDefaults.standard.set(false, forKey: "SUAutomaticallyUpdate")
        UserDefaults.standard.removeObject(forKey: "requiredUpdate.minimumBuild")
        UserDefaults.standard.removeObject(forKey: "requiredUpdate.deadline")
        UserDefaults.standard.removeObject(forKey: "NSWindow Frame SUUpdateAlert2")
        UserDefaults.standard.removeObject(forKey: "analytics.updateEventAt.check_found")
        UserDefaults.standard.synchronize()

        DispatchQueue.main.async {
            if instance == nil {
                instance = NusaNotchPlugin()
            }
        }
    }

    override init() {
        super.init()
        NSLog("[NusaNotch] Initialized with Animated Weather & Mascot Eyes!")

        NSEvent.addLocalMonitorForEvents(matching: [.mouseMoved]) { [weak self] event in
            guard let self = self else { return event }
            let loc = NSEvent.mouseLocation
            if let screen = NSScreen.main {
                let midX = screen.frame.midX
                let maxY = screen.frame.maxY
                let nearby = abs(loc.x - midX) < 80 && loc.y > (maxY - 45)
                if nearby != self.isMouseNearby {
                    self.isMouseNearby = nearby
                    self.updateOverlay(isHovering: nearby)
                }
            }
            return event
        }

        monitorTimer = Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }

    private func tick() {
        for win in NSApp.windows {
            let className = NSStringFromClass(type(of: win))
            if className.contains("SUUpdateAlert") || className.contains("RequiredUpdate") {
                win.orderOut(nil)
                win.close()
            }
        }

        guard let window = NSApp.windows.first(where: {
            NSStringFromClass(type(of: $0)).contains("NotchWindow") && $0.contentView != nil
        }) else { return }

        guard let contentView = window.contentView else { return }

        let pillWidth: CGFloat = 120
        let pillHeight: CGFloat = 28
        let targetX = (contentView.bounds.width - pillWidth) / 2
        let targetY = contentView.bounds.height - pillHeight - 2
        let targetFrame = NSRect(x: targetX, y: targetY, width: pillWidth, height: pillHeight)

        if hostingView == nil || hostingView?.superview == nil {
            let host = ClickThroughHostingView(rootView: NusaPillOverlayView(isHovering: isMouseNearby))
            host.wantsLayer = true
            host.frame = targetFrame
            contentView.addSubview(host, positioned: .above, relativeTo: nil)
            hostingView = host
            NSLog("[NusaNotch] Attached overlay with Animated Weather to NotchWindow at %@", NSStringFromRect(targetFrame))
        } else if let host = hostingView {
            if host.frame != targetFrame {
                host.frame = targetFrame
            }
            if host.superview != contentView {
                contentView.addSubview(host, positioned: .above, relativeTo: nil)
            }
            host.isHidden = false
        }
    }

    private func updateOverlay(isHovering: Bool) {
        hostingView?.rootView = NusaPillOverlayView(isHovering: isHovering)
    }
}

@_cdecl("nusa_notch_init")
public func nusaNotchInit() {
    NusaNotchPlugin.loadPlugin()
}
