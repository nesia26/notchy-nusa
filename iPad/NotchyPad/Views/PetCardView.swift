import SwiftUI

public struct PetCardView: View {
    @ObservedObject var state: NotchState
    @State private var petAction: String = "idle"
    @State private var happiness: Int = 90
    
    public var body: some View {
        VStack(spacing: 14) {
            HStack(spacing: 16) {
                // Interactive animated cat pet illustration
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 60, height: 60)
                    
                    Text("🐱")
                        .font(.system(size: 34))
                        .scaleEffect(petAction == "play" ? 1.2 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.5), value: petAction)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Midnight Cat")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text("❤️ \(happiness)%")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundColor(.pink)
                    }
                    
                    Text("Mood: \(petAction.capitalized) in the Notch")
                        .font(.system(size: 13, design: .rounded))
                        .foregroundColor(.white.opacity(0.65))
                }
                
                Spacer()
            }
            
            // Pet Action Buttons
            HStack(spacing: 12) {
                actionButton(icon: "heart.fill", label: "Pet", action: "love")
                actionButton(icon: "figure.play", label: "Play", action: "play")
                actionButton(icon: "fish.fill", label: "Feed", action: "feed")
                actionButton(icon: "moon.stars.fill", label: "Sleep", action: "sleep")
            }
        }
        .padding(.vertical, 4)
    }
    
    private func actionButton(icon: String, label: String, action: String) -> some View {
        Button(action: {
            petAction = action
            happiness = min(happiness + 5, 100)
            state.userDidInteract()
        }) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                Text(label)
                    .font(.system(size: 10, weight: .medium, design: .rounded))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(
                petAction == action
                ? state.eyeColor.primaryColor.opacity(0.25)
                : Color.white.opacity(0.08)
            )
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .foregroundColor(.white)
        }
    }
}
