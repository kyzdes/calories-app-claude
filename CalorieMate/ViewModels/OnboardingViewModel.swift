import Foundation
import SwiftData
import Observation

@Observable
final class OnboardingViewModel {

    // MARK: - Navigation

    enum Step: Int, CaseIterable {
        case welcome = 0
        case goal = 1
        case gender = 2
        case bodyParams = 3
        case activity = 4
        case result = 5

        var stepNumber: Int? {
            switch self {
            case .welcome: nil
            case .goal: 1
            case .gender: 2
            case .bodyParams: 3
            case .activity: 4
            case .result: 5
            }
        }
    }

    var currentStep: Step = .welcome

    // MARK: - User Input

    var selectedGoal: Goal?
    var selectedGender: Gender?
    var ageText: String = ""
    var heightText: String = ""
    var weightText: String = ""
    var selectedActivityLevel: ActivityLevel = .light
    var targetWeightText: String = ""

    // MARK: - Calculation Result

    var calculationResult: CalculationResult?

    // MARK: - Validation

    var age: Int? {
        guard let value = Int(ageText), value >= 14, value <= 100 else { return nil }
        return value
    }

    var height: Int? {
        guard let value = Int(heightText), value >= 100, value <= 250 else { return nil }
        return value
    }

    var weight: Double? {
        let cleaned = weightText.replacingOccurrences(of: ",", with: ".")
        guard let value = Double(cleaned), value >= 30.0, value <= 300.0 else { return nil }
        return value
    }

    var targetWeight: Double? {
        guard !targetWeightText.isEmpty else { return nil }
        let cleaned = targetWeightText.replacingOccurrences(of: ",", with: ".")
        guard let value = Double(cleaned), value >= 30.0, value <= 300.0 else { return nil }
        return value
    }

    var isAgeValid: Bool { age != nil || ageText.isEmpty }
    var isHeightValid: Bool { height != nil || heightText.isEmpty }
    var isWeightValid: Bool { weight != nil || weightText.isEmpty }

    var canProceedFromGoal: Bool { selectedGoal != nil }
    var canProceedFromGender: Bool { selectedGender != nil }
    var canProceedFromBodyParams: Bool { age != nil && height != nil && weight != nil }
    var canProceedFromActivity: Bool { true } // Всегда есть предвыбор

    // MARK: - Navigation Actions

    func goNext() {
        guard let nextIndex = Step(rawValue: currentStep.rawValue + 1) else { return }

        if nextIndex == .result {
            performCalculation()
        }

        currentStep = nextIndex
    }

    func goBack() {
        guard let prevIndex = Step(rawValue: currentStep.rawValue - 1) else { return }
        currentStep = prevIndex
    }

    // MARK: - Calculation

    private func performCalculation() {
        guard let goal = selectedGoal,
              let gender = selectedGender,
              let weight = weight,
              let height = height,
              let age = age else { return }

        calculationResult = CalorieCalculator.calculate(
            gender: gender,
            weight: weight,
            height: Double(height),
            age: age,
            activityLevel: selectedActivityLevel,
            goal: goal
        )
    }

    // MARK: - Save Profile

    func saveProfile(context: ModelContext) {
        guard let goal = selectedGoal,
              let gender = selectedGender,
              let result = calculationResult else { return }

        let profile = UserProfile(
            goal: goal,
            gender: gender,
            age: age ?? 25,
            height: height ?? 170,
            activityLevel: selectedActivityLevel,
            dailyCalorieGoal: result.targetCalories,
            proteinRatio: result.proteinRatio,
            fatRatio: result.fatRatio,
            carbsRatio: result.carbsRatio,
            targetWeight: targetWeight
        )

        context.insert(profile)

        // Сохраняем начальный вес
        if let weight = weight {
            let weightEntry = WeightEntry(weight: weight)
            context.insert(weightEntry)
        }
    }
}
