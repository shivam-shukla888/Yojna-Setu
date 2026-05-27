package com.yojnasetu.repository;

import com.yojnasetu.model.Scheme;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import java.time.LocalDate;
import java.util.List;

@Repository
public interface SchemeRepository extends JpaRepository<Scheme, Long> {
    List<Scheme> findByIsActiveTrue();

    @Query("SELECT s FROM Scheme s WHERE s.isActive = :isActive AND (s.endDate >= :date OR s.endDate IS NULL)")
    List<Scheme> findByIsActiveAndEndDateAfterOrEndDateIsNull(@Param("isActive") Boolean isActive, @Param("date") LocalDate date);
}
