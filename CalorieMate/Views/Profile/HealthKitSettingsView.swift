import SwiftUI
import SwiftData

struct HealthKitSettingsView: View {
    @Query private var profiles: [UserProfile]
    @Query(sort: \WeightEntry.date) private var weightEntries: [WeightEntry]
    @State private var healthKit = HealthKitService.shared
    @State private var isSyncing = false
    @State private var syncMessage: String?

    private var profile: UserProfile? { profiles.first }

    var body: some View {
        List {
            statusSection
            actionsSection
            infoSection
        }
        .listStyle(.insetGrouped)
        .background(Color.cmBgPrimary)
        .scrollContentBackground(.hidden)
        .navigationTitle("Apple Health")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Status

    private var statusSection: some View {
        Section {
            HStack {
                Image(systemName: "heart.fill")
                    .foregroundStyle(.red)
                    .font(.system(size: 20))

                VStack(alignment: .leading, spacing: 2) {
                    Text("Apple Health")
                        .font(.cmBodyBold)
                        .foregroundStyle(Color.cmTextPrimary)

                    Text(healthKit.isAvailable
                        ? (healthKit.isAuthorized ? "Подключено" : "Не подключено")
                        : "Недоступно на этом устройстве")
                        .font(.cmCaption)
                        .foregroundStyle(healthKit.isAuthorized ? Color.cmSuccess : Color.cmTextTertiary)
                }

                Spacer()

                if !healthKit.isAuthorized && healthKit.isAvailable {
                    Button("Подключить") {
                        Task {
                            let success = await healthKit.requestAuthorization()
                            if success, let profile {
                                profile.healthKitEnabled = true
                            }
                        }
                    }
                    .font(.cmBodyBold)
                    .foregroundStyle(Color.cmPrimary)
                }
            }
        } header: {
            Text("Статус")
        }
    }

    // MARK: - Actions

    private var actionsSection: some View {
        Section {
            // Sync weight
            Button {
                syncWeight()
            } label: {
                HStack {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .foregroundStyle(Color.cmPrimary)
                    Text("Синхронизировать вес")
                        .foregroundStyle(Color.cmTextPrimary)
                    Spacer()
                    if isSyncing {
                        ProgressView()
                    }
                }
            }
            .disabled(!healthKit.isAuthorized || isSyncing)

            // Import from Health
            Button {
                importFromHealth()
            } label: {
                HStack {
                    Image(systemName: "square.and.arrow.down")
                        .foregroundStyle(Color.cmPrimary)
                    Text("Импорт данных из Health")
                        .foregroundStyle(Color.cmTextPrimary)
                }
            }
            .disabled(!healthKit.isAuthorized)

            if let syncMessage {
                Text(syncMessage)
                    .font(.cmCaption)
                    .foregroundStyle(Color.cmTextSecondary)
            }
        } header: {
            Text("Действия")
        }
    }

    // MARK: - Info

    private var infoSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 8) {
                dataRow("Вес", read: true, write: true)
                dataRow("Рост", read: true, write: false)
                dataRow("Пол", read: true, write: false)
                dataRow("Дата рождения", read: true, write: false)
                dataRow("Калории (потребл.)", read: false, write: true)
            }
        } header: {
            Text("Типы данных")
        } footer: {
            Text("CalorieMate запрашивает только необходимые разрешения. Вы можете управлять доступом в Настройки → Здоровье.")
        }
    }

    private func dataRow(_ label: String, read: Bool, write: Bool) -> some View {
        HStack {
            Text(label)
                .font(.cmBody)
                .foregroundStyle(Color.cmTextPrimary)
            Spacer()
            if read {
                Text("Чтение")
                    .font(.cmCaption)
                    .foregroundStyle(Color.cmTextSecondary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.cmBgTertiary)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            }
            if write {
                Text("Запись")
                    .font(.cmCaption)
                    .foregroundStyle(Color.cmPrimary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.cmPrimaryLight)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            }
        }
    }

    // MARK: - Sync Logic

    private func syncWeight() {
        isSyncing = true
        syncMessage = nil
        let unsyncedEntries = weightEntries.filter { !$0.syncedToHealthKit }

        Task {
            await healthKit.syncWeightEntries(unsyncedEntries)

            await MainActor.run {
                isSyncing = false
                let count = unsyncedEntries.count
                if count > 0 {
                    syncMessage = "Синхронизировано записей: \(count)"
                } else {
                    syncMessage = "Все записи уже синхронизированы"
                }
            }
        }
    }

    private func importFromHealth() {
        Task {
            // Import weight
            if let weight = await healthKit.readLatestWeight() {
                await MainActor.run {
                    syncMessage = "Последний вес из Health: \(String(format: "%.1f", weight)) кг"
                }
            }

            // Import height
            if let height = await healthKit.readHeight(), let profile {
                await MainActor.run {
                    profile.height = Int(height.rounded())
                }
            }

            // Import gender
            if let gender = healthKit.readBiologicalSex(), let profile {
                await MainActor.run {
                    profile.gender = gender
                }
            }

            // Import age
            if let age = healthKit.readAge(), let profile {
                await MainActor.run {
                    profile.age = age
                }
            }
        }
    }
}
