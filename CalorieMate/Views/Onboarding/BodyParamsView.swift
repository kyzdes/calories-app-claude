import SwiftUI

struct BodyParamsView: View {
    @Bindable var viewModel: OnboardingViewModel
    @FocusState private var focusedField: Field?

    private enum Field: Hashable {
        case age, height, weight
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Ваши параметры")
                .font(.cmH1)
                .foregroundStyle(Color.cmTextPrimary)
                .padding(.top, 8)

            VStack(spacing: 16) {
                parameterField(
                    label: "Возраст",
                    text: $viewModel.ageText,
                    unit: "лет",
                    field: .age,
                    keyboard: .numberPad,
                    isValid: viewModel.isAgeValid
                )

                parameterField(
                    label: "Рост",
                    text: $viewModel.heightText,
                    unit: "см",
                    field: .height,
                    keyboard: .numberPad,
                    isValid: viewModel.isHeightValid
                )

                parameterField(
                    label: "Текущий вес",
                    text: $viewModel.weightText,
                    unit: "кг",
                    field: .weight,
                    keyboard: .decimalPad,
                    isValid: viewModel.isWeightValid
                )
            }

            Spacer()

            PrimaryButton(
                title: "Далее",
                action: {
                    focusedField = nil
                    viewModel.goNext()
                },
                isEnabled: viewModel.canProceedFromBodyParams
            )
            .padding(.bottom, 16)
        }
        .padding(.horizontal, 16)
        .onAppear {
            focusedField = .age
        }
    }

    // MARK: - Parameter Field

    @ViewBuilder
    private func parameterField(
        label: String,
        text: Binding<String>,
        unit: String,
        field: Field,
        keyboard: UIKeyboardType,
        isValid: Bool
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.cmCallout)
                .foregroundStyle(Color.cmTextSecondary)

            HStack {
                TextField("", text: text)
                    .font(.cmNumberLg)
                    .keyboardType(keyboard)
                    .multilineTextAlignment(.center)
                    .focused($focusedField, equals: field)
                    .onSubmit {
                        switch field {
                        case .age: focusedField = .height
                        case .height: focusedField = .weight
                        case .weight: focusedField = nil
                        }
                    }

                Text(unit)
                    .font(.cmBody)
                    .foregroundStyle(Color.cmTextTertiary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.cmBgTertiary)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isValid ? Color.clear : Color.cmDanger, lineWidth: 2)
            )
        }
    }
}

#Preview {
    BodyParamsView(viewModel: OnboardingViewModel())
}
