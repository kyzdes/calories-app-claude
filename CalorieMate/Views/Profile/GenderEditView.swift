import SwiftUI

struct GenderEditView: View {
    @Bindable var viewModel: ProfileViewModel
    let profile: UserProfile
    let weightEntries: [WeightEntry]
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Picker("Пол", selection: $viewModel.editGender) {
                ForEach(Gender.allCases, id: \.self) { gender in
                    Text(gender.displayName).tag(gender)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 32)

            Spacer()

            PrimaryButton(title: "Сохранить") {
                viewModel.saveGender(profile, weightEntries: weightEntries)
                dismiss()
            }
        }
        .padding(16)
        .background(Color.cmBgPrimary)
        .navigationTitle("Пол")
        .navigationBarTitleDisplayMode(.inline)
    }
}
