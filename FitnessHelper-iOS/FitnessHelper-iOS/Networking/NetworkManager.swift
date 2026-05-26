import Foundation

class NetworkManager {
    static let shared = NetworkManager()
    private let baseURL = "http://localhost:8080/api"
    
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        decoder.dateDecodingStrategy = .formatted(formatter)
        return decoder
    }()
    
    private let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        encoder.dateEncodingStrategy = .formatted(formatter)
        return encoder
    }()
    
    func fetchWorkouts() async throws -> [Workout] {
        guard let url = URL(string: "\(baseURL)/workouts") else { throw URLError(.badURL) }
        print("[DEBUG_LOG] Fetching workouts from: \(url)")
        let (data, response) = try await URLSession.shared.data(from: url)
        if let httpResponse = response as? HTTPURLResponse {
            print("[DEBUG_LOG] Fetch Workouts Status: \(httpResponse.statusCode)")
        }
        let workouts = try decoder.decode([Workout].self, from: data)
        print("[DEBUG_LOG] Decoded \(workouts.count) workouts")
        return workouts
    }
    
    func createWorkout(_ workout: Workout) async throws -> Workout {
        guard let url = URL(string: "\(baseURL)/workouts") else { throw URLError(.badURL) }
        print("[DEBUG_LOG] Creating workout at: \(url)")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try encoder.encode(workout)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        if let httpResponse = response as? HTTPURLResponse {
            print("[DEBUG_LOG] Create Workout Status: \(httpResponse.statusCode)")
        }
        let created = try decoder.decode(Workout.self, from: data)
        print("[DEBUG_LOG] Successfully created workout: \(created.name)")
        return created
    }
    
    func updateWorkout(_ workout: Workout) async throws -> Workout {
        guard let id = workout.id else { throw URLError(.badURL) }
        guard let url = URL(string: "\(baseURL)/workouts/\(id)") else { throw URLError(.badURL) }
        print("[DEBUG_LOG] Updating workout at: \(url)")
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try encoder.encode(workout)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        if let httpResponse = response as? HTTPURLResponse {
            print("[DEBUG_LOG] Update Workout Status: \(httpResponse.statusCode)")
        }
        let updated = try decoder.decode(Workout.self, from: data)
        print("[DEBUG_LOG] Successfully updated workout: \(updated.name)")
        return updated
    }
    
    func deleteWorkout(id: Long) async throws {
        guard let url = URL(string: "\(baseURL)/workouts/\(id)") else { throw URLError(.badURL) }
        print("[DEBUG_LOG] Deleting workout at: \(url)")
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        let (_, response) = try await URLSession.shared.data(for: request)
        if let httpResponse = response as? HTTPURLResponse {
            print("[DEBUG_LOG] Delete Workout Status: \(httpResponse.statusCode)")
            guard httpResponse.statusCode == 204 else { throw URLError(.badServerResponse) }
        }
    }
    
    func fetchDietEntries() async throws -> [DietEntry] {
        guard let url = URL(string: "\(baseURL)/diet") else { throw URLError(.badURL) }
        print("[DEBUG_LOG] Fetching diet entries from: \(url)")
        let (data, response) = try await URLSession.shared.data(from: url)
        if let httpResponse = response as? HTTPURLResponse {
            print("[DEBUG_LOG] Fetch Diet Status: \(httpResponse.statusCode)")
        }
        let entries = try decoder.decode([DietEntry].self, from: data)
        print("[DEBUG_LOG] Decoded \(entries.count) diet entries")
        return entries
    }
    
    func createDietEntry(_ entry: DietEntry) async throws -> DietEntry {
        guard let url = URL(string: "\(baseURL)/diet") else { throw URLError(.badURL) }
        print("[DEBUG_LOG] Creating diet entry at: \(url)")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try encoder.encode(entry)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        if let httpResponse = response as? HTTPURLResponse {
            print("[DEBUG_LOG] Create Diet Status: \(httpResponse.statusCode)")
        }
        let created = try decoder.decode(DietEntry.self, from: data)
        print("[DEBUG_LOG] Successfully created diet entry: \(created.foodName)")
        return created
    }
}
