import Foundation
import SwiftData
import Observation

@Observable
final class DashboardViewModel {
    var selectedDate: Date = Date()
    var recentlyDeletedEntry: FoodEntry?
    var showUndoToast = false

    // MARK: - Date Navigation

    var canGoForward: Bool {
        !Calendar.current.isDateInToday(selectedDate)
    }

    func goToPreviousDay() {
        selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) ?? selectedDate
    }

    func goToNextDay() {
        guard canGoForward else { return }
        selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate
    }

    // MARK: - Data Aggregation

    func entriesForMeal(_ mealType: MealType, from entries: [FoodEntry]) -> [FoodEntry] {
        entries
            .filter { $0.mealType == mealType }
            .sorted { $0.createdAt < $1.createdAt }
    }

    func totalCalories(from entries: [FoodEntry]) -> Int {
        entries.reduce(0) { $0 + $1.calories }
    }

    func totalProtein(from entries: [FoodEntry]) -> Double {
        entries.reduce(0) { $0 + $1.protein }
    }

    func totalFat(from entries: [FoodEntry]) -> Double {
        entries.reduce(0) { $0 + $1.fat }
    }

    func totalCarbs(from entries: [FoodEntry]) -> Double {
        entries.reduce(0) { $0 + $1.carbs }
    }

    func mealCalories(_ mealType: MealType, from entries: [FoodEntry]) -> Int {
        entriesForMeal(mealType, from: entries).reduce(0) { $0 + $1.calories }
    }

    // MARK: - Delete with Undo

    func deleteEntry(_ entry: FoodEntry, context: ModelContext) {
        recentlyDeletedEntry = entry
        context.delete(entry)
        showUndoToast = true

        // Автоскрытие через 3 секунды
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(3))
            if showUndoToast {
                showUndoToast = false
                recentlyDeletedEntry = nil
            }
        }
    }

    func undoDelete(context: ModelContext) {
        guard let entry = recentlyDeletedEntry else { return }
        let restored = FoodEntry(
            productId: entry.productId,
            productName: entry.productName,
            date: entry.date,
            mealType: entry.mealType,
            portionGrams: entry.portionGrams,
            calories: entry.calories,
            protein: entry.protein,
            fat: entry.fat,
            carbs: entry.carbs,
            createdAt: entry.createdAt
        )
        context.insert(restored)
        recentlyDeletedEntry = nil
        showUndoToast = false
    }
}
