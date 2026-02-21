import Foundation
import SwiftData
import Observation

@Observable
final class ProgressViewModel {
    var caloriesPeriod: TimePeriod = .week
    var macrosPeriod: TimePeriod = .week
    var weightPeriod: TimePeriod = .month

    enum TimePeriod: String, CaseIterable {
        case week = "Нед"
        case month = "Мес"
        case threeMonths = "3 мес"
        case all = "Всё"

        var days: Int? {
            switch self {
            case .week: 7
            case .month: 30
            case .threeMonths: 90
            case .all: nil
            }
        }
    }

    // MARK: - Daily Aggregation

    struct DailyCalories: Identifiable {
        let id = UUID()
        let date: Date
        let calories: Int
        let exceeded: Bool
    }

    struct DailyMacros: Identifiable {
        let id = UUID()
        let date: Date
        let protein: Double
        let fat: Double
        let carbs: Double
    }

    func dailyCalories(from entries: [FoodEntry], period: TimePeriod, goal: Int) -> [DailyCalories] {
        let filtered = filterByPeriod(entries, period: period)
        let grouped = Dictionary(grouping: filtered) { Calendar.current.startOfDay(for: $0.date) }

        return grouped.map { date, entries in
            let total = entries.reduce(0) { $0 + $1.calories }
            return DailyCalories(date: date, calories: total, exceeded: total > goal)
        }.sorted { $0.date < $1.date }
    }

    func dailyMacros(from entries: [FoodEntry], period: TimePeriod) -> [DailyMacros] {
        let filtered = filterByPeriod(entries, period: period)
        let grouped = Dictionary(grouping: filtered) { Calendar.current.startOfDay(for: $0.date) }

        return grouped.map { date, entries in
            DailyMacros(
                date: date,
                protein: entries.reduce(0) { $0 + $1.protein },
                fat: entries.reduce(0) { $0 + $1.fat },
                carbs: entries.reduce(0) { $0 + $1.carbs }
            )
        }.sorted { $0.date < $1.date }
    }

    // MARK: - Summary

    func averageCalories(from entries: [FoodEntry], period: TimePeriod) -> Int {
        let daily = dailyCalories(from: entries, period: period, goal: 0)
        guard !daily.isEmpty else { return 0 }
        return daily.reduce(0) { $0 + $1.calories } / daily.count
    }

    func averageMacros(from entries: [FoodEntry], period: TimePeriod) -> (protein: Int, fat: Int, carbs: Int) {
        let daily = dailyMacros(from: entries, period: period)
        guard !daily.isEmpty else { return (0, 0, 0) }
        let count = Double(daily.count)
        return (
            protein: Int((daily.reduce(0) { $0 + $1.protein } / count).rounded()),
            fat: Int((daily.reduce(0) { $0 + $1.fat } / count).rounded()),
            carbs: Int((daily.reduce(0) { $0 + $1.carbs } / count).rounded())
        )
    }

    /// Дни в диапазоне ±10% от цели / всего дней
    func complianceRate(from entries: [FoodEntry], period: TimePeriod, goal: Int) -> Int {
        let daily = dailyCalories(from: entries, period: period, goal: goal)
        guard !daily.isEmpty else { return 0 }
        let lower = Double(goal) * 0.9
        let upper = Double(goal) * 1.1
        let inRange = daily.filter { Double($0.calories) >= lower && Double($0.calories) <= upper }.count
        return Int((Double(inRange) / Double(daily.count) * 100).rounded())
    }

    // MARK: - Filter

    private func filterByPeriod(_ entries: [FoodEntry], period: TimePeriod) -> [FoodEntry] {
        guard let days = period.days else { return entries }
        let cutoff = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        return entries.filter { $0.date >= cutoff }
    }

    func filterWeightByPeriod(_ entries: [WeightEntry], period: TimePeriod) -> [WeightEntry] {
        guard let days = period.days else { return entries }
        let cutoff = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        return entries.filter { $0.date >= cutoff }
    }
}
