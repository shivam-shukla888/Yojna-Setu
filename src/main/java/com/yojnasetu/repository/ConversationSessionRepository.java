package com.yojnasetu.repository;

import com.yojnasetu.model.ConversationSession;
import com.yojnasetu.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface ConversationSessionRepository extends JpaRepository<ConversationSession, UUID> {
    Optional<ConversationSession> findByUserId(UUID userId);
    Optional<ConversationSession> findByUser(User user);
}
