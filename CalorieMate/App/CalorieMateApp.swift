import SwiftUI
import SwiftData

@main
struct CalorieMateApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [
            Product.self,
            FoodEntry.self,
            WeightEntry.self,
            BodyMeasurement.self,
            UserProfile.self
        ])
    }
}
