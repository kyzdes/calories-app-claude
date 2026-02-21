import Foundation

extension Double {

    /// Форматирование калорий: без десятичных, тонкий пробел как разделитель тысяч
    /// «1 842\u{00A0}ккал»
    var formattedCalories: String {
        let formatted = Self.calorieFormatter.string(from: NSNumber(value: Int(self.rounded()))) ?? "\(Int(self.rounded()))"
        return "\(formatted)\u{00A0}ккал"
    }

    /// Форматирование БЖУ: округление до целого
    /// «124\u{00A0}г»
    var formattedMacro: String {
        "\(Int(self.rounded()))\u{00A0}г"
    }

    /// Форматирование веса: до десятых
    /// «78.3\u{00A0}кг»
    var formattedWeight: String {
        let formatted = Self.weightFormatter.string(from: NSNumber(value: self)) ?? String(format: "%.1f", self)
        return "\(formatted)\u{00A0}кг"
    }

    /// Только число калорий без единицы (для отображения в кольце)
    var formattedCaloriesValue: String {
        Self.calorieFormatter.string(from: NSNumber(value: Int(self.rounded()))) ?? "\(Int(self.rounded()))"
    }

    /// Только число граммов без единицы
    var formattedMacroValue: String {
        "\(Int(self.rounded()))"
    }

    /// Только число веса без единицы
    var formattedWeightValue: String {
        Self.weightFormatter.string(from: NSNumber(value: self)) ?? String(format: "%.1f", self)
    }

    // MARK: - Formatters

    private static let calorieFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        formatter.groupingSeparator = "\u{2009}" // Тонкий пробел
        formatter.groupingSize = 3
        formatter.usesGroupingSeparator = true
        return formatter
    }()

    private static let weightFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 1
        formatter.decimalSeparator = "."
        return formatter
    }()
}

extension Int {

    /// Форматирование калорий из Int
    var formattedCalories: String {
        Double(self).formattedCalories
    }

    /// Только число калорий без единицы
    var formattedCaloriesValue: String {
        Double(self).formattedCaloriesValue
    }
}
