package com.yojnasetu.repository;

import com.yojnasetu.model.Scheme;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface SchemeRepository extends JpaRepository<Scheme, UUID> {

    Optional<Scheme> findByCode(String code);

    List<Scheme> findByIsActiveTrue();

    Page<Scheme> findByIsActiveTrue(Pageable pageable);

    @org.springframework.data.jpa.repository.Query("SELECT s FROM Scheme s WHERE s.isActive = :isActive AND (s.endDate IS NULL OR s.endDate >= :date)")
    List<Scheme> findByIsActiveAndEndDateAfterOrEndDateIsNull(
            @org.springframework.data.repository.query.Param("isActive") boolean isActive,
            @org.springframework.data.repository.query.Param("date") java.time.LocalDate date);

    // Compatibility methods for existing services
    default List<Scheme> findByIsActive(Boolean isActive) {
        return findByIsActiveTrue();
    }

    default List<Scheme> findByApplicableStatesContaining(String state) {
        return findByIsActiveTrue();
    }
}
