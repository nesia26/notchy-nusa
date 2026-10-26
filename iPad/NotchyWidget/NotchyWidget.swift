import WidgetKit
import SwiftUI

// MARK: - Timeline Provider
struct NotchyTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> NotchyWidgetEntry {
        NotchyWidgetEntry(
            date: Date(),
            temperature: 30,
            conditionIcon: "cloud.sun.fill",
            songTitle: "Dua Cincin",
            artist: "Hello ft. Ifan Seventeen",
            isPlaying: true
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (NotchyWidgetEntry) -> Void) {
        let entry = NotchyWidgetEntry(
            date: Date(),
            temperature: 30,
            conditionIcon: "cloud.sun.fill",
            songTitle: "Dua Cincin",
            artist: "Hello ft. Ifan Seventeen",
            isPlaying: true
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<NotchyWidgetEntry>) -> Void) {
        let currentDate = Date()
        var entries: [NotchyWidgetEntry] = []
        
        // Generate hourly timeline entries
        for hourOffset in 0..<5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate) ?? currentDate
            let entry = NotchyWidgetEntry(
                date: entryDate,
                temperature: 30,
                conditionIcon: "cloud.sun.fill",
                songTitle: "Dua Cincin",
                artist: "Hello ft. Ifan Seventeen",
                isPlaying: true
            )
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

// MARK: - Timeline Entry
struct NotchyWidgetEntry: TimelineEntry {
    let date: Date
    let temperature: Int
    let conditionIcon: String
    let songTitle: String
    let artist: String
    let isPlaying: Bool
}

// MARK: - Shapes
struct WidgetHappyArc: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY - 2))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.maxY - 2),
            control: CGPoint(x: rect.midX, y: rect.minY + 2)
        )
        return path
    }
}

// MARK: - Widget Views
struct NotchyWidgetEntryView: View {
    var entry: NotchyTimelineProvider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            smallWidgetView
        case .systemMedium:
            mediumWidgetView
        case .systemLarge:
            largeWidgetView
        case .accessoryRectangular:
            accessoryRectangularView
        case .accessoryCircular:
            accessoryCircularView
        default:
            mediumWidgetView
        }
    }
    
    // MARK: - Medium Widget (Dynamic Island Notch Pill)
    private var mediumWidgetView: some View {
        ZStack {
            Color.black
            
            VStack(spacing: 12) {
                // The Living Notch Pill
                HStack(spacing: 12) {
                    // Album Art & Weather
                    HStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(LinearGradient(colors: [.pink, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                                .frame(width: 24, height: 24)
                            Image(systemName: "music.note")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.white)
                        }
                        
                        HStack(spacing: 4) {
                            Image(systemName: entry.conditionIcon)
                                .font(.system(size: 13))
                                .foregroundColor(.white.opacity(0.85))
                            Text("\(entry.temperature)°")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.leading, 12)
                    
                    Spacer()
                    
                    // Cyan Glowing Nusa Mascot Eyes ^^
                    HStack(spacing: 7) {
                        WidgetHappyArc()
                            .stroke(Color(red: 0.2, green: 0.9, blue: 1.0), style: StrokeStyle(lineWidth: 3, lineCap: .round))
                            .frame(width: 13, height: 9)
                            .shadow(color: Color(red: 0.2, green: 0.9, blue: 1.0).opacity(0.8), radius: 5)
                        
                        WidgetHappyArc()
                            .stroke(Color(red: 0.2, green: 0.9, blue: 1.0), style: StrokeStyle(lineWidth: 3, lineCap: .round))
                            .frame(width: 13, height: 9)
                            .shadow(color: Color(red: 0.2, green: 0.9, blue: 1.0).opacity(0.8), radius: 5)
                    }
                    
                    Spacer()
                    
                    // Equalizer bars
                    HStack(spacing: 2.5) {
                        Capsule().fill(Color(red: 0.2, green: 0.9, blue: 1.0)).frame(width: 2.5, height: 12)
                        Capsule().fill(Color(red: 0.2, green: 0.9, blue: 1.0)).frame(width: 2.5, height: 16)
                        Capsule().fill(Color(red: 0.2, green: 0.9, blue: 1.0)).frame(width: 2.5, height: 10)
                        Capsule().fill(Color(red: 0.2, green: 0.9, blue: 1.0)).frame(width: 2.5, height: 14)
                    }
                    .padding(.trailing, 12)
                }
                .frame(height: 44)
                .background(Color.white.opacity(0.1))
                .clipShape(Capsule())
                .overlay(Capsule().stroke(Color.white.opacity(0.15), lineWidth: 0.8))
                
                // Track Info & Controls
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(entry.songTitle)
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        Text(entry.artist)
                            .font(.system(size: 11, design: .rounded))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 16) {
                        Image(systemName: "backward.fill").font(.system(size: 14)).foregroundColor(.white.opacity(0.8))
                        Image(systemName: "pause.fill").font(.system(size: 16)).foregroundColor(.white)
                        Image(systemName: "forward.fill").font(.system(size: 14)).foregroundColor(.white.opacity(0.8))
                    }
                }
                .padding(.horizontal, 8)
            }
            .padding(14)
        }
    }
    
    // MARK: - Small Widget
    private var smallWidgetView: some View {
        ZStack {
            Color.black
            
            VStack(spacing: 10) {
                // Mascot Eyes
                HStack(spacing: 8) {
                    WidgetHappyArc()
                        .stroke(Color(red: 0.2, green: 0.9, blue: 1.0), style: StrokeStyle(lineWidth: 3.5, lineCap: .round))
                        .frame(width: 16, height: 11)
                        .shadow(color: Color(red: 0.2, green: 0.9, blue: 1.0), radius: 6)
                    WidgetHappyArc()
                        .stroke(Color(red: 0.2, green: 0.9, blue: 1.0), style: StrokeStyle(lineWidth: 3.5, lineCap: .round))
                        .frame(width: 16, height: 11)
                        .shadow(color: Color(red: 0.2, green: 0.9, blue: 1.0), radius: 6)
                }
                
                Text("Notchy Nusa")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                HStack(spacing: 4) {
                    Image(systemName: entry.conditionIcon)
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.85))
                    Text("\(entry.temperature)°C")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
            }
            .padding()
        }
    }
    
    // MARK: - Large Widget
    private var largeWidgetView: some View {
        ZStack {
            Color.black
            
            VStack(spacing: 16) {
                mediumWidgetView
                
                Divider().background(Color.white.opacity(0.15))
                
                // Pet Status Card
                HStack(spacing: 14) {
                    Text("🐱")
                        .font(.system(size: 38))
                        .frame(width: 54, height: 54)
                        .background(Color.white.opacity(0.1))
                        .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Midnight Cat")
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        Text("Chilling in the Island Notch")
                            .font(.system(size: 12, design: .rounded))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    
                    Spacer()
                    
                    Text("❤️ 95%")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(.pink)
                }
                .padding(.horizontal, 14)
            }
        }
    }
    
    // MARK: - Lock Screen Accessory Views
    private var accessoryRectangularView: some View {
        HStack(spacing: 8) {
            HStack(spacing: 4) {
                WidgetHappyArc().stroke(Color.white, lineWidth: 2).frame(width: 10, height: 6)
                WidgetHappyArc().stroke(Color.white, lineWidth: 2).frame(width: 10, height: 6)
            }
            VStack(alignment: .leading) {
                Text("Notchy Nusa").font(.system(size: 12, weight: .bold))
                Text("\(entry.temperature)° • \(entry.songTitle)").font(.system(size: 10))
            }
        }
    }
    
    private var accessoryCircularView: some View {
        ZStack {
            AccessoryWidgetBackground()
            HStack(spacing: 4) {
                WidgetHappyArc().stroke(Color.white, lineWidth: 2).frame(width: 8, height: 5)
                WidgetHappyArc().stroke(Color.white, lineWidth: 2).frame(width: 8, height: 5)
            }
        }
    }
}

// MARK: - Widget Definition
struct NotchyLivingNotchWidget: Widget {
    let kind: String = "NotchyLivingNotchWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: NotchyTimelineProvider()) { entry in
            NotchyWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Notchy Nusa Island")
        .description("Living dynamic island notch mascot and now-playing status on iPad.")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .systemLarge,
            .accessoryCircular,
            .accessoryRectangular
        ])
    }
}

// MARK: - Widget Bundle
@main
struct NotchyWidgetBundle: WidgetBundle {
    var body: some Widget {
        NotchyLivingNotchWidget()
    }
}
