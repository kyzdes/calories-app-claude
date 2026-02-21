import Foundation
import SwiftData
import Observation

@Observable
final class FoodLogViewModel {

    // MARK: - Search

    var searchText: String = ""
    var searchResults: [Product] = []
    var isSearching = false
    var isOffline = false
    var recentProducts: [Product] = []
    var frequentProducts: [Product] = []

    // MARK: - Portion

    var selectedProduct: Product?
    var portionText: String = "100"
    var selectedMealType: MealType = Date.mealTypeForCurrentTime()
    var showPortionSheet = false

    // MARK: - Create Product

    var showCreateSheet = false
    var newProductName: String = ""
    var newProductBarcode: String = ""
    var newProductCalories: String = ""
    var newProductProtein: String = ""
    var newProductFat: String = ""
    var newProductCarbs: String = ""

    // MARK: - Computed

    var portionGrams: Double {
        let cleaned = portionText.replacingOccurrences(of: ",", with: ".")
        return Double(cleaned) ?? 0
    }

    var calculatedCalories: Int {
        guard let product = selectedProduct, portionGrams > 0 else { return 0 }
        return Int((portionGrams / 100.0 * product.caloriesPer100g).rounded())
    }

    var calculatedProtein: Double {
        guard let product = selectedProduct, portionGrams > 0 else { return 0 }
        return (portionGrams / 100.0 * product.proteinPer100g).rounded()
    }

    var calculatedFat: Double {
        guard let product = selectedProduct, portionGrams > 0 else { return 0 }
        return (portionGrams / 100.0 * product.fatPer100g).rounded()
    }

    var calculatedCarbs: Double {
        guard let product = selectedProduct, portionGrams > 0 else { return 0 }
        return (portionGrams / 100.0 * product.carbsPer100g).rounded()
    }

    var canAddEntry: Bool {
        selectedProduct != nil && portionGrams > 0
    }

    var isCreateFormValid: Bool {
        !newProductName.isEmpty &&
        newProductName.count >= 2 &&
        (Double(newProductCalories) ?? -1) >= 0 &&
        (Double(newProductProtein) ?? -1) >= 0 &&
        (Double(newProductFat) ?? -1) >= 0 &&
        (Double(newProductCarbs) ?? -1) >= 0
    }

    // MARK: - Search with Debounce

    private var searchTask: Task<Void, Never>?

    func onSearchTextChanged(context: ModelContext) {
        searchTask?.cancel()

        guard searchText.count >= 2 else {
            searchResults = []
            isSearching = false
            return
        }

        isSearching = true

        searchTask = Task { @MainActor in
            // Debounce 300ms
            try? await Task.sleep(for: .milliseconds(300))
            guard !Task.isCancelled else { return }

            let query = searchText
            let result = await FoodSearchService.search(query: query, context: context)

            guard !Task.isCancelled else { return }
            searchResults = result.products
            isOffline = result.isOffline
            isSearching = false
        }
    }

    // MARK: - Load Recent & Frequent

    func loadRecentsAndFrequents(context: ModelContext) {
        recentProducts = FoodSearchService.recentProducts(context: context)
        frequentProducts = FoodSearchService.frequentProducts(context: context)
    }

    // MARK: - Select Product

    func selectProduct(_ product: Product, preselectedMeal: MealType? = nil) {
        selectedProduct = product

        // Предзаполнение порции: последняя использованная или 100г
        portionText = "100"

        if let meal = preselectedMeal {
            selectedMealType = meal
        } else {
            selectedMealType = Date.mealTypeForCurrentTime()
        }

        showPortionSheet = true
    }

    func selectPortionPreset(_ grams: Int) {
        portionText = "\(grams)"
    }

    // MARK: - Add Food Entry

    func addFoodEntry(date: Date, context: ModelContext) {
        guard let product = selectedProduct, portionGrams > 0 else { return }

        let entry = FoodEntry(
            productId: product.id,
            productName: product.name,
            date: date,
            mealType: selectedMealType,
            portionGrams: portionGrams,
            calories: calculatedCalories,
            protein: calculatedProtein,
            fat: calculatedFat,
            carbs: calculatedCarbs
        )

        context.insert(entry)

        // Обновляем статистику продукта
        product.usageCount += 1
        product.lastUsed = Date()

        // Сохраняем продукт в локальный кэш, если из OFF
        if product.source == .off {
            // Проверяем, есть ли уже в кэше
            let barcode = product.barcode
            let descriptor = FetchDescriptor<Product>(
                predicate: #Predicate<Product> { p in
                    p.barcode != nil && p.barcode == barcode
                }
            )
            let existing = (try? context.fetch(descriptor)) ?? []
            if existing.isEmpty {
                context.insert(product)
            }
        }

        resetSelection()
    }

    // MARK: - Create UGC Product

    func createAndAddProduct(date: Date, context: ModelContext) {
        let product = Product(
            name: newProductName,
            barcode: newProductBarcode.isEmpty ? nil : newProductBarcode,
            caloriesPer100g: Double(newProductCalories) ?? 0,
            proteinPer100g: Double(newProductProtein) ?? 0,
            fatPer100g: Double(newProductFat) ?? 0,
            carbsPer100g: Double(newProductCarbs) ?? 0,
            source: .ugc,
            usageCount: 1,
            lastUsed: Date()
        )

        context.insert(product)

        // Сразу добавляем в дневник
        selectedProduct = product
        portionText = "100"
        addFoodEntry(date: date, context: context)

        resetCreateForm()
    }

    // MARK: - Reset

    private func resetSelection() {
        selectedProduct = nil
        portionText = "100"
        showPortionSheet = false
    }

    func resetCreateForm() {
        newProductName = ""
        newProductBarcode = ""
        newProductCalories = ""
        newProductProtein = ""
        newProductFat = ""
        newProductCarbs = ""
        showCreateSheet = false
    }
}
