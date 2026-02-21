import SwiftUI
import SwiftData

struct ProfileView: View {
    @Query private var profiles: [UserProfile]
    @Query(sort: \FoodEntry.date) private var foodEntries: [FoodEntry]
    @Query(sort: \WeightEntry.date) private var weightEntries: [WeightEntry]
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = ProfileViewModel()
    @State private var showShareSheet = false
    @State private var csvURL: URL?

    private var profile: UserProfile? { profiles.first }

    var body: some View {
        NavigationStack {
            List {
                if let profile {
                    goalSection(profile)
                    parametersSection(profile)
                    dataSection
                    aboutSection
                }
            }
            .listStyle(.insetGrouped)
            .background(Color.cmBgPrimary)
            .scrollContentBackground(.hidden)
            .navigationTitle("Профиль")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                if let profile {
                    viewModel.prefill(from: profile)
                }
            }
            .alert("Сбросить все данные?", isPresented: $viewModel.showResetConfirmation) {
                Button("Сбросить", role: .destructive) {
                    viewModel.resetAllData(context: modelContext)
                }
                Button("Отмена", role: .cancel) {}
            } message: {
                Text("Это действие удалит все ваши данные безвозвратно: дневник питания, вес, замеры и профиль.")
            }
            .sheet(isPresented: $showShareSheet) {
                if let csvURL {
                    ShareSheet(items: [csvURL])
                }
            }
        }
    }

    // MARK: - Goal & Norm Section

    private func goalSection(_ profile: UserProfile) -> some View {
        Section {
            NavigationLink {
                GoalEditView(viewModel: viewModel, profile: profile, weightEntries: weightEntries)
            } label: {
                profileRow("Цель", value: profile.goal.displayName)
            }

            NavigationLink {
                CalorieGoalEditView(viewModel: viewModel, profile: profile)
            } label: {
                profileRow("Дневная норма", value: "\(profile.dailyCalorieGoal.formattedCaloriesValue)\u{00A0}ккал")
            }

            NavigationLink {
                MacroDistributionView(viewModel: viewModel, profile: profile)
            } label: {
                let p = Int(profile.proteinRatio * 100)
                let f = Int(profile.fatRatio * 100)
                let c = Int(profile.carbsRatio * 100)
                profileRow("Распределение БЖУ", value: "\(p)/\(f)/\(c)\u{00A0}%")
            }
        } header: {
            Text("Цель и норма")
        }
    }

    // MARK: - Parameters Section

    private func parametersSection(_ profile: UserProfile) -> some View {
        Section {
            NavigationLink {
                ParamEditView(
                    title: "Возраст",
                    value: $viewModel.editAge,
                    unit: "лет",
                    keyboard: .numberPad,
                    range: "14–100"
                ) {
                    viewModel.saveAge(profile, weightEntries: weightEntries)
                }
            } label: {
                profileRow("Возраст", value: "\(profile.age) лет")
            }

            NavigationLink {
                ParamEditView(
                    title: "Рост",
                    value: $viewModel.editHeight,
                    unit: "см",
                    keyboard: .numberPad,
                    range: "100–250"
                ) {
                    viewModel.saveHeight(profile, weightEntries: weightEntries)
                }
            } label: {
                profileRow("Рост", value: "\(profile.height) см")
            }

            NavigationLink {
                GenderEditView(viewModel: viewModel, profile: profile, weightEntries: weightEntries)
            } label: {
                profileRow("Пол", value: profile.gender.displayName)
            }

            NavigationLink {
                ActivityEditView(viewModel: viewModel, profile: profile, weightEntries: weightEntries)
            } label: {
                profileRow("Активность", value: profile.activityLevel.displayName)
            }
        } header: {
            Text("Параметры")
        }
    }

    // MARK: - Data Section

    private var dataSection: some View {
        Section {
            Button {
                if let url = viewModel.exportCSV(
                    foodEntries: foodEntries,
                    weightEntries: weightEntries,
                    profile: profile
                ) {
                    csvURL = url
                    showShareSheet = true
                }
            } label: {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundStyle(Color.cmPrimary)
                    Text("Экспорт данных (CSV)")
                        .foregroundStyle(Color.cmTextPrimary)
                }
            }

            Button {
                viewModel.showResetConfirmation = true
            } label: {
                HStack {
                    Image(systemName: "trash")
                        .foregroundStyle(Color.cmDanger)
                    Text("Сбросить все данные")
                        .foregroundStyle(Color.cmDanger)
                }
            }
        } header: {
            Text("Данные")
        }
    }

    // MARK: - About Section

    private var aboutSection: some View {
        Section {
            HStack {
                Text("Версия")
                    .foregroundStyle(Color.cmTextPrimary)
                Spacer()
                Text("1.0.0")
                    .foregroundStyle(Color.cmTextSecondary)
            }
        } header: {
            Text("О приложении")
        }
    }

    // MARK: - Row Helper

    private func profileRow(_ label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.cmBody)
                .foregroundStyle(Color.cmTextPrimary)
            Spacer()
            Text(value)
                .font(.cmBody)
                .foregroundStyle(Color.cmTextSecondary)
        }
    }
}

// MARK: - Share Sheet (UIKit wrapper)

private struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    ProfileView()
        .modelContainer(for: [
            Product.self, FoodEntry.self, WeightEntry.self,
            BodyMeasurement.self, UserProfile.self
        ], inMemory: true)
}
