package com.fitnesshelper.backend.controller;

import com.fitnesshelper.backend.model.DietEntry;
import com.fitnesshelper.backend.repository.DietEntryRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/diet")
public class DietEntryController {

    private final DietEntryRepository dietEntryRepository;

    public DietEntryController(DietEntryRepository dietEntryRepository) {
        this.dietEntryRepository = dietEntryRepository;
    }

    @GetMapping
    public List<DietEntry> getAllDietEntries() {
        return dietEntryRepository.findAll();
    }

    @PostMapping
    public DietEntry createDietEntry(@RequestBody DietEntry dietEntry) {
        return dietEntryRepository.save(dietEntry);
    }

    @GetMapping("/{id}")
    public ResponseEntity<DietEntry> getDietEntryById(@PathVariable Long id) {
        return dietEntryRepository.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteDietEntry(@PathVariable Long id) {
        return dietEntryRepository.findById(id)
                .map(entry -> {
                    dietEntryRepository.delete(entry);
                    return ResponseEntity.noContent().<Void>build();
                })
                .orElse(ResponseEntity.notFound().build());
    }

    @PutMapping("/{id}")
    public ResponseEntity<DietEntry> updateDietEntry(@PathVariable Long id, @RequestBody DietEntry details) {
        return dietEntryRepository.findById(id)
                .map(entry -> {
                    entry.setFoodName(details.getFoodName());
                    entry.setCalories(details.getCalories());
                    entry.setProtein(details.getProtein());
                    entry.setCarbs(details.getCarbs());
                    entry.setFat(details.getFat());
                    entry.setDateTime(details.getDateTime());
                    entry.setAmount(details.getAmount());
                    entry.setUnit(details.getUnit());
                    return ResponseEntity.ok(dietEntryRepository.save(entry));
                })
                .orElse(ResponseEntity.notFound().build());
    }
}
