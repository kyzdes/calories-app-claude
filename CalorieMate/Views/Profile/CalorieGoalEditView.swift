import SwiftUI

struct CalorieGoalEditView: View {
    @Bindable var viewModel: ProfileViewModel
    let profile: UserProfile
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isFocused: Bool

    private var isValid: Bool {
        guard let val = Int(viewModel.editCalorieGoal) else { return false }
        return val > 0 && val <= 10000
    }

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            VStack(spacing: 8) {
                TextField("2000", text: $viewModel.editCalorieGoal)
                    .font(.cmHero)
                    .foregroundStyle(Color.cmTextPrimary)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.center)
                    .focused($isFocused)

                Text("ккал/день")
                    .font(.cmCallout)
                    .foregroundStyle(Color.cmTextSecondary)
            }

            Spacer()

            PrimaryButton(title: "Сохранить", isEnabled: isValid) {
                viewModel.saveCalorieGoal(profile)
                dismiss()
            }
        }
        .padding(16)
        .background(Color.cmBgPrimary)
        .navigationTitle("Дневная норма")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            isFocused = true
        }
    }
}
