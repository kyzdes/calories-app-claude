import SwiftUI

struct EmptyStateView: View {
    let icon: String
    let title: String
    let description: String
    var buttonTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundStyle(Color.cmTextTertiary)

            VStack(spacing: 8) {
                Text(title)
                    .font(.cmH3)
                    .foregroundStyle(Color.cmTextPrimary)

                Text(description)
                    .font(.cmCallout)
                    .foregroundStyle(Color.cmTextSecondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }

            if let buttonTitle, let action {
                PrimaryButton(title: buttonTitle, action: action)
                    .padding(.top, 8)
            }
        }
        .padding(.horizontal, 32)
        .padding(.top, 40)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Preview

#Preview {
    EmptyStateView(
        icon: "fork.knife",
        title: "Пока пусто",
        description: "Добавьте свой первый приём пищи",
        buttonTitle: "Добавить",
        action: {}
    )
}
