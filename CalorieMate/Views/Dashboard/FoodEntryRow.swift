import SwiftUI

struct FoodEntryRow: View {
    let entry: FoodEntry
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                Text(entry.productName)
                    .font(.cmBody)
                    .foregroundStyle(Color.cmTextPrimary)
                    .lineLimit(1)

                Spacer()

                Text("\(Int(entry.portionGrams))\u{00A0}г")
                    .font(.cmNumberSm)
                    .foregroundStyle(Color.cmTextSecondary)

                Text("\(entry.calories)")
                    .font(.cmNumberSm)
                    .foregroundStyle(Color.cmTextPrimary)
                    .frame(width: 44, alignment: .trailing)
            }
            .padding(.vertical, 10)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(entry.productName), \(Int(entry.portionGrams)) грамм, \(entry.calories) килокалорий")
        .accessibilityHint("Нажмите для редактирования. Смахните влево для удаления")
    }
}
