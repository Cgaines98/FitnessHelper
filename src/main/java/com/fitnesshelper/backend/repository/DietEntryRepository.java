package com.fitnesshelper.backend.repository;

import com.fitnesshelper.backend.model.DietEntry;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface DietEntryRepository extends JpaRepository<DietEntry, Long> {
}
