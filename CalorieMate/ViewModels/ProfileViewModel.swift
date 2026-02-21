import Foundation
import SwiftData
import Observation

@Observable
final class ProfileViewModel {

    // MARK: - Edit State

    var editGoal: Goal = .maintain
    var editGender: Gender = .male
    var editAge: String = ""
    var editHeight: String = ""
    var editActivityLevel: ActivityLevel = .light
    var editTargetWeight: String = ""

    // MARK: - Macro Edit

    var editProteinPercent: Double = 25
    var editFatPercent: Double = 30
    var editCarbsPercent: Double = 45

    var macroSumPercent: Int {
        Int(editProteinPercent + editFatPercent + editCarbsPercent)
    }

    var isMacroSumValid: Bool {
        macroSumPercent == 100
    }

    // MARK: - Calorie Edit

    var editCalorieGoal: String = ""

    // MARK: - CSV Export

    var csvFileURL: URL?
    var showShareSheet = false
    var showResetConfirmation = false

    // MARK: - Prefill from Profile

    func prefill(from profile: UserProfile) {
        editGoal = profile.goal
        editGender = profile.gender
        editAge = "\(profile.age)"
        editHeight = "\(profile.height)"
        editActivityLevel = profile.activityLevel
        editTargetWeight = profile.targetWeight.map { String(format: "%.1f", $0) } ?? ""
        editProteinPercent = (profile.proteinRatio * 100).rounded()
        editFatPercent = (profile.fatRatio * 100).rounded()
        editCarbsPercent = (profile.carbsRatio * 100).rounded()
        editCalorieGoal = "\(profile.dailyCalorieGoal)"
    }

    // MARK: - Save Goal

    func saveGoal(_ profile: UserProfile, weightEntries: [WeightEntry]) {
        profile.goal = editGoal
        recalculate(profile, weightEntries: weightEntries)
    }

    // MARK: - Save Gender

    func saveGender(_ profile: UserProfile, weightEntries: [WeightEntry]) {
        profile.gender = editGender
        recalculate(profile, weightEntries: weightEntries)
    }

    // MARK: - Save Age

    func saveAge(_ profile: UserProfile, weightEntries: [WeightEntry]) {
        guard let age = Int(editAge), age >= 14, age <= 100 else { return }
        profile.age = age
        recalculate(profile, weightEntries: weightEntries)
    }

    // MARK: - Save Height

    func saveHeight(_ profile: UserProfile, weightEntries: [WeightEntry]) {
        guard let height = Int(editHeight), height >= 100, height <= 250 else { return }
        profile.height = height
        recalculate(profile, weightEntries: weightEntries)
    }

    // MARK: - Save Activity

    func saveActivity(_ profile: UserProfile, weightEntries: [WeightEntry]) {
        profile.activityLevel = editActivityLevel
        recalculate(profile, weightEntries: weightEntries)
    }

    // MARK: - Save Macros

    func saveMacros(_ profile: UserProfile) {
        guard isMacroSumValid else { return }
        profile.proteinRatio = editProteinPercent / 100.0
        profile.fatRatio = editFatPercent / 100.0
        profile.carbsRatio = editCarbsPercent / 100.0
    }

    // MARK: - Save Calorie Goal

    func saveCalorieGoal(_ profile: UserProfile) {
        guard let goal = Int(editCalorieGoal), goal > 0 else { return }
        profile.dailyCalorieGoal = goal
    }

    // MARK: - Apply Default Macros

    func applyDefaultMacros(for goal: Goal) {
        let defaults = CalorieCalculator.defaultMacroRatios(for: goal)
        editProteinPercent = (defaults.protein * 100).rounded()
        editFatPercent = (defaults.fat * 100).rounded()
        editCarbsPercent = (defaults.carbs * 100).rounded()
    }

    // MARK: - Recalculate

    private func recalculate(_ profile: UserProfile, weightEntries: [WeightEntry]) {
        let currentWeight = weightEntries
            .sorted { $0.date > $1.date }
            .first?.weight ?? 70.0

        let result = CalorieCalculator.calculate(
            gender: profile.gender,
            weight: currentWeight,
            height: Double(profile.height),
            age: profile.age,
            activityLevel: profile.activityLevel,
            goal: profile.goal
        )

        profile.dailyCalorieGoal = result.targetCalories
        profile.proteinRatio = result.proteinRatio
        profile.fatRatio = result.fatRatio
        profile.carbsRatio = result.carbsRatio

        // Update edit state
        editCalorieGoal = "\(result.targetCalories)"
        editProteinPercent = (result.proteinRatio * 100).rounded()
        editFatPercent = (result.fatRatio * 100).rounded()
        editCarbsPercent = (result.carbsRatio * 100).rounded()
    }

    // MARK: - CSV Export

    func exportCSV(foodEntries: [FoodEntry], weightEntries: [WeightEntry], profile: UserProfile?) -> URL? {
        return CSVExportService.export(
            foodEntries: foodEntries,
            weightEntries: weightEntries,
            profile: profile
        )
    }

    // MARK: - Reset All Data

    func resetAllData(context: ModelContext) {
        do {
            try context.delete(model: FoodEntry.self)
            try context.delete(model: WeightEntry.self)
            try context.delete(model: BodyMeasurement.self)
            try context.delete(model: Product.self)
            try context.delete(model: UserProfile.self)
            try context.save()
        } catch {
            // Silently handle — data will remain
        }
    }
}
