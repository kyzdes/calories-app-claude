import SwiftUI
import SwiftData

struct CalorieResultView: View {
    @Bindable var viewModel: OnboardingViewModel
    @Environment(\.modelContext) private var modelContext
    let onComplete: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Text("Ваш план готов!")
                .font(.cmH1)
                .foregroundStyle(Color.cmTextPrimary)
                .padding(.top, 8)

            // Карточка результата
            if let result = viewModel.calculationResult {
                resultCard(result: result)
            }

            // Целевой вес
            targetWeightField

            Text("Вы всегда можете изменить\nэти значения в профиле")
                .font(.cmCaption)
                .foregroundStyle(Color.cmTextTertiary)
                .multilineTextAlignment(.center)

            Spacer()

            PrimaryButton(
                title: "Начать отслеживание",
                action: {
                    viewModel.saveProfile(context: modelContext)
                    onComplete()
                }
            )
            .padding(.bottom, 16)
        }
        .padding(.horizontal, 16)
    }

    // MARK: - Result Card

    @ViewBuilder
    private func resultCard(result: CalculationResult) -> some View {
        VStack(spacing: 16) {
            Text("Ваша дневная норма:")
                .font(.cmCallout)
                .foregroundStyle(Color.cmTextSecondary)

            VStack(spacing: 4) {
                Text(result.targetCalories.formattedCaloriesValue)
                    .font(.cmHero)
                    .foregroundStyle(Color.cmPrimary)
                    .contentTransition(.numericText())

                Text("ккал")
                    .font(.cmCallout)
                    .foregroundStyle(Color.cmTextTertiary)
            }

            HStack(spacing: 16) {
                macroLabel("Б", value: result.proteinGrams, color: .cmProtein)
                macroLabel("Ж", value: result.fatGrams, color: .cmFat)
                macroLabel("У", value: result.carbsGrams, color: .cmCarbs)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(Color.cmPrimaryLight)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    @ViewBuilder
    private func macroLabel(_ prefix: String, value: Int, color: Color) -> some View {
        HStack(spacing: 4) {
            Text(prefix)
                .font(.cmBodyBold)
                .foregroundStyle(color)

            Text("\(value)\u{00A0}г")
                .font(.cmBody)
                .foregroundStyle(Color.cmTextPrimary)
        }
    }

    // MARK: - Target Weight

    private var targetWeightField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Целевой вес (опционально)")
                .font(.cmCallout)
                .foregroundStyle(Color.cmTextSecondary)

            HStack {
                TextField("", text: $viewModel.targetWeightText)
                    .font(.cmNumberLg)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.center)

                Text("кг")
                    .font(.cmBody)
                    .foregroundStyle(Color.cmTextTertiary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.cmBgTertiary)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

#Preview {
    let vm = OnboardingViewModel()
    vm.calculationResult = CalorieCalculator.calculate(
        gender: .male, weight: 82.5, height: 175,
        age: 28, activityLevel: .light, goal: .lose
    )
    return CalorieResultView(viewModel: vm, onComplete: {})
        .modelContainer(for: UserProfile.self, inMemory: true)
}
