import SwiftUI
import Charts

struct WeightChartView: View {
    let entries: [WeightEntry]
    let goalWeight: Double?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("График веса")
                .font(.cmH3)
                .foregroundStyle(Color.cmTextPrimary)

            if entries.isEmpty {
                Text("Нет данных")
                    .font(.cmBody)
                    .foregroundStyle(Color.cmTextTertiary)
                    .frame(height: 200)
                    .frame(maxWidth: .infinity)
            } else {
                Chart {
                    ForEach(entries.sorted(by: { $0.date < $1.date }), id: \.id) { entry in
                        LineMark(
                            x: .value("Дата", entry.date),
                            y: .value("Вес", entry.weight)
                        )
                        .foregroundStyle(Color.cmPrimary)
                        .interpolationMethod(.catmullRom)

                        PointMark(
                            x: .value("Дата", entry.date),
                            y: .value("Вес", entry.weight)
                        )
                        .foregroundStyle(Color.cmPrimary)
                        .symbolSize(30)
                    }

                    if let goal = goalWeight {
                        RuleMark(y: .value("Цель", goal))
                            .foregroundStyle(Color.cmTextTertiary)
                            .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                            .annotation(position: .trailing) {
                                Text(goal.formattedWeightValue)
                                    .font(.cmCaption)
                                    .foregroundStyle(Color.cmTextTertiary)
                            }
                    }
                }
                .frame(height: 200)
                .chartYScale(domain: yDomain)
            }
        }
        .padding(16)
        .background(Color.cmBgSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private var yDomain: ClosedRange<Double> {
        let weights = entries.map(\.weight)
        let minW = (weights.min() ?? 50) - 2
        let maxW = (weights.max() ?? 100) + 2
        if let goal = goalWeight {
            return min(minW, goal - 2)...max(maxW, goal + 2)
        }
        return minW...maxW
    }
}
