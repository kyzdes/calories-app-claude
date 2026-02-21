import Foundation
import SwiftData

@Model
final class BodyMeasurement {
    var id: UUID
    var date: Date
    var waist: Double?
    var hips: Double?
    var chest: Double?
    var biceps: Double?
    var photoPath: String?

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        waist: Double? = nil,
        hips: Double? = nil,
        chest: Double? = nil,
        biceps: Double? = nil,
        photoPath: String? = nil
    ) {
        self.id = id
        self.date = date
        self.waist = waist
        self.hips = hips
        self.chest = chest
        self.biceps = biceps
        self.photoPath = photoPath
    }
}
