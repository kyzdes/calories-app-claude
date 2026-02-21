import Foundation

extension Date {

    // MARK: - Display

    /// Возвращает строку для отображения даты:
    /// - «Сегодня» если текущий день
    /// - «Вчера» если вчера
    /// - «Пн, 17 февраля» для других дат текущего года
    /// - «Пн, 17 февраля 2025» для дат другого года
    var displayString: String {
        let calendar = Calendar.current

        if calendar.isDateInToday(self) {
            return "Сегодня"
        }
        if calendar.isDateInYesterday(self) {
            return "Вчера"
        }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")

        if calendar.component(.year, from: self) == calendar.component(.year, from: Date()) {
            formatter.dateFormat = "EE, d MMMM"
        } else {
            formatter.dateFormat = "EE, d MMMM yyyy"
        }

        return formatter.string(from: self).capitalizedFirstLetter
    }

    /// Дата для sheet'а ввода веса: «Сегодня, 21 февраля»
    var sheetDateString: String {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "d MMMM"
        let dateStr = formatter.string(from: self)

        if calendar.isDateInToday(self) {
            return "Сегодня, \(dateStr)"
        }
        if calendar.isDateInYesterday(self) {
            return "Вчера, \(dateStr)"
        }
        return displayString
    }

    // MARK: - Day Boundaries

    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

    var endOfDay: Date {
        Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!.addingTimeInterval(-1)
    }

    // MARK: - Meal Type by Time

    /// Определение приёма пищи по текущему времени:
    /// - 06:00–10:59 → Завтрак
    /// - 11:00–14:59 → Обед
    /// - 15:00–19:59 → Ужин
    /// - 20:00–05:59 → Перекус
    static func mealTypeForCurrentTime() -> MealType {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 6...10: return .breakfast
        case 11...14: return .lunch
        case 15...19: return .dinner
        default: return .snack
        }
    }
}

// MARK: - String Helper

private extension String {
    /// Делает первую букву заглавной, остальные не трогает
    var capitalizedFirstLetter: String {
        guard let first = self.first else { return self }
        return first.uppercased() + self.dropFirst()
    }
}
