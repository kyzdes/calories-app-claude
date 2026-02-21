import SwiftUI

struct CreateProductSheet: View {
    @Bindable var viewModel: FoodLogViewModel
    let date: Date
    let onCreate: () -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Name
                    inputField(
                        label: "Название *",
                        text: $viewModel.newProductName,
                        placeholder: "Например: Творог 5%",
                        keyboard: .default
                    )

                    // Barcode
                    inputField(
                        label: "Штрих-код",
                        text: $viewModel.newProductBarcode,
                        placeholder: "EAN-13 (необязательно)",
                        keyboard: .numberPad
                    )

                    // Nutrition per 100g
                    Text("Значения на 100\u{00A0}г: *")
                        .font(.cmCallout)
                        .foregroundStyle(Color.cmTextSecondary)

                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 12) {
                        nutritionField(label: "Калории", text: $viewModel.newProductCalories, unit: "ккал")
                        nutritionField(label: "Белки", text: $viewModel.newProductProtein, unit: "г")
                        nutritionField(label: "Жиры", text: $viewModel.newProductFat, unit: "г")
                        nutritionField(label: "Углев.", text: $viewModel.newProductCarbs, unit: "г")
                    }

                    // BJU consistency warning
                    if showBJUWarning {
                        Text("Сумма БЖУ не соответствует калориям")
                            .font(.cmCaption)
                            .foregroundStyle(Color.cmWarning)
                    }
                }
                .padding(16)
            }
            .navigationTitle("Новый продукт")
            .navigationBarTitleDisplayMode(.inline)
            .safeAreaInset(edge: .bottom) {
                PrimaryButton(
                    title: "Создать и добавить",
                    action: onCreate,
                    isEnabled: viewModel.isCreateFormValid
                )
                .padding(16)
                .background(Color.cmBgPrimary)
            }
        }
    }

    private var showBJUWarning: Bool {
        guard let cal = Double(viewModel.newProductCalories), cal > 0,
              let p = Double(viewModel.newProductProtein),
              let f = Double(viewModel.newProductFat),
              let c = Double(viewModel.newProductCarbs) else { return false }

        let estimated = p * 4 + f * 9 + c * 4
        let deviation = abs(estimated - cal) / cal
        return deviation > 0.2
    }

    @ViewBuilder
    private func inputField(label: String, text: Binding<String>, placeholder: String, keyboard: UIKeyboardType) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.cmCallout)
                .foregroundStyle(Color.cmTextSecondary)

            TextField(placeholder, text: text)
                .font(.cmBody)
                .keyboardType(keyboard)
                .padding(12)
                .background(Color.cmBgTertiary)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    @ViewBuilder
    private func nutritionField(label: String, text: Binding<String>, unit: String) -> some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.cmCaption)
                .foregroundStyle(Color.cmTextSecondary)

            TextField("0", text: text)
                .font(.cmNumberMd)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.center)
                .padding(.vertical, 8)
                .background(Color.cmBgTertiary)
                .clipShape(RoundedRectangle(cornerRadius: 8))

            Text(unit)
                .font(.cmCaption2)
                .foregroundStyle(Color.cmTextTertiary)
        }
    }
}
