import SwiftUI

struct SelectionCard: View {
    let icon: String
    let title: String
    let description: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundStyle(isSelected ? Color.cmPrimary : Color.cmTextSecondary)
                    .frame(width: 32)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.cmH3)
                        .foregroundStyle(Color.cmTextPrimary)

                    Text(description)
                        .font(.cmCallout)
                        .foregroundStyle(Color.cmTextSecondary)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(Color.cmPrimary)
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

// MARK: - Preview

#Preview {
    VStack(spacing: 12) {
        SelectionCard(
            icon: "arrow.down",
            title: "Похудеть",
            description: "Снизить вес и жировую массу",
            isSelected: true,
            action: {}
        )
        SelectionCard(
            icon: "arrow.up",
            title: "Набрать массу",
            description: "Увеличить мышечную массу",
            isSelected: false,
            action: {}
        )
    }
    .padding()
}
