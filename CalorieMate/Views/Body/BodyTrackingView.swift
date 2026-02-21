import SwiftUI
import SwiftData

struct BodyTrackingView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \WeightEntry.date) private var weightEntries: [WeightEntry]
    @Query(sort: \BodyMeasurement.date) private var measurements: [BodyMeasurement]
    @Query private var profiles: [UserProfile]
    @State private var viewModel = BodyTrackingViewModel()

    private var profile: UserProfile? { profiles.first }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Current weight card
                    weightCard

                    // Weight chart
                    WeightChartView(
                        entries: viewModel.filteredWeightEntries(weightEntries),
                        goalWeight: profile?.targetWeight
                    )
                    .padding(.horizontal, 16)

                    // Period picker
                    periodPicker
                        .padding(.horizontal, 16)

                    // Body measurements
                    measurementsSection
                }
                .padding(.bottom, 100)
            }
            .background(Color.cmBgPrimary)
            .navigationTitle("Тело")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $viewModel.showWeightSheet) {
                WeightInputSheet(viewModel: viewModel)
                    .presentationDetents([.medium])
                    .onAppear {
                        viewModel.prefillWeight(from: weightEntries)
                    }
            }
            .sheet(isPresented: $viewModel.showMeasurementsSheet) {
                MeasurementsInputSheet(viewModel: viewModel)
                    .presentationDetents([.medium])
                    .onAppear {
                        viewModel.prefillMeasurements(from: measurements)
                    }
            }
        }
    }

    // MARK: - Weight Card

    private var weightCard: some View {
        VStack(spacing: 12) {
            Text("Текущий вес")
                .font(.cmCallout)
                .foregroundStyle(Color.cmTextSecondary)

            if let latest = viewModel.latestWeight(from: weightEntries) {
                Text(latest.weight.formattedWeightValue)
                    .font(.cmHero)
                    .foregroundStyle(Color.cmTextPrimary)
                + Text("\u{00A0}кг")
                    .font(.cmH2)
                    .foregroundStyle(Color.cmTextSecondary)
            } else {
                Text("—")
                    .font(.cmHero)
                    .foregroundStyle(Color.cmTextTertiary)
            }

            if let delta = viewModel.weightDelta(from: weightEntries) {
                let isPositive = delta.value > 0
                let isGood = (profile?.goal == .lose && !isPositive) || (profile?.goal == .gain && isPositive)
                HStack(spacing: 4) {
                    Image(systemName: isPositive ? "arrow.up" : "arrow.down")
                        .font(.cmCaption)
                    Text("\(String(format: "%.1f", abs(delta.value)))\u{00A0}кг за \(delta.days) дн.")
                        .font(.cmCallout)
                }
                .foregroundStyle(isGood ? Color.cmSuccess : Color.cmDanger)
            }

            if let target = profile?.targetWeight {
                Text("Цель: \(target.formattedWeight)")
                    .font(.cmCaption)
                    .foregroundStyle(Color.cmTextTertiary)
            }

            PrimaryButton(title: "Записать вес") {
                viewModel.showWeightSheet = true
            }
            .padding(.horizontal, 16)
        }
        .padding(20)
        .background(Color.cmBgSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .padding(.horizontal, 16)
        .sensoryFeedback(.success, trigger: viewModel.showWeightSheet) { old, new in
            old && !new
        }
    }

    // MARK: - Period Picker

    private var periodPicker: some View {
        HStack(spacing: 0) {
            ForEach(BodyTrackingViewModel.TimePeriod.allCases, id: \.self) { period in
                Button {
                    viewModel.selectedPeriod = period
                } label: {
                    Text(period.rawValue)
                        .font(.cmCaption)
                        .foregroundStyle(viewModel.selectedPeriod == period ? .white : Color.cmTextPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(viewModel.selectedPeriod == period ? Color.cmPrimary : Color.cmBgTertiary)
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    // MARK: - Measurements Section

    private var measurementsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Замеры тела")
                .font(.cmH3)
                .foregroundStyle(Color.cmTextPrimary)
                .padding(.horizontal, 16)

            if let latest = viewModel.latestMeasurement(from: measurements) {
                VStack(spacing: 0) {
                    if let waist = latest.waist {
                        measurementRow("Талия", value: "\(Int(waist))\u{00A0}см", date: latest.date)
                    }
                    if let hips = latest.hips {
                        measurementRow("Бёдра", value: "\(Int(hips))\u{00A0}см", date: latest.date)
                    }
                    if let chest = latest.chest {
                        measurementRow("Грудь", value: "\(Int(chest))\u{00A0}см", date: latest.date)
                    }
                    if let biceps = latest.biceps {
                        measurementRow("Бицепс", value: "\(Int(biceps))\u{00A0}см", date: latest.date)
                    }
                }
                .padding(.horizontal, 16)
            }

            Button {
                viewModel.showMeasurementsSheet = true
            } label: {
                Text("+ Записать замеры")
                    .font(.cmBody)
                    .foregroundStyle(Color.cmPrimary)
                    .frame(maxWidth: .infinity)
            }
            .padding(.top, 8)
        }
    }

    @ViewBuilder
    private func measurementRow(_ label: String, value: String, date: Date) -> some View {
        HStack {
            Text(label)
                .font(.cmBody)
                .foregroundStyle(Color.cmTextPrimary)
            Spacer()
            Text(value)
                .font(.cmBodyBold)
                .foregroundStyle(Color.cmTextPrimary)

            let formatter = DateFormatter()
            let _ = formatter.dateFormat = "d MMM"
            let _ = formatter.locale = Locale(identifier: "ru_RU")
            Text(formatter.string(from: date))
                .font(.cmCaption)
                .foregroundStyle(Color.cmTextTertiary)
                .frame(width: 60, alignment: .trailing)
        }
        .padding(.vertical, 10)
    }
}

#Preview {
    BodyTrackingView()
        .modelContainer(for: [
            Product.self, FoodEntry.self, WeightEntry.self,
            BodyMeasurement.self, UserProfile.self
        ], inMemory: true)
}
