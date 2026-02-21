import SwiftUI

struct PeriodPicker: View {
    @Binding var selected: ProgressViewModel.TimePeriod

    var body: some View {
        HStack(spacing: 0) {
            ForEach(ProgressViewModel.TimePeriod.allCases, id: \.self) { period in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selected = period
                    }
                } label: {
                    Text(period.rawValue)
                        .font(.cmCaption)
                        .foregroundStyle(selected == period ? .white : Color.cmTextPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(selected == period ? Color.cmPrimary : Color.cmBgTertiary)
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
