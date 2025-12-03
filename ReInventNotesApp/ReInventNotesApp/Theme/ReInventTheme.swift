import SwiftUI

struct ReInventTheme {
    // AWS re:Invent rainbow gradient colors
    static let rainbowColors = [
        Color(red: 0.4, green: 0.2, blue: 1.0),    // Purple
        Color(red: 0.0, green: 0.4, blue: 1.0),    // Blue
        Color(red: 0.0, green: 0.8, blue: 0.6),    // Teal
        Color(red: 1.0, green: 0.6, blue: 0.0),    // Orange
        Color(red: 1.0, green: 0.2, blue: 0.4)     // Pink
    ]
    
    var rainbowGradient: LinearGradient {
        LinearGradient(
            colors: Self.rainbowColors,
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    var accentColor: Color {
        Color(red: 1.0, green: 0.6, blue: 0.0)
    }
    
    var cardBackground: Color {
        Color(red: 0.1, green: 0.1, blue: 0.1)
    }
    
    var backgroundColor: Color {
        Color.black
    }
    
    var primaryTextColor: Color {
        .white
    }
    
    var secondaryTextColor: Color {
        Color.gray
    }
}

class ReInventThemeManager: ObservableObject {
    @Published var theme = ReInventTheme()
}

// Rainbow border button style
struct RainbowBorderButtonStyle: ButtonStyle {
    let theme: ReInventTheme
    var compact: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: compact ? 14 : 16, weight: .medium))
            .padding(.horizontal, compact ? 12 : 20)
            .padding(.vertical, compact ? 6 : 10)
            .frame(minWidth: compact ? 60 : 80)
            .background(theme.cardBackground)
            .foregroundStyle(theme.rainbowGradient)
            .clipShape(RoundedRectangle(cornerRadius: compact ? 16 : 20))
            .overlay(
                RoundedRectangle(cornerRadius: compact ? 16 : 20)
                    .stroke(theme.rainbowGradient, lineWidth: 2)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}