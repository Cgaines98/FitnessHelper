import SwiftUI

@MainActor
class FitnessViewModel: ObservableObject {
    @Published var workouts: [Workout] = []
    @Published var dietEntries: [DietEntry] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func loadData() async {
        isLoading = true
        errorMessage = nil
        do {
            async let fetchedWorkouts = NetworkManager.shared.fetchWorkouts()
            async let fetchedDiet = NetworkManager.shared.fetchDietEntries()
            
            self.workouts = try await fetchedWorkouts
            self.dietEntries = try await fetchedDiet
            print("[DEBUG_LOG] ViewModel loaded \(workouts.count) workouts and \(dietEntries.count) diet entries")
        } catch {
            print("[DEBUG_LOG] Error loading data: \(error)")
            errorMessage = "Failed to load data: \(error.localizedDescription)"
        }
        isLoading = false
    }
    
    func addWorkout(name: String, sets: [WorkoutSet]) async {
        let newWorkout = Workout(id: nil, name: name, dateTime: Date(), notes: nil, sets: sets)
        do {
            let created = try await NetworkManager.shared.createWorkout(newWorkout)
            print("[DEBUG_LOG] Successfully added workout: \(created.name) with \(created.sets.count) sets")
            self.workouts.append(created)
        } catch {
            print("[DEBUG_LOG] Error adding workout: \(error)")
            errorMessage = "Failed to add workout: \(error.localizedDescription)"
        }
    }
    
    func updateWorkout(id: Long, name: String, dateTime: Date, sets: [WorkoutSet]) async {
        let updatedWorkout = Workout(id: id, name: name, dateTime: dateTime, notes: nil, sets: sets)
        do {
            let updated = try await NetworkManager.shared.updateWorkout(updatedWorkout)
            if let index = self.workouts.firstIndex(where: { $0.id == id }) {
                self.workouts[index] = updated
            }
            print("[DEBUG_LOG] Successfully updated workout: \(updated.name)")
        } catch {
            print("[DEBUG_LOG] Error updating workout: \(error)")
            errorMessage = "Failed to update workout: \(error.localizedDescription)"
        }
    }
    
    func deleteWorkout(workout: Workout) async {
        guard let id = workout.id else { return }
        do {
            try await NetworkManager.shared.deleteWorkout(id: id)
            self.workouts.removeAll(where: { $0.id == id })
            print("[DEBUG_LOG] Successfully deleted workout: \(workout.name)")
        } catch {
            print("[DEBUG_LOG] Error deleting workout: \(error)")
            errorMessage = "Failed to delete workout: \(error.localizedDescription)"
        }
    }
    
    func addDietEntry(foodName: String, calories: Double, protein: Double, carbs: Double, fat: Double) async {
        let newEntry = DietEntry(id: nil, foodName: foodName, calories: calories, protein: protein, carbs: carbs, fat: fat, dateTime: Date())
        do {
            let created = try await NetworkManager.shared.createDietEntry(newEntry)
            print("[DEBUG_LOG] Successfully added diet entry: \(created.foodName)")
            self.dietEntries.append(created)
        } catch {
            print("[DEBUG_LOG] Error adding diet entry: \(error)")
            errorMessage = "Failed to add diet entry: \(error.localizedDescription)"
        }
    }
}
