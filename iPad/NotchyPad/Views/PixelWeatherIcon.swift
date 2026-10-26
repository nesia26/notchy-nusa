import SwiftUI

/// Pixel weather art for the Nusa island. The weather code comes directly
/// from Open-Meteo, so the visual condition stays in sync with the text and
/// temperature shown beside it.
public struct PixelWeatherIcon: View {
    public let weatherCode: Int
    public let isDay: Bool
    public var size: CGFloat

    private enum Kind {
        case sun, cloud, fog, precipitation, snow, storm, moon
    }

    public init(weatherCode: Int, isDay: Bool = true, size: CGFloat = 20) {
        self.weatherCode = weatherCode
        self.isDay = isDay
        self.size = size
    }

    private var kind: Kind {
        switch weatherCode {
        case 45, 48:
            return .fog
        case 51...57, 61...67, 80...82:
            return .precipitation
        case 71...77, 85...86:
            return .snow
        case 95...99:
            return .storm
        case 2, 3:
            return .cloud
        default:
            return isDay ? .sun : .moon
        }
    }

    public var body: some View {
        TimelineView(.animation(minimumInterval: 0.12, paused: false)) { timeline in
            GeometryReader { proxy in
                let phase = timeline.date.timeIntervalSinceReferenceDate
                let pixel = max(1, min(proxy.size.width, proxy.size.height) / 12)

                ZStack {
                    switch kind {
                    case .sun:
                        sun(pixel: pixel, phase: phase)
                    case .cloud:
                        cloud(pixel: pixel, phase: phase)
                    case .fog:
                        fog(pixel: pixel, phase: phase)
                    case .precipitation:
                        cloud(pixel: pixel, phase: phase)
                        precipitation(pixel: pixel, phase: phase)
                    case .snow:
                        cloud(pixel: pixel, phase: phase)
                        snow(pixel: pixel, phase: phase)
                    case .storm:
                        cloud(pixel: pixel, phase: phase)
                        storm(pixel: pixel)
                    case .moon:
                        moon(pixel: pixel)
                    }
                }
                .frame(width: proxy.size.width, height: proxy.size.height)
            }
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }

    @ViewBuilder
    private func sun(pixel: CGFloat, phase: TimeInterval) -> some View {
        let step = Int(phase * 2).quotientAndRemainder(dividingBy: 8).remainder
        let angle = Double(step) * .pi / 4
        let points: [(CGFloat, CGFloat)] = [
            (0, -4.5), (3.2, -3.2), (4.5, 0), (3.2, 3.2),
            (0, 4.5), (-3.2, 3.2), (-4.5, 0), (-3.2, -3.2)
        ]

        ZStack {
            ForEach(points.indices, id: \.self) { index in
                let point = points[index]
                Rectangle()
                    .fill(Color.yellow)
                    .frame(width: pixel * 1.45, height: pixel * 1.45)
                    .offset(
                        x: pixel * CGFloat(Double(point.0) * cos(angle) - Double(point.1) * sin(angle)),
                        y: pixel * CGFloat(Double(point.0) * sin(angle) + Double(point.1) * cos(angle))
                    )
            }
            Rectangle()
                .fill(Color.yellow)
                .frame(width: pixel * 4.1, height: pixel * 4.1)
                .shadow(color: .yellow.opacity(0.55), radius: pixel)
        }
    }

    @ViewBuilder
    private func cloud(pixel: CGFloat, phase: TimeInterval) -> some View {
        let step = Int(phase * 4).isMultiple(of: 2) ? -1.0 : 1.0
        ZStack(alignment: .bottomLeading) {
            Rectangle()
                .fill(Color(red: 0.74, green: 0.80, blue: 0.88))
                .frame(width: pixel * 8, height: pixel * 3)
                .offset(x: pixel * -0.2)
            Rectangle()
                .fill(Color(red: 0.80, green: 0.86, blue: 0.94))
                .frame(width: pixel * 4, height: pixel * 3)
                .offset(x: pixel * 1.2, y: pixel * -2.2)
            Rectangle()
                .fill(Color(red: 0.80, green: 0.86, blue: 0.94))
                .frame(width: pixel * 3, height: pixel * 2)
                .offset(x: pixel * 5.2, y: pixel * -1.3)
        }
        .frame(width: pixel * 9, height: pixel * 7, alignment: .bottomLeading)
        .offset(x: pixel * step * 0.55, y: pixel * 1.5)
    }

    @ViewBuilder
    private func fog(pixel: CGFloat, phase: TimeInterval) -> some View {
        cloud(pixel: pixel, phase: phase)
        VStack(spacing: pixel * 0.7) {
            Rectangle()
                .fill(Color.gray.opacity(0.85))
                .frame(width: pixel * 7, height: pixel * 0.8)
            Rectangle()
                .fill(Color.gray.opacity(0.65))
                .frame(width: pixel * 5, height: pixel * 0.8)
        }
        .offset(y: pixel * 3.7)
    }

    @ViewBuilder
    private func precipitation(pixel: CGFloat, phase: TimeInterval) -> some View {
        let columns: [CGFloat] = [-2.8, 0, 2.8]
        ForEach(columns.indices, id: \.self) { index in
            let progress = (phase * 1.65 + Double(index) * 0.31)
                .truncatingRemainder(dividingBy: 1)
            Rectangle()
                .fill(Color.cyan)
                .frame(width: pixel * 1.15, height: pixel * 2.25)
                .offset(
                    x: columns[index] * pixel,
                    y: pixel * CGFloat(1 + progress * 6)
                )
                .opacity(progress < 0.12 || progress > 0.9 ? 0 : 1)
        }
    }

    @ViewBuilder
    private func snow(pixel: CGFloat, phase: TimeInterval) -> some View {
        let columns: [CGFloat] = [-2.8, 0, 2.8]
        ForEach(columns.indices, id: \.self) { index in
            let progress = (phase * 0.85 + Double(index) * 0.31)
                .truncatingRemainder(dividingBy: 1)
            Rectangle()
                .fill(Color.white)
                .frame(width: pixel * 1.25, height: pixel * 1.25)
                .offset(
                    x: columns[index] * pixel,
                    y: pixel * CGFloat(1 + progress * 6)
                )
        }
    }

    @ViewBuilder
    private func storm(pixel: CGFloat) -> some View {
        Path { path in
            path.move(to: CGPoint(x: pixel * 5.8, y: pixel * 7.1))
            path.addLine(to: CGPoint(x: pixel * 4.1, y: pixel * 10.2))
            path.addLine(to: CGPoint(x: pixel * 5.5, y: pixel * 10.2))
            path.addLine(to: CGPoint(x: pixel * 4.8, y: pixel * 13.0))
            path.addLine(to: CGPoint(x: pixel * 7.2, y: pixel * 9.0))
            path.addLine(to: CGPoint(x: pixel * 5.8, y: pixel * 9.0))
            path.closeSubpath()
        }
        .fill(Color.yellow)
        .scaleEffect(0.72)
        .offset(x: pixel * 0.25, y: pixel * 0.3)
    }

    @ViewBuilder
    private func moon(pixel: CGFloat) -> some View {
        ZStack {
            Rectangle()
                .fill(Color(red: 0.55, green: 0.79, blue: 1))
                .frame(width: pixel * 3, height: pixel * 2)
                .offset(x: pixel * -1.1, y: pixel * -3)
            Rectangle()
                .fill(Color(red: 0.55, green: 0.79, blue: 1))
                .frame(width: pixel * 5, height: pixel * 3)
                .offset(x: pixel * -0.3)
            Rectangle()
                .fill(Color(red: 0.55, green: 0.79, blue: 1))
                .frame(width: pixel * 3, height: pixel * 2)
                .offset(x: pixel * -1.1, y: pixel * 3)
        }
    }
}
