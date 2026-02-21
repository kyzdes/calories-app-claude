import Foundation
import HealthKit

@Observable
final class HealthKitService {
    static let shared = HealthKitService()

    private let healthStore = HKHealthStore()

    var isAvailable: Bool {
        HKHealthStore.isHealthDataAvailable()
    }

    var isAuthorized = false

    // MARK: - Authorization

    /// Типы для чтения
    private var readTypes: Set<HKObjectType> {
        var types: Set<HKObjectType> = []
        if let bodyMass = HKObjectType.quantityType(forIdentifier: .bodyMass) {
            types.insert(bodyMass)
        }
        if let height = HKObjectType.quantityType(forIdentifier: .height) {
            types.insert(height)
        }
        if let sex = HKObjectType.characteristicType(forIdentifier: .biologicalSex) {
            types.insert(sex)
        }
        if let dob = HKObjectType.characteristicType(forIdentifier: .dateOfBirth) {
            types.insert(dob)
        }
        if let active = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned) {
            types.insert(active)
        }
        return types
    }

    /// Типы для записи
    private var writeTypes: Set<HKSampleType> {
        var types: Set<HKSampleType> = []
        if let bodyMass = HKObjectType.quantityType(forIdentifier: .bodyMass) {
            types.insert(bodyMass)
        }
        if let dietary = HKObjectType.quantityType(forIdentifier: .dietaryEnergyConsumed) {
            types.insert(dietary)
        }
        return types
    }

    /// Запросить разрешения HealthKit
    func requestAuthorization() async -> Bool {
        guard isAvailable else { return false }

        do {
            try await healthStore.requestAuthorization(toShare: writeTypes, read: readTypes)
            await MainActor.run {
                isAuthorized = true
            }
            return true
        } catch {
            return false
        }
    }

    // MARK: - Read Weight

    /// Прочитать последний вес из HealthKit
    func readLatestWeight() async -> Double? {
        guard isAvailable else { return nil }

        guard let weightType = HKQuantityType.quantityType(forIdentifier: .bodyMass) else {
            return nil
        }

        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let query = HKSampleQuery(
            sampleType: weightType,
            predicate: nil,
            limit: 1,
            sortDescriptors: [sortDescriptor]
        ) { _, _, _ in }

        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: weightType,
                predicate: nil,
                limit: 1,
                sortDescriptors: [sortDescriptor]
            ) { _, samples, _ in
                guard let sample = samples?.first as? HKQuantitySample else {
                    continuation.resume(returning: nil)
                    return
                }
                let kg = sample.quantity.doubleValue(for: .gramUnit(with: .kilo))
                continuation.resume(returning: kg)
            }
            healthStore.execute(query)
        }
    }

    // MARK: - Write Weight

    /// Записать вес в HealthKit
    func saveWeight(_ kg: Double, date: Date = Date()) async -> Bool {
        guard isAvailable else { return false }

        guard let weightType = HKQuantityType.quantityType(forIdentifier: .bodyMass) else {
            return false
        }

        let quantity = HKQuantity(unit: .gramUnit(with: .kilo), doubleValue: kg)
        let sample = HKQuantitySample(
            type: weightType,
            quantity: quantity,
            start: date,
            end: date
        )

        do {
            try await healthStore.save(sample)
            return true
        } catch {
            return false
        }
    }

    // MARK: - Write Calories

    /// Записать потреблённые калории в HealthKit
    func saveCalories(_ kcal: Double, date: Date = Date()) async -> Bool {
        guard isAvailable else { return false }

        guard let calorieType = HKQuantityType.quantityType(forIdentifier: .dietaryEnergyConsumed) else {
            return false
        }

        let quantity = HKQuantity(unit: .kilocalorie(), doubleValue: kcal)
        let sample = HKQuantitySample(
            type: calorieType,
            quantity: quantity,
            start: date,
            end: date
        )

        do {
            try await healthStore.save(sample)
            return true
        } catch {
            return false
        }
    }

    // MARK: - Read Height

    /// Прочитать рост из HealthKit
    func readHeight() async -> Double? {
        guard isAvailable else { return nil }

        guard let heightType = HKQuantityType.quantityType(forIdentifier: .height) else {
            return nil
        }

        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)

        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: heightType,
                predicate: nil,
                limit: 1,
                sortDescriptors: [sortDescriptor]
            ) { _, samples, _ in
                guard let sample = samples?.first as? HKQuantitySample else {
                    continuation.resume(returning: nil)
                    return
                }
                let cm = sample.quantity.doubleValue(for: .meterUnit(with: .centi))
                continuation.resume(returning: cm)
            }
            healthStore.execute(query)
        }
    }

    // MARK: - Read Biological Sex

    /// Прочитать пол из HealthKit
    func readBiologicalSex() -> Gender? {
        guard isAvailable else { return nil }

        do {
            let sex = try healthStore.biologicalSex().biologicalSex
            switch sex {
            case .male: return .male
            case .female: return .female
            default: return nil
            }
        } catch {
            return nil
        }
    }

    // MARK: - Read Date of Birth

    /// Прочитать возраст из HealthKit
    func readAge() -> Int? {
        guard isAvailable else { return nil }

        do {
            let components = try healthStore.dateOfBirthComponents()
            guard let year = components.year else { return nil }
            let currentYear = Calendar.current.component(.year, from: Date())
            let age = currentYear - year
            return (age >= 14 && age <= 100) ? age : nil
        } catch {
            return nil
        }
    }

    // MARK: - Sync Weight Entries

    /// Синхронизировать несинхронизированные записи веса в HealthKit
    func syncWeightEntries(_ entries: [WeightEntry]) async {
        for entry in entries where !entry.syncedToHealthKit {
            let success = await saveWeight(entry.weight, date: entry.date)
            if success {
                await MainActor.run {
                    entry.syncedToHealthKit = true
                }
            }
        }
    }
}
