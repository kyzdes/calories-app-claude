import SwiftUI

struct WelcomeView: View {
    let onStart: () -> Void

    var body: some View {
        VStack {
            Spacer()

            VStack(spacing: 12) {
                Text("CalorieMate")
                    .font(.cmH1)
                    .foregroundStyle(Color.cmPrimary)

                Text("Простой контроль калорий\nбез лишних функций")
                    .font(.cmBody)
                    .foregroundStyle(Color.cmTextSecondary)
                    .multilineTextAlignment(.center)
            }

            Spacer()

            PrimaryButton(title: "Начать", action: onStart)
                .padding(.bottom, 32)
        }
        .padding(.horizontal, 16)
    }
}

#Preview {
    WelcomeView(onStart: {})
}
