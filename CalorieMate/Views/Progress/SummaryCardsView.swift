import SwiftUI

struct SummaryCardsView: View {
    let averageCalories: Int
    let averageProtein: Int
    let averageFat: Int
    let averageCarbs: Int
    let complianceRate: Int

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 4) {
                Text("\u{00D8} \(averageCalories.formattedCaloriesValue)")
                    .font(.cmNumberMd)
                    .foregroundStyle(Color.cmTextPrimary)
                Text("ккал/день")
                    .font(.cmCallout)
                    .foregroundStyle(Color.cmTextSecondary)
            }

            HStack(spacing: 12) {
                HStack(spacing: 4) {
                    Text("\u{00D8} Б")
                        .font(.cmCaption)
                        .foregroundStyle(Color.cmProtein)
                    Text("\(averageProtein)\u{00A0}г")
                        .font(.cmCaption)
                        .foregroundStyle(Color.cmTextPrimary)
                }
                Text("\u{00B7}")
                    .foregroundStyle(Color.cmTextTertiary)
                HStack(spacing: 4) {
                    Text("Ж")
                        .font(.cmCaption)
                        .foregroundStyle(Color.cmFat)
                    Text("\(averageFat)\u{00A0}г")
                        .font(.cmCaption)
                        .foregroundStyle(Color.cmTextPrimary)
                }
                Text("\u{00B7}")
                    .foregroundStyle(Color.cmTextTertiary)
                HStack(spacing: 4) {
                    Text("У")
                        .font(.cmCaption)
                        .foregroundStyle(Color.cmCarbs)
                    Text("\(averageCarbs)\u{00A0}г")
                        .font(.cmCaption)
                        .foregroundStyle(Color.cmTextPrimary)
                }
            }

            Text("Соблюдение нормы: \(complianceRate)%")
                .font(.cmCaption)
                .foregroundStyle(Color.cmTextSecondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(Color.cmBgSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}
