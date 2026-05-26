import Foundation

struct Workout: Identifiable, Codable {
    var id: Long?
    var name: String
    var dateTime: Date
    var notes: String?
    var sets: [WorkoutSet]
    
    enum CodingKeys: String, CodingKey {
        case id, name, sets, notes
        case dateTime = "dateTime"
    }
}

struct WorkoutSet: Identifiable, Codable {
    var id: Long?
    var exerciseName: String
    var reps: Int
    var weight: Double
    var setNumber: Int?
}

struct DietEntry: Identifiable, Codable {
    var id: Long?
    var foodName: String
    var calories: Double
    var protein: Double
    var carbs: Double
    var fat: Double
    var dateTime: Date

    enum CodingKeys: String, CodingKey {
        case id, foodName, calories, protein, carbs, fat
        case dateTime = "dateTime"
    }
}

typealias Long = Int64
