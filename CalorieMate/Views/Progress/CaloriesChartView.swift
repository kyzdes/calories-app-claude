import SwiftUI
import Charts

struct CaloriesChartView: View {
    let data: [ProgressViewModel.DailyCalories]
    let goal: Int
    @Binding var period: ProgressViewModel.TimePeriod

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Калории")
                    .font(.cmH3)
                    .foregroundStyle(Color.cmTextPrimary)

                Spacer()

                if !data.isEmpty {
                    let avg = data.reduce(0) { $0 + $1.calories } / max(data.count, 1)
                    Text("\u{00D8} \(avg.formattedCaloriesValue)")
                        .font(.cmNumberMd)
                        .foregroundStyle(Color.cmTextPrimary)
                }
            }

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
                            y: .value("Калории", item.calories)
                        )
                        .foregroundStyle(item.exceeded ? Color.cmDanger : Color.cmPrimary)
                        .cornerRadius(4)
                    }

                    RuleMark(y: .value("Цель", goal))
                        .foregroundStyle(Color.cmTextTertiary)
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                }
                .frame(height: 200)
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day)) { value in
                        if let date = value.as(Date.self) {
                            let formatter = DateFormatter()
                            let _ = formatter.dateFormat = "EE"
                            let _ = formatter.locale = Locale(identifier: "ru_RU")
                            AxisValueLabel {
                                Text(formatter.string(from: date))
                                    .font(.cmCaption2)
                            }
                        }
                    }
                }
            }

            PeriodPicker(selected: $period)
        }
        .padding(16)
        .background(Color.cmBgSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}
