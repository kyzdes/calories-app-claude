import SwiftUI

struct FoodSearchResultRow: View {
    let product: Product
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 4) {
                Text(product.name)
                    .font(.cmBody)
                    .foregroundStyle(Color.cmTextPrimary)
                    .lineLimit(2)

                HStack(spacing: 8) {
                    Text("\(Int(product.caloriesPer100g))\u{00A0}ккал")
                        .font(.cmBodyBold)
                        .foregroundStyle(Color.cmTextPrimary)

                    Text("\u{00B7}")
                        .foregroundStyle(Color.cmTextTertiary)

                    HStack(spacing: 6) {
                        macroText("Б", value: product.proteinPer100g, color: .cmProtein)
                        macroText("Ж", value: product.fatPer100g, color: .cmFat)
                        macroText("У", value: product.carbsPer100g, color: .cmCarbs)
                    }

                    Spacer()

                    Text("на 100\u{00A0}г")
                        .font(.cmCaption)
                        .foregroundStyle(Color.cmTextTertiary)
                }

                if product.source == .ugc {
                    Text("Пользователь")
                        .font(.cmCaption2)
                        .foregroundStyle(Color.cmTextTertiary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.cmBgTertiary)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func macroText(_ prefix: String, value: Double, color: Color) -> some View {
        HStack(spacing: 2) {
            Text(prefix)
                .font(.cmCaption)
                .foregroundStyle(color)
            Text("\(Int(value.rounded()))")
                .font(.cmCaption)
                .foregroundStyle(color)
        }
    }
}
