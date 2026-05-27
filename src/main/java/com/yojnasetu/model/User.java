package com.yojnasetu.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotNull;
import java.time.LocalDateTime;

@Entity
@Table(name = "users")
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotNull
    @Column(name = "phone_number", unique = true, nullable = false)
    private String phoneNumber;

    @Column(name = "name")
    private String name;

    @Column(name = "language_pref", columnDefinition = "VARCHAR(255) DEFAULT 'hi'")
    private String languagePref = "hi";

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        if (createdAt == null) {
            createdAt = LocalDateTime.now();
        }
        if (languagePref == null) {
            languagePref = "hi";
        }
    }

    // Default constructor
    public User() {
    }

    // Constructor with fields
    public User(String phoneNumber, String name) {
        this.phoneNumber = phoneNumber;
        this.name = name;
        this.languagePref = "hi";
    }

    // Full constructor
    public User(Long id, String phoneNumber, String name, String languagePref, LocalDateTime createdAt) {
        this.id = id;
        this.phoneNumber = phoneNumber;
        this.name = name;
        this.languagePref = languagePref;
        this.createdAt = createdAt;
    }

    // Getters and Setters
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getPhoneNumber() {
        return phoneNumber;
    }

    public void setPhoneNumber(String phoneNumber) {
        this.phoneNumber = phoneNumber;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getLanguagePref() {
        return languagePref;
    }

    public void setLanguagePref(String languagePref) {
        this.languagePref = languagePref;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }
}
