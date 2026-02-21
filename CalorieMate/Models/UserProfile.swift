import Foundation
import SwiftData

@Model
final class UserProfile {
    var goal: Goal
    var gender: Gender
    var age: Int
    var height: Int
    var activityLevel: ActivityLevel
    var dailyCalorieGoal: Int
    var proteinRatio: Double
    var fatRatio: Double
    var carbsRatio: Double
    var targetWeight: Double?
    var healthKitEnabled: Bool

    init(
        goal: Goal,
        gender: Gender,
        age: Int,
        height: Int,
        activityLevel: ActivityLevel,
        dailyCalorieGoal: Int,
        proteinRatio: Double,
        fatRatio: Double,
        carbsRatio: Double,
        targetWeight: Double? = nil,
        healthKitEnabled: Bool = false
    ) {
        self.goal = goal
        self.gender = gender
        self.age = age
        self.height = height
        self.activityLevel = activityLevel
        self.dailyCalorieGoal = dailyCalorieGoal
        self.proteinRatio = proteinRatio
        self.fatRatio = fatRatio
        self.carbsRatio = carbsRatio
        self.targetWeight = targetWeight
        self.healthKitEnabled = healthKitEnabled
    }
}
