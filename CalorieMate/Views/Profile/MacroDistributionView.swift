import SwiftUI

struct MacroDistributionView: View {
    @Bindable var viewModel: ProfileViewModel
    let profile: UserProfile
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 24) {
            // Sum indicator
            HStack {
                Text("Сумма:")
                    .font(.cmBody)
                    .foregroundStyle(Color.cmTextSecondary)
                Text("\(viewModel.macroSumPercent)%")
                    .font(.cmNumberMd)
                    .foregroundStyle(viewModel.isMacroSumValid ? Color.cmSuccess : Color.cmDanger)
            }
            .padding(.top, 8)

            // Sliders
            VStack(spacing: 20) {
                macroSlider(
                    label: "Белки",
                    color: .cmProtein,
                    value: $viewModel.editProteinPercent
                )

                macroSlider(
                    label: "Жиры",
                    color: .cmFat,
                    value: $viewModel.editFatPercent
                )

                macroSlider(
                    label: "Углеводы",
                    color: .cmCarbs,
                    value: $viewModel.editCarbsPercent
                )
            }

            // Gram equivalents
            let macros = CalorieCalculator.macrosInGrams(
                calories: profile.dailyCalorieGoal,
                proteinRatio: viewModel.editProteinPercent / 100,
                fatRatio: viewModel.editFatPercent / 100,
                carbsRatio: viewModel.editCarbsPercent / 100
            )

            HStack(spacing: 16) {
                gramLabel("Б", grams: macros.protein, color: .cmProtein)
                gramLabel("Ж", grams: macros.fat, color: .cmFat)
                gramLabel("У", grams: macros.carbs, color: .cmCarbs)
            }
            .padding(12)
            .background(Color.cmBgSecondary)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            // Presets
            VStack(alignment: .leading, spacing: 8) {
                Text("Быстрый выбор")
                    .font(.cmCaption)
                    .foregroundStyle(Color.cmTextTertiary)

                HStack(spacing: 8) {
                    ForEach(Goal.allCases, id: \.self) { goal in
                        let ratios = CalorieCalculator.defaultMacroRatios(for: goal)
                        let label = "\(Int(ratios.protein * 100))/\(Int(ratios.fat * 100))/\(Int(ratios.carbs * 100))"
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                viewModel.applyDefaultMacros(for: goal)
                            }
                        } label: {
                            VStack(spacing: 4) {
                                Text(goal.displayName)
                                    .font(.cmCaption)
                                Text(label)
                                    .font(.cmCaption2)
                            }
                            .foregroundStyle(Color.cmTextPrimary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(Color.cmBgTertiary)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                }
            }

            Spacer()

            PrimaryButton(title: "Сохранить", isEnabled: viewModel.isMacroSumValid) {
                viewModel.saveMacros(profile)
                dismiss()
            }
        }
        .padding(16)
        .background(Color.cmBgPrimary)
        .navigationTitle("Распределение БЖУ")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Macro Slider

    private func macroSlider(label: String, color: Color, value: Binding<Double>) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label)
                    .font(.cmBodyBold)
                    .foregroundStyle(color)
                Spacer()
                Text("\(Int(value.wrappedValue))%")
                    .font(.cmNumberSm)
                    .foregroundStyle(Color.cmTextPrimary)
            }

            Slider(value: value, in: 5...70, step: 5)
                .tint(color)
        }
    }

    // MARK: - Gram Label

    private func gramLabel(_ label: String, grams: Int, color: Color) -> some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.cmCaption)
                .foregroundStyle(color)
            Text("\(grams)\u{00A0}г")
                .font(.cmNumberSm)
                .foregroundStyle(Color.cmTextPrimary)
        }
        .frame(maxWidth: .infinity)
    }
}
