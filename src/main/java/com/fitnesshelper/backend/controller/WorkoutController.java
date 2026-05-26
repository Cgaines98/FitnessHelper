package com.fitnesshelper.backend.controller;

import com.fitnesshelper.backend.model.Workout;
import com.fitnesshelper.backend.repository.WorkoutRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/workouts")
public class WorkoutController {

    private final WorkoutRepository workoutRepository;

    public WorkoutController(WorkoutRepository workoutRepository) {
        this.workoutRepository = workoutRepository;
    }

    @GetMapping
    public List<Workout> getAllWorkouts() {
        return workoutRepository.findAll();
    }

    @PostMapping
    public Workout createWorkout(@RequestBody Workout workout) {
        if (workout.getSets() != null) {
            workout.getSets().forEach(set -> set.setWorkout(workout));
        }
        return workoutRepository.save(workout);
    }

    @GetMapping("/{id}")
    public ResponseEntity<Workout> getWorkoutById(@PathVariable Long id) {
        return workoutRepository.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteWorkout(@PathVariable Long id) {
        return workoutRepository.findById(id)
                .map(workout -> {
                    workoutRepository.delete(workout);
                    return ResponseEntity.noContent().<Void>build();
                })
                .orElse(ResponseEntity.notFound().build());
    }

    @PutMapping("/{id}")
    public ResponseEntity<Workout> updateWorkout(@PathVariable Long id, @RequestBody Workout workoutDetails) {
        return workoutRepository.findById(id)
                .map(workout -> {
                    workout.setName(workoutDetails.getName());
                    workout.setNotes(workoutDetails.getNotes());
                    workout.setDateTime(workoutDetails.getDateTime());
                    
                    // Handle sets: clear and re-add to maintain relationship
                    workout.getSets().clear();
                    if (workoutDetails.getSets() != null) {
                        workoutDetails.getSets().forEach(set -> {
                            set.setWorkout(workout);
                            workout.getSets().add(set);
                        });
                    }
                    
                    Workout updated = workoutRepository.save(workout);
                    return ResponseEntity.ok(updated);
                })
                .orElse(ResponseEntity.notFound().build());
    }
}
