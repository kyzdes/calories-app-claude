import SwiftUI
import Charts

struct MacrosChartView: View {
    let data: [ProgressViewModel.DailyMacros]
    @Binding var period: ProgressViewModel.TimePeriod

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("БЖУ")
                .font(.cmH3)
                .foregroundStyle(Color.cmTextPrimary)

            if data.isEmpty {
                Text("Нет данных за выбранный период")
                    .font(.cmBody)
                    .foregroundStyle(Color.cmTextTertiary)
                    .frame(height: 200)
                    .frame(maxWidth: .infinity)
            } else {
                Chart {
                    ForEach(data) { item in
                        BarMark(
                            x: .value("Дата", item.date, unit: .day),
                            y: .value("Граммы", item.protein)
                        )
                        .foregroundStyle(Color.cmProtein)

                        BarMark(
                            x: .value("Дата", item.date, unit: .day),
                            y: .value("Граммы", item.fat)
                        )
                        .foregroundStyle(Color.cmFat)

                        BarMark(
                            x: .value("Дата", item.date, unit: .day),
                            y: .value("Граммы", item.carbs)
                        )
                        .foregroundStyle(Color.cmCarbs)
                    }
                }
                .chartForegroundStyleScale([
                    "Белки": Color.cmProtein,
                    "Жиры": Color.cmFat,
                    "Углеводы": Color.cmCarbs
                ])
                .frame(height: 200)
            }

            // Legend
            HStack(spacing: 16) {
                legendItem("Белки", color: .cmProtein)
                legendItem("Жиры", color: .cmFat)
                legendItem("Углеводы", color: .cmCarbs)
            }

            PeriodPicker(selected: $period)
        }
        .padding(16)
        .background(Color.cmBgSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    @ViewBuilder
    private func legendItem(_ label: String, color: Color) -> some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(label)
                .font(.cmCaption)
                .foregroundStyle(Color.cmTextSecondary)
        }
    }
}
