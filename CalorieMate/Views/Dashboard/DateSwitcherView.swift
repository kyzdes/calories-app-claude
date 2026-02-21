import SwiftUI

struct DateSwitcherView: View {
    @Binding var selectedDate: Date
    let canGoForward: Bool
    let onPrevious: () -> Void
    let onNext: () -> Void

    var body: some View {
        HStack {
            Button(action: onPrevious) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18))
                    .foregroundStyle(Color.cmPrimary)
            }

            Spacer()

            Text(selectedDate.displayString)
                .font(.cmH2)
                .foregroundStyle(Color.cmTextPrimary)

            Spacer()

            Button(action: onNext) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 18))
                    .foregroundStyle(canGoForward ? Color.cmPrimary : Color.clear)
            }
            .disabled(!canGoForward)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}

#Preview {
    DateSwitcherView(
        selectedDate: .constant(Date()),
        canGoForward: false,
        onPrevious: {},
        onNext: {}
    )
}
