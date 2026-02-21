import Foundation

struct OpenFoodFactsService {

    private static let baseURL = "https://world.openfoodfacts.org"
    private static let userAgent = "CalorieMate iOS/1.0"

    // MARK: - Search by Text

    static func search(query: String) async throws -> [Product] {
        guard let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return []
        }

        let urlString = "\(baseURL)/cgi/search.pl?search_terms=\(encoded)&search_simple=1&action=process&json=1&page_size=20&cc=ru&lc=ru"
        guard let url = URL(string: urlString) else { return [] }

        var request = URLRequest(url: url)
        request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        request.timeoutInterval = 10

        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(OFFSearchResponse.self, from: data)

        return response.products.compactMap { $0.toProduct() }
    }

    // MARK: - Search by Barcode

    static func searchByBarcode(_ barcode: String) async throws -> Product? {
        let urlString = "\(baseURL)/api/v2/product/\(barcode).json"
        guard let url = URL(string: urlString) else { return nil }

        var request = URLRequest(url: url)
        request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        request.timeoutInterval = 10

        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(OFFProductResponse.self, from: data)

        guard response.status == 1 else { return nil }
        return response.product?.toProduct()
    }
}

// MARK: - API Response Models

private struct OFFSearchResponse: Decodable {
    let products: [OFFProduct]
}

private struct OFFProductResponse: Decodable {
    let status: Int
    let product: OFFProduct?
}

private struct OFFProduct: Decodable {
    let code: String?
    let productName: String?
    let productNameRu: String?
    let brands: String?
    let nutriments: OFFNutriments?

    enum CodingKeys: String, CodingKey {
        case code
        case productName = "product_name"
        case productNameRu = "product_name_ru"
        case brands
        case nutriments
    }

    func toProduct() -> Product? {
        let name = productNameRu ?? productName
        guard let name, !name.isEmpty else { return nil }

        let cal = nutriments?.energyKcal100g ?? 0
        let protein = nutriments?.proteins100g ?? 0
        let fat = nutriments?.fat100g ?? 0
        let carbs = nutriments?.carbohydrates100g ?? 0

        // Пропускаем продукты без данных о калориях
        guard cal > 0 || protein > 0 || fat > 0 || carbs > 0 else { return nil }

        var displayName = name
        if let brands, !brands.isEmpty {
            displayName = "\(name) \u{00AB}\(brands)\u{00BB}"
        }

        return Product(
            name: displayName,
            barcode: code,
            caloriesPer100g: cal,
            proteinPer100g: protein,
            fatPer100g: fat,
            carbsPer100g: carbs,
            source: .off,
            brand: brands
        )
    }
}

private struct OFFNutriments: Decodable {
    let energyKcal100g: Double?
    let proteins100g: Double?
    let fat100g: Double?
    let carbohydrates100g: Double?

    enum CodingKeys: String, CodingKey {
        case energyKcal100g = "energy-kcal_100g"
        case proteins100g = "proteins_100g"
        case fat100g = "fat_100g"
        case carbohydrates100g = "carbohydrates_100g"
    }
}
