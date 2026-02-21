import SwiftUI

struct PortionSheet: View {
    @Bindable var viewModel: FoodLogViewModel
    let date: Date
    let onAdd: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            // Product info
            if let product = viewModel.selectedProduct {
                VStack(alignment: .leading, spacing: 4) {
                    Text(product.name)
                        .font(.cmH2)
                        .foregroundStyle(Color.cmTextPrimary)
                        .lineLimit(2)

                    Text("\(Int(product.caloriesPer100g))\u{00A0}ккал на 100\u{00A0}г")
                        .font(.cmCallout)
                        .foregroundStyle(Color.cmTextSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            // Portion stepper
            PortionStepper(
                portionText: $viewModel.portionText,
                presets: [50, 100, 150, 200]
            )

            // Calculated nutrition
            VStack(spacing: 8) {
                nutritionRow("Калории:", value: "\(viewModel.calculatedCalories)\u{00A0}ккал")
                nutritionRow("Белки:", value: "\(Int(viewModel.calculatedProtein))\u{00A0}г", color: .cmProtein)
                nutritionRow("Жиры:", value: "\(Int(viewModel.calculatedFat))\u{00A0}г", color: .cmFat)
                nutritionRow("Углеводы:", value: "\(Int(viewModel.calculatedCarbs))\u{00A0}г", color: .cmCarbs)
            }
            .padding(16)
            .background(Color.cmBgSecondary)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            // Meal type picker
            VStack(alignment: .leading, spacing: 8) {
                Text("Приём пищи:")
                    .font(.cmCallout)
                    .foregroundStyle(Color.cmTextSecondary)

                HStack(spacing: 8) {
                    ForEach(MealType.allCases.sorted(by: { $0.sortOrder < $1.sortOrder }), id: \.self) { meal in
                        Button {
                            viewModel.selectedMealType = meal
                        } label: {
                            Text(meal.displayName)
                                .font(.cmCaption)
                                .foregroundStyle(viewModel.selectedMealType == meal ? .white : Color.cmTextPrimary)
                                .padding(.horizontal, 12)
                                .frame(height: 36)
                                .background(viewModel.selectedMealType == meal ? Color.cmPrimary : Color.cmBgTertiary)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                }
            }

            Spacer()

            PrimaryButton(
                title: "Добавить",
                action: onAdd,
                isEnabled: viewModel.canAddEntry
            )
        }
        .padding(16)
        .padding(.top, 8)
        .sensoryFeedback(.selection, trigger: viewModel.selectedMealType)
    }

    @ViewBuilder
    private func nutritionRow(_ label: String, value: String, color: Color = .cmTextPrimary) -> some View {
        HStack {
            Text(label)
                .font(.cmCallout)
                .foregroundStyle(Color.cmTextSecondary)
            Spacer()
            Text(value)
                .font(.cmBodyBold)
                .foregroundStyle(color)
        }
    }
}
