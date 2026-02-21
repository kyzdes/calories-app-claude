import SwiftUI

struct CalorieRingView: View {
    let consumed: Int
    let goal: Int

    private var progress: Double {
        guard goal > 0 else { return 0 }
        return Double(consumed) / Double(goal)
    }

    private var remaining: Int {
        max(0, goal - consumed)
    }

    private var exceeded: Int {
        max(0, consumed - goal)
    }

    private var ringColor: Color {
        switch progress {
        case ..<0.9: .cmPrimary
        case 0.9..<1.0: .cmWarning
        default: .cmDanger
        }
    }

    private var subtitleText: String {
        if consumed == 0 {
            return ""
        } else if progress > 1.0 {
            return "Превышено на \(exceeded.formattedCaloriesValue)\u{00A0}ккал"
        } else if progress >= 0.9 {
            return "Почти у цели"
        } else {
            return "Осталось: \(remaining.formattedCaloriesValue)\u{00A0}ккал"
        }
    }

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                // Track (background ring)
                Circle()
                    .stroke(Color.cmBgTertiary, lineWidth: 14)

                // Progress ring
                Circle()
                    .trim(from: 0, to: min(progress, 1.0))
                    .stroke(ringColor, style: StrokeStyle(lineWidth: 14, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: progress)

                // Center text
                VStack(spacing: 2) {
                    Text(consumed.formattedCaloriesValue)
                        .font(.cmHero)
                        .foregroundStyle(Color.cmTextPrimary)
                        .contentTransition(.numericText())

                    Text("из \(goal.formattedCaloriesValue)")
                        .font(.cmCallout)
                        .foregroundStyle(Color.cmTextSecondary)

                    Text("ккал")
                        .font(.cmCaption)
                        .foregroundStyle(Color.cmTextTertiary)
                }
            }
            .frame(width: 180, height: 180)

            Text(subtitleText)
                .font(.cmCallout)
                .foregroundStyle(Color.cmTextSecondary)
                .frame(height: 20)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Калории: съедено \(consumed) из \(goal). Осталось \(remaining)")
    }
}

#Preview {
    VStack(spacing: 32) {
        CalorieRingView(consumed: 1245, goal: 2100)
        CalorieRingView(consumed: 1950, goal: 2100)
        CalorieRingView(consumed: 2350, goal: 2100)
    }
}
