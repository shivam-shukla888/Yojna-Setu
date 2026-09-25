package com.yojnasetu.repository;

import com.yojnasetu.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface UserRepository extends JpaRepository<User, UUID> {
    Optional<User> findByPhoneNumberHash(String phoneNumberHash);
    Optional<User> findByPhoneNumberE164(String phoneNumberE164);

    // Compatibility method
    default Optional<User> findByPhoneNumber(String phoneNumber) {
        return findByPhoneNumberE164(phoneNumber);
    }
}
