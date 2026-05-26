package com.fitnesshelper.backend.model;

import com.fasterxml.jackson.annotation.JsonBackReference;
import jakarta.persistence.*;

@Entity
@Table(name = "workout_sets")
public class WorkoutSet {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String exerciseName;
    private Integer reps;
    private Double weight;
    private Integer setNumber;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "workout_id")
    @JsonBackReference
    private Workout workout;

    public WorkoutSet() {}

    public WorkoutSet(Long id, String exerciseName, Integer reps, Double weight, Integer setNumber, Workout workout) {
        this.id = id;
        this.exerciseName = exerciseName;
        this.reps = reps;
        this.weight = weight;
        this.setNumber = setNumber;
        this.workout = workout;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getExerciseName() { return exerciseName; }
    public void setExerciseName(String exerciseName) { this.exerciseName = exerciseName; }

    public Integer getReps() { return reps; }
    public void setReps(Integer reps) { this.reps = reps; }

    public Double getWeight() { return weight; }
    public void setWeight(Double weight) { this.weight = weight; }

    public Integer getSetNumber() { return setNumber; }
    public void setSetNumber(Integer setNumber) { this.setNumber = setNumber; }

    public Workout getWorkout() { return workout; }
    public void setWorkout(Workout workout) { this.workout = workout; }
}
