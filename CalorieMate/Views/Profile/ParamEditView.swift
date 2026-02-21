import SwiftUI

struct ParamEditView: View {
    let title: String
    @Binding var value: String
    let unit: String
    let keyboard: UIKeyboardType
    let range: String
    let onSave: () -> Void
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isFocused: Bool

    private var isValid: Bool {
        guard let val = Int(value) else { return false }
        return val > 0
    }

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            VStack(spacing: 8) {
                TextField("", text: $value)
                    .font(.cmHero)
                    .foregroundStyle(Color.cmTextPrimary)
                    .keyboardType(keyboard)
                    .multilineTextAlignment(.center)
                    .focused($isFocused)

                Text(unit)
                    .font(.cmCallout)
                    .foregroundStyle(Color.cmTextSecondary)

                Text("Допустимый диапазон: \(range)")
                    .font(.cmCaption)
                    .foregroundStyle(Color.cmTextTertiary)
            }

            Spacer()

            PrimaryButton(title: "Сохранить", isEnabled: isValid) {
                onSave()
                dismiss()
            }
        }
        .padding(16)
        .background(Color.cmBgPrimary)
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            isFocused = true
        }
    }
}
