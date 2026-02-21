import SwiftUI

struct GoalSelectionView: View {
    @Bindable var viewModel: OnboardingViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Какая у вас цель?")
                .font(.cmH1)
                .foregroundStyle(Color.cmTextPrimary)
                .padding(.top, 8)

            VStack(spacing: 12) {
                ForEach(Goal.allCases, id: \.self) { goal in
                    SelectionCard(
                        icon: goal.icon,
                        title: goal.displayName,
                        description: goal.description,
                        isSelected: viewModel.selectedGoal == goal,
                        action: { viewModel.selectedGoal = goal }
                    )
                }
            }

            Spacer()

            PrimaryButton(
                title: "Далее",
                action: { viewModel.goNext() },
                isEnabled: viewModel.canProceedFromGoal
            )
            .padding(.bottom, 16)
        }
        .padding(.horizontal, 16)
    }
}

#Preview {
    GoalSelectionView(viewModel: OnboardingViewModel())
}
