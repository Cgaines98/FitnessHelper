import SwiftUI

struct MainTabView: View {
    @StateObject var viewModel = FitnessViewModel()
    
    var body: some View {
        TabView {
            WorkoutListView(viewModel: viewModel)
                .tabItem {
                    Label("Workouts", systemImage: "figure.run")
                }
            
            DietListView(viewModel: viewModel)
                .tabItem {
                    Label("Diet", systemImage: "fork.knife")
                }
        }
        .task {
            await viewModel.loadData()
        }
    }
}

struct WorkoutListView: View {
    @ObservedObject var viewModel: FitnessViewModel
    @State private var showingAddWorkout = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.workouts) { workout in
                    NavigationLink(destination: WorkoutDetailView(viewModel: viewModel, workout: workout)) {
                        VStack(alignment: .leading) {
                            Text(workout.name).font(.headline)
                            Text("\(workout.dateTime, style: .date)").font(.subheadline)
                            Text("\(workout.sets.count) sets").font(.caption)
                        }
                    }
                }
            }
            .navigationTitle("Workouts")
            .toolbar {
                Button(action: { showingAddWorkout = true }) {
                    Image(systemName: "plus")
                }
            }
            .sheet(isPresented: $showingAddWorkout) {
                AddWorkoutView(viewModel: viewModel)
            }
        }
    }
}

struct DietListView: View {
    @ObservedObject var viewModel: FitnessViewModel
    @State private var showingAddDiet = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.dietEntries) { entry in
                    VStack(alignment: .leading) {
                        Text(entry.foodName).font(.headline)
                        Text("\(Int(entry.calories)) kcal | P: \(Int(entry.protein))g C: \(Int(entry.carbs))g F: \(Int(entry.fat))g")
                            .font(.subheadline)
                    }
                }
            }
            .navigationTitle("Diet")
            .toolbar {
                Button(action: { showingAddDiet = true }) {
                    Image(systemName: "plus")
                }
            }
            .sheet(isPresented: $showingAddDiet) {
                AddDietEntryView(viewModel: viewModel)
            }
        }
    }
}

struct AddWorkoutView: View {
    @ObservedObject var viewModel: FitnessViewModel
    @Environment(\.dismiss) var dismiss
    @State private var name = ""
    @State private var sets: [WorkoutSet] = []
    @State private var exerciseName = ""
    @State private var reps = ""
    @State private var weight = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Workout Details")) {
                    TextField("Workout Name", text: $name)
                }
                
                Section(header: Text("Add Set")) {
                    TextField("Exercise Name", text: $exerciseName)
                    TextField("Reps", text: $reps)
                        .keyboardType(.numberPad)
                    TextField("Weight", text: $weight)
                        .keyboardType(.decimalPad)
                    
                    Button(action: addSet) {
                        Label("Add Set", systemImage: "plus.circle.fill")
                    }
                    .disabled(exerciseName.isEmpty || reps.isEmpty || weight.isEmpty)
                }
                
                if !sets.isEmpty {
                    Section(header: Text("Sets")) {
                        ForEach(sets.indices, id: \.self) { index in
                            HStack {
                                Text(sets[index].exerciseName)
                                Spacer()
                                Text("\(sets[index].reps) x \(String(format: "%.1f", sets[index].weight)) kg")
                                    .foregroundColor(.secondary)
                            }
                        }
                        .onDelete(perform: removeSet)
                    }
                }
            }
            .navigationTitle("New Workout")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            await viewModel.addWorkout(name: name, sets: sets)
                            dismiss()
                        }
                    }
                    .disabled(name.isEmpty)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
    
    private func addSet() {
        guard let repsInt = Int(reps), let weightDouble = Double(weight) else { return }
        let newSetNumber = sets.count + 1
        let newSet = WorkoutSet(id: nil, exerciseName: exerciseName, reps: repsInt, weight: weightDouble, setNumber: newSetNumber)
        sets.append(newSet)
        
        // Clear inputs for next set
        exerciseName = ""
        reps = ""
        weight = ""
    }
    
    private func removeSet(at offsets: IndexSet) {
        sets.remove(atOffsets: offsets)
    }
}

struct WorkoutDetailView: View {
    @ObservedObject var viewModel: FitnessViewModel
    let workout: Workout
    @Environment(\.dismiss) var dismiss
    @State private var showingEditWorkout = false
    @State private var showingDeleteAlert = false
    
    var body: some View {
        List {
            Section(header: Text("Details")) {
                HStack {
                    Text("Date")
                    Spacer()
                    Text(workout.dateTime, style: .date)
                }
                HStack {
                    Text("Time")
                    Spacer()
                    Text(workout.dateTime, style: .time)
                }
            }
            
            Section(header: Text("Sets")) {
                if workout.sets.isEmpty {
                    Text("No sets recorded")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(workout.sets) { set in
                        VStack(alignment: .leading) {
                            Text(set.exerciseName).font(.headline)
                            HStack {
                                Text("\(set.reps) reps")
                                Spacer()
                                Text("\(String(format: "%.1f", set.weight)) kg")
                            }
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        }
                    }
                }
            }
            
            Section {
                Button(role: .destructive, action: { showingDeleteAlert = true }) {
                    HStack {
                        Spacer()
                        Text("Delete Workout")
                        Spacer()
                    }
                }
            }
        }
        .navigationTitle(workout.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            Button("Edit") {
                showingEditWorkout = true
            }
        }
        .sheet(isPresented: $showingEditWorkout) {
            EditWorkoutView(viewModel: viewModel, workout: workout)
        }
        .alert("Delete Workout?", isPresented: $showingDeleteAlert) {
            Button("Delete", role: .destructive) {
                Task {
                    await viewModel.deleteWorkout(workout: workout)
                    dismiss()
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to delete this workout? This action cannot be undone.")
        }
    }
}

struct EditWorkoutView: View {
    @ObservedObject var viewModel: FitnessViewModel
    let workout: Workout
    @Environment(\.dismiss) var dismiss
    
    @State private var name: String
    @State private var dateTime: Date
    @State private var sets: [WorkoutSet]
    
    @State private var exerciseName = ""
    @State private var reps = ""
    @State private var weight = ""
    
    init(viewModel: FitnessViewModel, workout: Workout) {
        self.viewModel = viewModel
        self.workout = workout
        _name = State(initialValue: workout.name)
        _dateTime = State(initialValue: workout.dateTime)
        _sets = State(initialValue: workout.sets)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Workout Details")) {
                    TextField("Workout Name", text: $name)
                    DatePicker("Date", selection: $dateTime)
                }
                
                Section(header: Text("Add Set")) {
                    TextField("Exercise Name", text: $exerciseName)
                    TextField("Reps", text: $reps)
                        .keyboardType(.numberPad)
                    TextField("Weight", text: $weight)
                        .keyboardType(.decimalPad)
                    
                    Button(action: addSet) {
                        Label("Add Set", systemImage: "plus.circle.fill")
                    }
                    .disabled(exerciseName.isEmpty || reps.isEmpty || weight.isEmpty)
                }
                
                if !sets.isEmpty {
                    Section(header: Text("Sets")) {
                        ForEach(sets.indices, id: \.self) { index in
                            HStack {
                                Text(sets[index].exerciseName)
                                Spacer()
                                Text("\(sets[index].reps) x \(String(format: "%.1f", sets[index].weight)) kg")
                                    .foregroundColor(.secondary)
                            }
                        }
                        .onDelete(perform: removeSet)
                    }
                }
            }
            .navigationTitle("Edit Workout")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            if let id = workout.id {
                                await viewModel.updateWorkout(id: id, name: name, dateTime: dateTime, sets: sets)
                            }
                            dismiss()
                        }
                    }
                    .disabled(name.isEmpty)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
    
    private func addSet() {
        guard let repsInt = Int(reps), let weightDouble = Double(weight) else { return }
        let newSetNumber = (sets.map { $0.setNumber ?? 0 }.max() ?? 0) + 1
        let newSet = WorkoutSet(id: nil, exerciseName: exerciseName, reps: repsInt, weight: weightDouble, setNumber: newSetNumber)
        sets.append(newSet)
        
        exerciseName = ""
        reps = ""
        weight = ""
    }
    
    private func removeSet(at offsets: IndexSet) {
        sets.remove(atOffsets: offsets)
    }
}

struct AddDietEntryView: View {
    @ObservedObject var viewModel: FitnessViewModel
    @Environment(\.dismiss) var dismiss
    @State private var foodName = ""
    @State private var calories = ""
    @State private var protein = ""
    @State private var carbs = ""
    @State private var fat = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Food Info")) {
                    TextField("Food Name", text: $foodName)
                    TextField("Calories", text: $calories)
                        .keyboardType(.numberPad)
                }
                
                Section(header: Text("Macros (optional)")) {
                    TextField("Protein (g)", text: $protein)
                        .keyboardType(.decimalPad)
                    TextField("Carbs (g)", text: $carbs)
                        .keyboardType(.decimalPad)
                    TextField("Fat (g)", text: $fat)
                        .keyboardType(.decimalPad)
                }
            }
            .navigationTitle("New Diet Entry")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            await viewModel.addDietEntry(
                                foodName: foodName,
                                calories: Double(calories) ?? 0,
                                protein: Double(protein) ?? 0,
                                carbs: Double(carbs) ?? 0,
                                fat: Double(fat) ?? 0
                            )
                            dismiss()
                        }
                    }
                    .disabled(foodName.isEmpty || calories.isEmpty)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
