import Foundation
import SwiftData

@Model
final class WeightEntry {
    var id: UUID
    var date: Date
    var weight: Double
    var syncedToHealthKit: Bool

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        weight: Double,
        syncedToHealthKit: Bool = false
    ) {
        self.id = id
        self.date = date
        self.weight = weight
        self.syncedToHealthKit = syncedToHealthKit
    }
}
