package com.yojnasetu.repository;

import com.yojnasetu.model.User;
import com.yojnasetu.model.UserProfile;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface UserProfileRepository extends JpaRepository<UserProfile, UUID> {
    Optional<UserProfile> findByUserId(UUID userId);
    Optional<UserProfile> findByUser(User user);

    @org.springframework.data.jpa.repository.Query("SELECT p FROM UserProfile p WHERE p.user.phoneNumberE164 = :phoneNumber")
    Optional<UserProfile> findByUserPhoneNumber(@org.springframework.data.repository.query.Param("phoneNumber") String phoneNumber);
}
