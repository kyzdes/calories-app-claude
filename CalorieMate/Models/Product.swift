import Foundation
import SwiftData

@Model
final class Product {
    var id: UUID
    var name: String
    var barcode: String?
    var caloriesPer100g: Double
    var proteinPer100g: Double
    var fatPer100g: Double
    var carbsPer100g: Double
    var source: ProductSource
    var brand: String?
    var usageCount: Int
    var lastUsed: Date?

    init(
        id: UUID = UUID(),
        name: String,
        barcode: String? = nil,
        caloriesPer100g: Double,
        proteinPer100g: Double,
        fatPer100g: Double,
        carbsPer100g: Double,
        source: ProductSource,
        brand: String? = nil,
        usageCount: Int = 0,
        lastUsed: Date? = nil
    ) {
        self.id = id
        self.name = name
        self.barcode = barcode
        self.caloriesPer100g = caloriesPer100g
        self.proteinPer100g = proteinPer100g
        self.fatPer100g = fatPer100g
        self.carbsPer100g = carbsPer100g
        self.source = source
        self.brand = brand
        self.usageCount = usageCount
        self.lastUsed = lastUsed
    }
}
