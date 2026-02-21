import SwiftUI

struct UndoToast: View {
    let message: String
    let onUndo: () -> Void

    var body: some View {
        HStack {
            Text(message)
                .font(.cmBody)
                .foregroundStyle(.white)

            Spacer()

            Button(action: onUndo) {
                Text("Отменить")
                    .font(.cmBodyBold)
                    .foregroundStyle(.white)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.cmTextPrimary.opacity(0.9))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, 16)
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
}

#Preview {
    VStack {
        Spacer()
        UndoToast(message: "Удалено", onUndo: {})
    }
}
