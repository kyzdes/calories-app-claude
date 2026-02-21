import SwiftUI

struct PortionStepper: View {
    @Binding var portionText: String
    let presets: [Int]

    private var selectedPreset: Int? {
        guard let value = Int(portionText) else { return nil }
        return presets.contains(value) ? value : nil
    }

    var body: some View {
        VStack(spacing: 16) {
            // Preset chips
            HStack(spacing: 8) {
                ForEach(presets, id: \.self) { grams in
                    Button {
                        portionText = "\(grams)"
                    } label: {
                        Text("\(grams)\u{00A0}г")
                            .font(.cmCallout)
                            .foregroundStyle(selectedPreset == grams ? .white : Color.cmTextPrimary)
                            .padding(.horizontal, 12)
                            .frame(height: 36)
                            .background(selectedPreset == grams ? Color.cmPrimary : Color.cmBgTertiary)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .sensoryFeedback(.selection, trigger: selectedPreset)
                }
            }

            // Free input
            HStack {
                TextField("", text: $portionText)
                    .font(.cmNumberLg)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.center)

                Text("г")
                    .font(.cmBody)
                    .foregroundStyle(Color.cmTextTertiary)
            }
            .padding(.horizontal, 16)
            .frame(height: 56)
            .background(Color.cmBgTertiary)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

#Preview {
    PortionStepper(
        portionText: .constant("150"),
        presets: [50, 100, 150, 200]
    )
    .padding()
}
