import SwiftUI

public struct HappyArcShape: Shape {
    public func path(in rect: CGRect) -> Path {
        var path = Path()
        // Draw an upward curved happy arc (smile ^^)
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY - 2))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.maxY - 2),
            control: CGPoint(x: rect.midX, y: rect.minY + 2)
        )
        return path
    }
}

public struct SleepingEyeShape: Shape {
    public func path(in rect: CGRect) -> Path {
        var path = Path()
        // Draw a relaxed downward sleeping line/arc
        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.midY),
            control: CGPoint(x: rect.midX, y: rect.maxY)
        )
        return path
    }
}

public struct MascotEyeView: View {
    @ObservedObject var state: NotchState
    var isHoveringOrActive: Bool = false
    
    @State private var blinkScaleY: CGFloat = 1.0
    @State private var eyeOffsetX: CGFloat = 0.0
    @State private var eyeOffsetY: CGFloat = 0.0
    @State private var zOffset: CGFloat = 0.0
    @State private var zOpacity: Double = 0.0
    
    @State private var blinkTimer: Timer?
    @State private var glanceTimer: Timer?
    @State private var zTimer: Timer?
    
    public init(state: NotchState, isHoveringOrActive: Bool = false) {
        self.state = state
        self.isHoveringOrActive = isHoveringOrActive
    }
    
    public var body: some View {
        ZStack {
            // Sleeping 'z' animation when idle
            if state.isIdle {
                Text("z")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundColor(state.eyeColor.primaryColor)
                    .offset(x: 14 + zOffset, y: -8 - zOffset)
                    .opacity(zOpacity)
            }
            
            HStack(spacing: 8) {
                singleEyeView
                singleEyeView
            }
            .offset(x: eyeOffsetX, y: eyeOffsetY)
            .scaleEffect(y: blinkScaleY)
        }
        .frame(width: 44, height: 24)
        .onAppear {
            startAnimationTimers()
        }
        .onDisappear {
            blinkTimer?.invalidate()
            glanceTimer?.invalidate()
            zTimer?.invalidate()
        }
    }
    
    @ViewBuilder
    private var singleEyeView: some View {
        let eyeColor = state.eyeColor.primaryColor
        
        if isHoveringOrActive {
            // Happy smiling eyes ^^
            HappyArcShape()
                .stroke(eyeColor, style: StrokeStyle(lineWidth: 3.2, lineCap: .round))
                .frame(width: 13, height: 9)
                .shadow(color: eyeColor.opacity(0.8), radius: 5, x: 0, y: 0)
        } else if state.isIdle {
            // Sleeping eyes
            SleepingEyeShape()
                .stroke(eyeColor.opacity(0.7), style: StrokeStyle(lineWidth: 2.8, lineCap: .round))
                .frame(width: 12, height: 7)
                .shadow(color: eyeColor.opacity(0.5), radius: 4, x: 0, y: 0)
        } else {
            // Normal rounded pill capsule eyes
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [eyeColor, eyeColor.opacity(0.85)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 8, height: 13)
                .shadow(color: eyeColor.opacity(0.75), radius: 4, x: 0, y: 0)
        }
    }
    
    private func startAnimationTimers() {
        // Natural random blinking timer
        blinkTimer = Timer.scheduledTimer(withTimeInterval: 3.5, repeats: true) { _ in
            guard !state.isIdle && !isHoveringOrActive else { return }
            
            withAnimation(.easeInOut(duration: 0.1)) {
                blinkScaleY = 0.1
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                withAnimation(.easeInOut(duration: 0.12)) {
                    blinkScaleY = 1.0
                }
            }
        }
        
        // Random glance/look around timer
        glanceTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            guard !state.isIdle && !isHoveringOrActive else { return }
            let randomDir = [-2.0, 0.0, 2.0, 0.0, -1.5, 1.5].randomElement() ?? 0.0
            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                eyeOffsetX = randomDir
            }
        }
        
        // Zzz floating animation timer
        zTimer = Timer.scheduledTimer(withTimeInterval: 1.8, repeats: true) { _ in
            guard state.isIdle else { return }
            zOffset = 0
            zOpacity = 0.8
            withAnimation(.easeOut(duration: 1.5)) {
                zOffset = 6
                zOpacity = 0.0
            }
        }
    }
}
