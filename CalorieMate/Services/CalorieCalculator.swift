import Foundation

struct CalorieCalculator {

    // MARK: - BMR (Mifflin-St Jeor)

    /// Базовый метаболизм (Mifflin-St Jeor)
    /// - Мужчины: 10 x вес(кг) + 6.25 x рост(см) - 5 x возраст - 5
    /// - Женщины: 10 x вес(кг) + 6.25 x рост(см) - 5 x возраст - 161
    static func calculateBMR(gender: Gender, weight: Double, height: Double, age: Int) -> Double {
        let base = 10.0 * weight + 6.25 * height - 5.0 * Double(age)
        switch gender {
        case .male: return base - 5.0
        case .female: return base - 161.0
        }
    }

    // MARK: - TDEE

    /// Общий расход энергии = BMR x коэффициент активности
    static func calculateTDEE(bmr: Double, activityLevel: ActivityLevel) -> Double {
        bmr * activityLevel.multiplier
    }

    // MARK: - Target Calories

    /// Целевые калории:
    /// - Похудение: TDEE x 0.80
    /// - Набор: TDEE x 1.15
    /// - Поддержание: TDEE x 1.00
    static func calculateTargetCalories(tdee: Double, goal: Goal) -> Int {
        let multiplier: Double = switch goal {
        case .lose: 0.80
        case .gain: 1.15
        case .maintain: 1.00
        }
        return Int((tdee * multiplier).rounded())
    }

    // MARK: - Macro Ratios

    /// БЖУ по умолчанию (% от калорий):
    /// - Похудение: Б 30% / Ж 25% / У 45%
    /// - Набор: Б 30% / Ж 30% / У 40%
    /// - Поддержание: Б 25% / Ж 30% / У 45%
    static func defaultMacroRatios(for goal: Goal) -> (protein: Double, fat: Double, carbs: Double) {
        switch goal {
        case .lose: (protein: 0.30, fat: 0.25, carbs: 0.45)
        case .gain: (protein: 0.30, fat: 0.30, carbs: 0.40)
        case .maintain: (protein: 0.25, fat: 0.30, carbs: 0.45)
        }
    }

    // MARK: - Macros in Grams

    /// Перевод % в граммы:
    /// - Белки(г) = калории x protein% / 4
    /// - Жиры(г) = калории x fat% / 9
    /// - Углеводы(г) = калории x carbs% / 4
    static func macrosInGrams(
        calories: Int,
        proteinRatio: Double,
        fatRatio: Double,
        carbsRatio: Double
    ) -> (protein: Int, fat: Int, carbs: Int) {
        let cal = Double(calories)
        return (
            protein: Int((cal * proteinRatio / 4.0).rounded()),
            fat: Int((cal * fatRatio / 9.0).rounded()),
            carbs: Int((cal * carbsRatio / 4.0).rounded())
        )
    }

    // MARK: - Full Calculation

    /// Полный расчёт: от параметров тела до целевых калорий и БЖУ
    static func calculate(
        gender: Gender,
        weight: Double,
        height: Double,
        age: Int,
        activityLevel: ActivityLevel,
        goal: Goal
    ) -> CalculationResult {
        let bmr = calculateBMR(gender: gender, weight: weight, height: height, age: age)
        let tdee = calculateTDEE(bmr: bmr, activityLevel: activityLevel)
        let targetCalories = calculateTargetCalories(tdee: tdee, goal: goal)
        let ratios = defaultMacroRatios(for: goal)
        let macros = macrosInGrams(
            calories: targetCalories,
            proteinRatio: ratios.protein,
            fatRatio: ratios.fat,
            carbsRatio: ratios.carbs
        )

        return CalculationResult(
            bmr: bmr,
            tdee: tdee,
            targetCalories: targetCalories,
            proteinRatio: ratios.protein,
            fatRatio: ratios.fat,
            carbsRatio: ratios.carbs,
            proteinGrams: macros.protein,
            fatGrams: macros.fat,
            carbsGrams: macros.carbs
        )
    }
}

// MARK: - Result

struct CalculationResult {
    let bmr: Double
    let tdee: Double
    let targetCalories: Int
    let proteinRatio: Double
    let fatRatio: Double
    let carbsRatio: Double
    let proteinGrams: Int
    let fatGrams: Int
    let carbsGrams: Int
}
