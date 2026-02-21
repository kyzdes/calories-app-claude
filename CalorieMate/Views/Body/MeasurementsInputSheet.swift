import SwiftUI

struct MeasurementsInputSheet: View {
    @Bindable var viewModel: BodyTrackingViewModel
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Замеры тела")
                    .font(.cmH2)
                    .foregroundStyle(Color.cmTextPrimary)

                Text(Date().sheetDateString)
                    .font(.cmCallout)
                    .foregroundStyle(Color.cmTextSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                measurementField(label: "Талия (см)", text: $viewModel.waistText)
                measurementField(label: "Бёдра (см)", text: $viewModel.hipsText)
                measurementField(label: "Грудь (см)", text: $viewModel.chestText)
                measurementField(label: "Бицепс (см)", text: $viewModel.bicepsText)
            }

            Spacer()

            PrimaryButton(title: "Сохранить") {
                viewModel.saveMeasurements(context: modelContext)
            }
        }
        .padding(16)
        .padding(.top, 8)
    }

    @ViewBuilder
    private func measurementField(label: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.cmCaption)
                .foregroundStyle(Color.cmTextSecondary)

            TextField("", text: text)
                .font(.cmNumberMd)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.center)
                .padding(.vertical, 12)
                .background(Color.cmBgTertiary)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}
