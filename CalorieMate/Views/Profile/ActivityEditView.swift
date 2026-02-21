import SwiftUI

struct ActivityEditView: View {
    @Bindable var viewModel: ProfileViewModel
    let profile: UserProfile
    let weightEntries: [WeightEntry]
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 12) {
            ForEach(ActivityLevel.allCases, id: \.self) { level in
                Button {
                    viewModel.editActivityLevel = level
                } label: {
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(level.displayName)
                                .font(.cmH3)
                                .foregroundStyle(Color.cmTextPrimary)

                            Text(level.description)
                                .font(.cmCaption)
                                .foregroundStyle(Color.cmTextSecondary)
                        }

                        Spacer()

                        Text("×\(String(format: "%.2f", level.multiplier))")
                            .font(.cmNumberSm)
                            .foregroundStyle(Color.cmTextTertiary)

                        if viewModel.editActivityLevel == level {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(Color.cmPrimary)
                                .font(.system(size: 22))
                        }
                    }
                    .padding(16)
                    .background(
                        viewModel.editActivityLevel == level
                            ? Color.cmPrimaryLight
                            : Color.cmBgSecondary
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                viewModel.editActivityLevel == level
                                    ? Color.cmPrimary
                                    : Color.clear,
                                lineWidth: 2
                            )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .sensoryFeedback(.selection, trigger: viewModel.editActivityLevel)
            }

            Spacer()

            PrimaryButton(title: "Сохранить") {
                viewModel.saveActivity(profile, weightEntries: weightEntries)
                dismiss()
            }
        }
        .padding(16)
        .background(Color.cmBgPrimary)
        .navigationTitle("Уровень активности")
        .navigationBarTitleDisplayMode(.inline)
    }
}
