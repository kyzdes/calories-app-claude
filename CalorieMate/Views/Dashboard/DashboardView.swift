import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    @Query(sort: \FoodEntry.createdAt) private var allEntries: [FoodEntry]
    @State private var viewModel = DashboardViewModel()
    @State private var showAddFoodSheet = false
    @State private var selectedMealType: MealType?

    private var profile: UserProfile? { profiles.first }

    private var todayEntries: [FoodEntry] {
        let start = viewModel.selectedDate.startOfDay
        let end = viewModel.selectedDate.endOfDay
        return allEntries.filter { $0.date >= start && $0.date <= end }
    }

    private var macroGoals: (protein: Int, fat: Int, carbs: Int) {
        guard let profile else { return (0, 0, 0) }
        return CalorieCalculator.macrosInGrams(
            calories: profile.dailyCalorieGoal,
            proteinRatio: profile.proteinRatio,
            fatRatio: profile.fatRatio,
            carbsRatio: profile.carbsRatio
        )
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(spacing: 20) {
                    // Date switcher
                    DateSwitcherView(
                        selectedDate: $viewModel.selectedDate,
                        canGoForward: viewModel.canGoForward,
                        onPrevious: { viewModel.goToPreviousDay() },
                        onNext: { viewModel.goToNextDay() }
                    )
                    .sensoryFeedback(.selection, trigger: viewModel.selectedDate)

                    // Calorie ring
                    CalorieRingView(
                        consumed: viewModel.totalCalories(from: todayEntries),
                        goal: profile?.dailyCalorieGoal ?? 2000
                    )

                    // Macro progress bars
                    MacroProgressGroup(
                        protein: viewModel.totalProtein(from: todayEntries),
                        fat: viewModel.totalFat(from: todayEntries),
                        carbs: viewModel.totalCarbs(from: todayEntries),
                        proteinGoal: macroGoals.protein,
                        fatGoal: macroGoals.fat,
                        carbsGoal: macroGoals.carbs
                    )
                    .padding(.horizontal, 16)

                    // Meal sections
                    VStack(spacing: 12) {
                        ForEach(MealType.allCases.sorted(by: { $0.sortOrder < $1.sortOrder }), id: \.self) { mealType in
                            let entries = viewModel.entriesForMeal(mealType, from: todayEntries)
                            MealSectionView(
                                mealType: mealType,
                                entries: entries,
                                totalCalories: viewModel.mealCalories(mealType, from: todayEntries),
                                onAddFood: {
                                    selectedMealType = mealType
                                    showAddFoodSheet = true
                                },
                                onTapEntry: { _ in
                                    // TODO: Итерация 4 — sheet редактирования порции
                                },
                                onDeleteEntry: { entry in
                                    viewModel.deleteEntry(entry, context: modelContext)
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 100) // Space for tab bar
                }
            }
            .gesture(
                DragGesture(minimumDistance: 50)
                    .onEnded { value in
                        if value.translation.width > 50 {
                            viewModel.goToPreviousDay()
                        } else if value.translation.width < -50 && viewModel.canGoForward {
                            viewModel.goToNextDay()
                        }
                    }
            )

            // Undo toast
            if viewModel.showUndoToast {
                UndoToast(message: "Удалено") {
                    viewModel.undoDelete(context: modelContext)
                }
                .padding(.bottom, 90)
                .animation(.easeInOut(duration: 0.3), value: viewModel.showUndoToast)
            }
        }
        .background(Color.cmBgPrimary)
        .sheet(isPresented: $showAddFoodSheet) {
            AddFoodSheet(
                date: viewModel.selectedDate,
                preselectedMealType: selectedMealType
            )
            .presentationDetents([.large])
        }
    }
}

#Preview {
    DashboardView()
        .modelContainer(for: [
            Product.self, FoodEntry.self, WeightEntry.self,
            BodyMeasurement.self, UserProfile.self
        ], inMemory: true)
}
