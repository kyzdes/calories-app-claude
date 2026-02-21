import SwiftUI

struct WeightInputSheet: View {
    @Bindable var viewModel: BodyTrackingViewModel
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Записать вес")
                    .font(.cmH2)
                    .foregroundStyle(Color.cmTextPrimary)

                Text(Date().sheetDateString)
                    .font(.cmCallout)
                    .foregroundStyle(Color.cmTextSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            HStack {
                TextField("", text: $viewModel.weightText)
                    .font(.cmNumberLg)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.center)

                Text("кг")
                    .font(.cmBody)
                    .foregroundStyle(Color.cmTextTertiary)
            }
            .padding(.horizontal, 16)
            .frame(height: 56)
            .background(Color.cmBgTertiary)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            Spacer()

            PrimaryButton(title: "Сохранить") {
                viewModel.saveWeight(context: modelContext)
            }
        }
        .padding(16)
        .padding(.top, 8)
    }
}
