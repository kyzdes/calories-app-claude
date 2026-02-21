import SwiftUI
import SwiftData

struct ProgressTabView: View {
    @Query(sort: \FoodEntry.date) private var foodEntries: [FoodEntry]
    @Query(sort: \WeightEntry.date) private var weightEntries: [WeightEntry]
    @Query private var profiles: [UserProfile]
    @State private var viewModel = ProgressViewModel()

    private var profile: UserProfile? { profiles.first }
    private var goal: Int { profile?.dailyCalorieGoal ?? 2000 }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Summary cards
                    let avgMacros = viewModel.averageMacros(from: foodEntries, period: viewModel.caloriesPeriod)
                    SummaryCardsView(
                        averageCalories: viewModel.averageCalories(from: foodEntries, period: viewModel.caloriesPeriod),
                        averageProtein: avgMacros.protein,
                        averageFat: avgMacros.fat,
                        averageCarbs: avgMacros.carbs,
                        complianceRate: viewModel.complianceRate(from: foodEntries, period: viewModel.caloriesPeriod, goal: goal)
                    )
                    .padding(.horizontal, 16)

                    // Calories chart
                    CaloriesChartView(
                        data: viewModel.dailyCalories(from: foodEntries, period: viewModel.caloriesPeriod, goal: goal),
                        goal: goal,
                        period: $viewModel.caloriesPeriod
                    )
                    .padding(.horizontal, 16)

                    // Macros chart
                    MacrosChartView(
                        data: viewModel.dailyMacros(from: foodEntries, period: viewModel.macrosPeriod),
                        period: $viewModel.macrosPeriod
                    )
                    .padding(.horizontal, 16)

                    // Weight chart
                    WeightChartView(
                        entries: viewModel.filterWeightByPeriod(weightEntries, period: viewModel.weightPeriod),
                        goalWeight: profile?.targetWeight
                    )
                    .padding(.horizontal, 16)

                    PeriodPicker(selected: $viewModel.weightPeriod)
                        .padding(.horizontal, 16)
                }
                .padding(.bottom, 100)
            }
            .background(Color.cmBgPrimary)
            .navigationTitle("Прогресс")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    ProgressTabView()
        .modelContainer(for: [
            Product.self, FoodEntry.self, WeightEntry.self,
            BodyMeasurement.self, UserProfile.self
        ], inMemory: true)
}
