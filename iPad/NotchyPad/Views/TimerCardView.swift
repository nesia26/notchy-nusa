import SwiftUI

public struct TimerCardView: View {
    @State private var selectedMinutes: Int = 5
    @State private var remainingSeconds: Int = 300
    @State private var isRunning: Bool = false
    @State private var timer: Timer?
    
    let presets = [1, 2, 3, 5, 10, 25]
    
    public var body: some View {
        VStack(spacing: 16) {
            Text("Set a Timer")
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundColor(.white.opacity(0.85))
            
            // Preset pills
            HStack(spacing: 12) {
                ForEach(presets, id: \.self) { min in
                    Button(action: {
                        selectedMinutes = min
                        remainingSeconds = min * 60
                        isRunning = false
                        timer?.invalidate()
                    }) {
                        VStack(spacing: 2) {
                            Text("\(min)")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                            Text("min")
                                .font(.system(size: 10, weight: .medium, design: .rounded))
                                .foregroundColor(.white.opacity(0.6))
                        }
                        .frame(width: 48, height: 48)
                        .background(
                            selectedMinutes == min
                            ? Color.white.opacity(0.25)
                            : Color.white.opacity(0.08)
                        )
                        .clipShape(Circle())
                        .foregroundColor(.white)
                    }
                }
            }
            
            // Countdown display & Controls
            HStack(spacing: 20) {
                Text(formatTime(remainingSeconds))
                    .font(.system(size: 32, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                
                Button(action: toggleTimer) {
                    Image(systemName: isRunning ? "pause.fill" : "play.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.black)
                        .frame(width: 44, height: 44)
                        .background(Color.white)
                        .clipShape(Circle())
                }
                
                Button(action: resetTimer) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(Color.white.opacity(0.12))
                        .clipShape(Circle())
                }
            }
        }
        .padding(.vertical, 8)
    }
    
    private func formatTime(_ totalSeconds: Int) -> String {
        let mins = totalSeconds / 60
        let secs = totalSeconds % 60
        return String(format: "%02d:%02d", mins, secs)
    }
    
    private func toggleTimer() {
        if isRunning {
            isRunning = false
            timer?.invalidate()
        } else {
            isRunning = true
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                if remainingSeconds > 0 {
                    remainingSeconds -= 1
                } else {
                    isRunning = false
                    timer?.invalidate()
                }
            }
        }
    }
    
    private func resetTimer() {
        isRunning = false
        timer?.invalidate()
        remainingSeconds = selectedMinutes * 60
    }
}
