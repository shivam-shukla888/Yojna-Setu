package com.yojnasetu.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotNull;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "users", schema = "yojna_setu")
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    @Column(name = "id", updatable = false, nullable = false)
    private UUID id;

    @NotNull
    @Column(name = "phone_number_e164", nullable = false, length = 20)
    private String phoneNumberE164;

    @NotNull
    @Column(name = "phone_number_hash", unique = true, nullable = false, length = 64)
    private String phoneNumberHash;

    @Column(name = "name")
    private String name;

    @Column(name = "preferred_language", length = 10)
    private String preferredLanguage = "en";

    @Column(name = "is_active", nullable = false)
    private boolean isActive = true;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;

    @PrePersist
    protected void onCreate() {
        if (createdAt == null) {
            createdAt = LocalDateTime.now();
        }
        if (updatedAt == null) {
            updatedAt = LocalDateTime.now();
        }
        if (preferredLanguage == null) {
            preferredLanguage = "en";
        }
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }

    public User() {
    }

    public User(String phoneNumberE164, String phoneNumberHash, String preferredLanguage) {
        this.phoneNumberE164 = phoneNumberE164;
        this.phoneNumberHash = phoneNumberHash;
        this.preferredLanguage = preferredLanguage != null ? preferredLanguage : "en";
        this.isActive = true;
    }

    // Backward-compatible constructor
    public User(String phoneNumberE164, String name) {
        this.phoneNumberE164 = phoneNumberE164;
        this.preferredLanguage = "hi";
        this.isActive = true;
    }

    // Getters and Setters
    public UUID getId() {
        return id;
    }

    public void setId(UUID id) {
        this.id = id;
    }

    public String getPhoneNumberE164() {
        return phoneNumberE164;
    }

    public void setPhoneNumberE164(String phoneNumberE164) {
        this.phoneNumberE164 = phoneNumberE164;
    }

    // Backward compatibility helper
    public String getPhoneNumber() {
        return phoneNumberE164;
    }

    public void setPhoneNumber(String phoneNumber) {
        this.phoneNumberE164 = phoneNumber;
    }

    public String getPhoneNumberHash() {
        return phoneNumberHash;
    }

    public void setPhoneNumberHash(String phoneNumberHash) {
        this.phoneNumberHash = phoneNumberHash;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getPreferredLanguage() {
        return preferredLanguage;
    }

    public void setPreferredLanguage(String preferredLanguage) {
        this.preferredLanguage = preferredLanguage;
    }

    // Backward compatibility helper
    public String getLanguagePref() {
        return preferredLanguage;
    }

    public void setLanguagePref(String languagePref) {
        this.preferredLanguage = languagePref;
    }

    public boolean isActive() {
        return isActive;
    }

    public void setActive(boolean active) {
        isActive = active;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }
}
