import SwiftUI

struct GoalEditView: View {
    @Bindable var viewModel: ProfileViewModel
    let profile: UserProfile
    let weightEntries: [WeightEntry]
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 16) {
            ForEach(Goal.allCases, id: \.self) { goal in
                SelectionCard(
                    icon: goal.icon,
                    title: goal.displayName,
                    description: goal.description,
                    isSelected: viewModel.editGoal == goal
                ) {
                    viewModel.editGoal = goal
                }
            }

            Spacer()

            PrimaryButton(title: "Сохранить") {
                viewModel.saveGoal(profile, weightEntries: weightEntries)
                dismiss()
            }
        }
        .padding(16)
        .background(Color.cmBgPrimary)
        .navigationTitle("Цель")
        .navigationBarTitleDisplayMode(.inline)
        .sensoryFeedback(.success, trigger: viewModel.editGoal)
    }
}
