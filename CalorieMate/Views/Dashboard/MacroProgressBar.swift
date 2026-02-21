import SwiftUI

struct MacroProgressBar: View {
    let label: String
    let current: Double
    let goal: Int
    let color: Color

    private var progress: Double {
        guard goal > 0 else { return 0 }
        return min(current / Double(goal), 1.0)
    }

    var body: some View {
        VStack(spacing: 4) {
            HStack {
                Text(label)
                    .font(.cmCallout)
                    .foregroundStyle(Color.cmTextSecondary)

                Spacer()

                HStack(spacing: 2) {
                    Text(current.formattedMacroValue)
                        .font(.cmCallout)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.cmTextPrimary)

                    Text("/ \(goal)\u{00A0}г")
                        .font(.cmCallout)
                        .foregroundStyle(Color.cmTextSecondary)
                }
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.cmBgTertiary)
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(color)
                        .frame(width: geo.size.width * progress, height: 8)
                        .animation(.spring(response: 0.5, dampingFraction: 0.85), value: progress)
                }
            }
            .frame(height: 8)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(label): \(Int(current.rounded())) из \(goal) грамм")
    }
}

/// Группа из 3 макро-прогрессбаров (Б/Ж/У)
struct MacroProgressGroup: View {
    let protein: Double
    let fat: Double
    let carbs: Double
    let proteinGoal: Int
    let fatGoal: Int
    let carbsGoal: Int

    var body: some View {
        VStack(spacing: 12) {
            MacroProgressBar(label: "Белки", current: protein, goal: proteinGoal, color: .cmProtein)
            MacroProgressBar(label: "Жиры", current: fat, goal: fatGoal, color: .cmFat)
            MacroProgressBar(label: "Углеводы", current: carbs, goal: carbsGoal, color: .cmCarbs)
        }
    }
}

#Preview {
    MacroProgressGroup(
        protein: 87, fat: 32, carbs: 187,
        proteinGoal: 158, fatGoal: 58, carbsGoal: 236
    )
    .padding()
}
