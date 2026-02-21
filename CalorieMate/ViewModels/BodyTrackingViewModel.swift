import Foundation
import SwiftData
import Observation

@Observable
final class BodyTrackingViewModel {
    var showWeightSheet = false
    var showMeasurementsSheet = false
    var weightText: String = ""
    var selectedPeriod: TimePeriod = .month

    // Measurements
    var waistText: String = ""
    var hipsText: String = ""
    var chestText: String = ""
    var bicepsText: String = ""

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

    // MARK: - Weight

    func latestWeight(from entries: [WeightEntry]) -> WeightEntry? {
        entries.sorted { $0.date > $1.date }.first
    }

    func weightDelta(from entries: [WeightEntry]) -> (value: Double, days: Int)? {
        let sorted = entries.sorted { $0.date < $1.date }
        guard let first = sorted.first, let last = sorted.last, first.id != last.id else { return nil }
        let days = Calendar.current.dateComponents([.day], from: first.date, to: last.date).day ?? 0
        return (value: last.weight - first.weight, days: max(days, 1))
    }

    func filteredWeightEntries(_ entries: [WeightEntry]) -> [WeightEntry] {
        guard let days = selectedPeriod.days else { return entries }
        let cutoff = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        return entries.filter { $0.date >= cutoff }
    }

    func prefillWeight(from entries: [WeightEntry]) {
        if let latest = latestWeight(from: entries) {
            weightText = String(format: "%.1f", latest.weight)
        }
    }

    func saveWeight(context: ModelContext) {
        let cleaned = weightText.replacingOccurrences(of: ",", with: ".")
        guard let value = Double(cleaned), value >= 30.0, value <= 300.0 else { return }

        let entry = WeightEntry(weight: value)
        context.insert(entry)
        showWeightSheet = false
    }

    // MARK: - Measurements

    func latestMeasurement(from measurements: [BodyMeasurement]) -> BodyMeasurement? {
        measurements.sorted { $0.date > $1.date }.first
    }

    func prefillMeasurements(from measurements: [BodyMeasurement]) {
        if let latest = latestMeasurement(from: measurements) {
            waistText = latest.waist.map { String(format: "%.0f", $0) } ?? ""
            hipsText = latest.hips.map { String(format: "%.0f", $0) } ?? ""
            chestText = latest.chest.map { String(format: "%.0f", $0) } ?? ""
            bicepsText = latest.biceps.map { String(format: "%.0f", $0) } ?? ""
        }
    }

    func saveMeasurements(context: ModelContext) {
        let measurement = BodyMeasurement(
            waist: Double(waistText),
            hips: Double(hipsText),
            chest: Double(chestText),
            biceps: Double(bicepsText)
        )
        context.insert(measurement)
        showMeasurementsSheet = false
    }
}
