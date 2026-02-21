import Foundation
import SwiftData

@Model
final class FoodEntry {
    var id: UUID
    var productId: UUID
    var productName: String
    var date: Date
    var mealType: MealType
    var portionGrams: Double
    var calories: Int
    var protein: Double
    var fat: Double
    var carbs: Double
    var createdAt: Date

    init(
        id: UUID = UUID(),
        productId: UUID,
        productName: String,
        date: Date = Date(),
        mealType: MealType,
        portionGrams: Double,
        calories: Int,
        protein: Double,
        fat: Double,
        carbs: Double,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.productId = productId
        self.productName = productName
        self.date = date
        self.mealType = mealType
        self.portionGrams = portionGrams
        self.calories = calories
        self.protein = protein
        self.fat = fat
        self.carbs = carbs
        self.createdAt = createdAt
    }
}
