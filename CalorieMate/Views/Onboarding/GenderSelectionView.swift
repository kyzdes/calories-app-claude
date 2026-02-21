import SwiftUI

struct GenderSelectionView: View {
    @Bindable var viewModel: OnboardingViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Ваш пол")
                .font(.cmH1)
                .foregroundStyle(Color.cmTextPrimary)
                .padding(.top, 8)

            Picker("Пол", selection: Binding(
                get: { viewModel.selectedGender ?? .male },
                set: { viewModel.selectedGender = $0 }
            )) {
                ForEach(Gender.allCases, id: \.self) { gender in
                    Text(gender.displayName).tag(gender)
                }
            }
            .pickerStyle(.segmented)
            .onChange(of: viewModel.selectedGender) { _, newValue in
                if newValue == nil {
                    viewModel.selectedGender = .male
                }
            }

            Text("Нужен для точного расчёта нормы\nкалорий по формуле Mifflin-St Jeor")
                .font(.cmCaption)
                .foregroundStyle(Color.cmTextTertiary)

            Spacer()

            PrimaryButton(
                title: "Далее",
                action: { viewModel.goNext() },
                isEnabled: viewModel.canProceedFromGender
            )
            .padding(.bottom, 16)
        }
        .padding(.horizontal, 16)
    }
}

#Preview {
    GenderSelectionView(viewModel: OnboardingViewModel())
}
