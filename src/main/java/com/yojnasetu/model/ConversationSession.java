package com.yojnasetu.model;

import com.yojnasetu.model.enums.SessionStateType;
import jakarta.persistence.*;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "conversation_sessions", schema = "yojna_setu")
public class ConversationSession {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private UUID id;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", referencedColumnName = "id", unique = true, nullable = false)
    private User user;

    @Enumerated(EnumType.STRING)
    @Column(name = "current_state", nullable = false, length = 50)
    private SessionStateType currentState = SessionStateType.INIT;

    @Column(name = "last_prompt_sent", length = 100)
    private String lastPromptSent;

    @Column(name = "pagination_offset", nullable = false)
    private int paginationOffset = 0;

    @Column(name = "cached_eligible_schemes", columnDefinition = "TEXT")
    private String cachedEligibleSchemes;

    @Column(name = "session_data", columnDefinition = "TEXT")
    private String sessionData;

    @Column(name = "last_interaction_at", nullable = false)
    private LocalDateTime lastInteractionAt;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        if (createdAt == null) createdAt = LocalDateTime.now();
        if (lastInteractionAt == null) lastInteractionAt = LocalDateTime.now();
    }

    @PreUpdate
    protected void onUpdate() {
        lastInteractionAt = LocalDateTime.now();
    }

    public ConversationSession() {
    }

    public ConversationSession(User user) {
        this.user = user;
        this.currentState = SessionStateType.INIT;
    }

    public UUID getId() {
        return id;
    }

    public void setId(UUID id) {
        this.id = id;
    }

    public User getUser() {
        return user;
    }

    public void setUser(User user) {
        this.user = user;
    }

    public SessionStateType getCurrentState() {
        return currentState;
    }

    public void setCurrentState(SessionStateType currentState) {
        this.currentState = currentState;
    }

    public String getLastPromptSent() {
        return lastPromptSent;
    }

    public void setLastPromptSent(String lastPromptSent) {
        this.lastPromptSent = lastPromptSent;
    }

    public int getPaginationOffset() {
        return paginationOffset;
    }

    public void setPaginationOffset(int paginationOffset) {
        this.paginationOffset = paginationOffset;
    }

    public String getCachedEligibleSchemes() {
        return cachedEligibleSchemes;
    }

    public void setCachedEligibleSchemes(String cachedEligibleSchemes) {
        this.cachedEligibleSchemes = cachedEligibleSchemes;
    }

    public String getSessionData() {
        return sessionData;
    }

    public void setSessionData(String sessionData) {
        this.sessionData = sessionData;
    }

    public LocalDateTime getLastInteractionAt() {
        return lastInteractionAt;
    }

    public void setLastInteractionAt(LocalDateTime lastInteractionAt) {
        this.lastInteractionAt = lastInteractionAt;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }
}
