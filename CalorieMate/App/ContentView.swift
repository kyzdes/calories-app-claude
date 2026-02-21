import SwiftUI
import SwiftData

struct ContentView: View {
    @Query private var profiles: [UserProfile]

    private var hasProfile: Bool {
        !profiles.isEmpty
    }

    var body: some View {
        if hasProfile {
            // TODO: Итерация 3 — TabBar с 5 табами
            Text("Главный экран")
                .font(.cmH1)
                .foregroundStyle(Color.cmTextPrimary)
        } else {
            // TODO: Итерация 2 — Onboarding flow
            Text("Онбординг")
                .font(.cmH1)
                .foregroundStyle(Color.cmTextPrimary)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [
            Product.self,
            FoodEntry.self,
            WeightEntry.self,
            BodyMeasurement.self,
            UserProfile.self
        ], inMemory: true)
}
