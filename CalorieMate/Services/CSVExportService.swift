import Foundation

struct CSVExportService {

    /// Экспортирует данные в CSV файл и возвращает URL
    static func export(
        foodEntries: [FoodEntry],
        weightEntries: [WeightEntry],
        profile: UserProfile?
    ) -> URL? {
        var csv = ""

        // BOM для корректного открытия в Excel
        csv += "\u{FEFF}"

        // Профиль
        csv += "=== ПРОФИЛЬ ===\n"
        if let p = profile {
            csv += "Цель;\(p.goal.displayName)\n"
            csv += "Пол;\(p.gender.displayName)\n"
            csv += "Возраст;\(p.age)\n"
            csv += "Рост (см);\(p.height)\n"
            csv += "Активность;\(p.activityLevel.displayName)\n"
            csv += "Дневная норма (ккал);\(p.dailyCalorieGoal)\n"
            csv += "Белки (%);\(Int(p.proteinRatio * 100))\n"
            csv += "Жиры (%);\(Int(p.fatRatio * 100))\n"
            csv += "Углеводы (%);\(Int(p.carbsRatio * 100))\n"
            if let tw = p.targetWeight {
                csv += "Целевой вес (кг);\(String(format: "%.1f", tw))\n"
            }
        }

        csv += "\n"

        // Дневник питания
        csv += "=== ДНЕВНИК ПИТАНИЯ ===\n"
        csv += "Дата;Приём пищи;Продукт;Порция (г);Калории;Белки (г);Жиры (г);Углеводы (г)\n"

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale(identifier: "ru_RU")

        let sortedFood = foodEntries.sorted { $0.date < $1.date }
        for entry in sortedFood {
            let date = dateFormatter.string(from: entry.date)
            let meal = entry.mealType.displayName
            let name = entry.productName.replacingOccurrences(of: ";", with: ",")
            let portion = String(format: "%.0f", entry.portionGrams)
            let cal = "\(entry.calories)"
            let protein = String(format: "%.1f", entry.protein)
            let fat = String(format: "%.1f", entry.fat)
            let carbs = String(format: "%.1f", entry.carbs)
            csv += "\(date);\(meal);\(name);\(portion);\(cal);\(protein);\(fat);\(carbs)\n"
        }

        csv += "\n"

        // Вес
        csv += "=== ВЕС ===\n"
        csv += "Дата;Вес (кг)\n"

        let sortedWeight = weightEntries.sorted { $0.date < $1.date }
        for entry in sortedWeight {
            let date = dateFormatter.string(from: entry.date)
            let weight = String(format: "%.1f", entry.weight)
            csv += "\(date);\(weight)\n"
        }

        // Сохранение файла
        let fileName = "CalorieMate_export_\(dateFormatter.string(from: Date())).csv"
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

        do {
            try csv.write(to: tempURL, atomically: true, encoding: .utf8)
            return tempURL
        } catch {
            return nil
        }
    }
}
