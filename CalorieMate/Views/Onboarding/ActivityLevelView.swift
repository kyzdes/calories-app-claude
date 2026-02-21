import SwiftUI

struct ActivityLevelView: View {
    @Bindable var viewModel: OnboardingViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Уровень активности")
                .font(.cmH1)
                .foregroundStyle(Color.cmTextPrimary)
                .padding(.top, 8)

            ScrollView {
                VStack(spacing: 12) {
                    ForEach(ActivityLevel.allCases, id: \.self) { level in
                        ActivityCard(
                            level: level,
                            isSelected: viewModel.selectedActivityLevel == level,
                            action: { viewModel.selectedActivityLevel = level }
                        )
                    }
                }
            }
            .scrollIndicators(.hidden)

            PrimaryButton(
                title: "Далее",
                action: { viewModel.goNext() },
                isEnabled: viewModel.canProceedFromActivity
            )
            .padding(.bottom, 16)
        }
        .padding(.horizontal, 16)
    }
}

// MARK: - Activity Card

private struct ActivityCard: View {
    let level: ActivityLevel
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(level.displayName)
                        .font(.cmH3)
                        .foregroundStyle(Color.cmTextPrimary)

                    Text(level.description)
                        .font(.cmCallout)
                        .foregroundStyle(Color.cmTextSecondary)
                }

                Spacer()

                VStack(alignment: .trailing) {
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(Color.cmPrimary)
                    }

                    Spacer()

                    Text("\u{00D7}\u{00A0}\(String(format: "%.3g", level.multiplier))")
                        .font(.cmCaption)
                        .foregroundStyle(Color.cmTextTertiary)
                }
            }
            .padding(16)
            .background(isSelected ? Color.cmPrimaryLight : Color.cmBgSecondary)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? Color.cmPrimary : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: isSelected)
    }
}

#Preview {
    ActivityLevelView(viewModel: OnboardingViewModel())
}
