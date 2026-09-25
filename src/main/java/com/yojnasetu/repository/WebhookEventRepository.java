package com.yojnasetu.repository;

import com.yojnasetu.model.WebhookEvent;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface WebhookEventRepository extends JpaRepository<WebhookEvent, UUID> {
    boolean existsByProviderMessageId(String providerMessageId);
    Optional<WebhookEvent> findByProviderMessageId(String providerMessageId);
}
