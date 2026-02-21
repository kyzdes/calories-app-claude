import Foundation
import SwiftData

struct FoodSearchService {

    /// Поиск по локальному кэшу (SwiftData) + Open Food Facts API.
    /// Результаты мержатся: сначала локальные (мгновенно), затем OFF (async).
    static func search(query: String, context: ModelContext) async -> SearchResult {
        let localResults = searchLocal(query: query, context: context)

        do {
            let offResults = try await OpenFoodFactsService.search(query: query)
            // Мерж: локальные первые, затем OFF без дубликатов по barcode
            let existingBarcodes = Set(localResults.compactMap(\.barcode))
            let filtered = offResults.filter { product in
                guard let barcode = product.barcode else { return true }
                return !existingBarcodes.contains(barcode)
            }
            return SearchResult(products: localResults + filtered, isOffline: false)
        } catch {
            return SearchResult(products: localResults, isOffline: true)
        }
    }

    /// Поиск только по локальному кэшу
    static func searchLocal(query: String, context: ModelContext) -> [Product] {
        let lowercased = query.lowercased()
        let descriptor = FetchDescriptor<Product>(
            predicate: #Predicate<Product> { product in
                product.name.localizedStandardContains(lowercased)
            },
            sortBy: [SortDescriptor(\Product.usageCount, order: .reverse)]
        )

        return (try? context.fetch(descriptor)) ?? []
    }

    /// Недавние продукты (последние 20 уникальных)
    static func recentProducts(context: ModelContext) -> [Product] {
        let descriptor = FetchDescriptor<Product>(
            predicate: #Predicate<Product> { $0.lastUsed != nil },
            sortBy: [SortDescriptor(\Product.lastUsed, order: .reverse)]
        )

        let products = (try? context.fetch(descriptor)) ?? []
        return Array(products.prefix(20))
    }

    /// Частые продукты (топ-10 по использованию)
    static func frequentProducts(context: ModelContext) -> [Product] {
        let descriptor = FetchDescriptor<Product>(
            predicate: #Predicate<Product> { $0.usageCount > 0 },
            sortBy: [SortDescriptor(\Product.usageCount, order: .reverse)]
        )

        let products = (try? context.fetch(descriptor)) ?? []
        return Array(products.prefix(10))
    }
}

// MARK: - Search Result

struct SearchResult {
    let products: [Product]
    let isOffline: Bool
}
