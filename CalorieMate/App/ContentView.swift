import SwiftUI
import SwiftData

struct ContentView: View {
    @Query private var profiles: [UserProfile]
    @State private var showOnboarding = false

    private var hasProfile: Bool {
        !profiles.isEmpty
    }

    var body: some View {
        if hasProfile && !showOnboarding {
            MainTabView()
        } else {
            OnboardingContainerView {
                showOnboarding = false
            }
        }
    }
}

// MARK: - Onboarding Container

struct OnboardingContainerView: View {
    @State private var viewModel = OnboardingViewModel()
    let onComplete: () -> Void

    var body: some View {
        NavigationStack {
            VStack {
                // Step indicator
                if let stepNumber = viewModel.currentStep.stepNumber {
                    HStack {
                        Spacer()
                        Text("Шаг \(stepNumber)/5")
                            .font(.cmCaption)
                            .foregroundStyle(Color.cmTextTertiary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                }

                // Step content
                stepView
            }
            .background(Color.cmBgPrimary)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if viewModel.currentStep != .welcome && viewModel.currentStep != .goal {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            viewModel.goBack()
                        } label: {
                            Image(systemName: "chevron.left")
                                .foregroundStyle(Color.cmPrimary)
                        }
                    }
                }
            }
            .animation(.easeInOut(duration: 0.25), value: viewModel.currentStep)
        }
    }

    @ViewBuilder
    private var stepView: some View {
        switch viewModel.currentStep {
        case .welcome:
            WelcomeView {
                viewModel.goNext()
            }
        case .goal:
            GoalSelectionView(viewModel: viewModel)
        case .gender:
            GenderSelectionView(viewModel: viewModel)
        case .bodyParams:
            BodyParamsView(viewModel: viewModel)
        case .activity:
            ActivityLevelView(viewModel: viewModel)
        case .result:
            CalorieResultView(viewModel: viewModel, onComplete: onComplete)
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
