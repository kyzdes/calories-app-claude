import Foundation

// MARK: - Goal

enum Goal: String, Codable, CaseIterable {
    case lose
    case gain
    case maintain

    var displayName: String {
        switch self {
        case .lose: "Похудеть"
        case .gain: "Набрать массу"
        case .maintain: "Поддерживать вес"
        }
    }

    var description: String {
        switch self {
        case .lose: "Снизить вес и жировую массу"
        case .gain: "Увеличить мышечную массу"
        case .maintain: "Контролировать питание"
        }
    }

    var icon: String {
        switch self {
        case .lose: "arrow.down"
        case .gain: "arrow.up"
        case .maintain: "equal"
        }
    }
}

// MARK: - Gender

enum Gender: String, Codable, CaseIterable {
    case male
    case female

    var displayName: String {
        switch self {
        case .male: "Мужской"
        case .female: "Женский"
        }
    }
}

// MARK: - MealType

enum MealType: String, Codable, CaseIterable {
    case breakfast
    case lunch
    case dinner
    case snack

    var displayName: String {
        switch self {
        case .breakfast: "Завтрак"
        case .lunch: "Обед"
        case .dinner: "Ужин"
        case .snack: "Перекус"
        }
    }

    var icon: String {
        switch self {
        case .breakfast: "sunrise"
        case .lunch: "sun.max"
        case .dinner: "sunset"
        case .snack: "cup.and.saucer"
        }
    }

    var sortOrder: Int {
        switch self {
        case .breakfast: 0
        case .lunch: 1
        case .dinner: 2
        case .snack: 3
        }
    }

    var addButtonTitle: String {
        switch self {
        case .breakfast: "Добавить завтрак"
        case .lunch: "Добавить обед"
        case .dinner: "Добавить ужин"
        case .snack: "Добавить перекус"
        }
    }
}

// MARK: - ActivityLevel

enum ActivityLevel: String, Codable, CaseIterable {
    case sedentary
    case light
    case moderate
    case active

    var multiplier: Double {
        switch self {
        case .sedentary: 1.2
        case .light: 1.375
        case .moderate: 1.55
        case .active: 1.725
        }
    }

    var displayName: String {
        switch self {
        case .sedentary: "Минимальная"
        case .light: "Лёгкая"
        case .moderate: "Средняя"
        case .active: "Высокая"
        }
    }

    var description: String {
        switch self {
        case .sedentary: "Сидячая работа, мало движения"
        case .light: "Тренировки 1\u{2013}3 раза в неделю"
        case .moderate: "Тренировки 3\u{2013}5 раз в неделю"
        case .active: "Тренировки 6\u{2013}7 раз в неделю"
        }
    }
}

// MARK: - ProductSource

enum ProductSource: String, Codable {
    case off
    case ugc
    case manual
}
