package com.yojnasetu.model;

import com.yojnasetu.model.enums.CasteType;
import com.yojnasetu.model.enums.GenderType;
import com.yojnasetu.model.enums.MaritalStatusType;
import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "user_profiles", schema = "yojna_setu")
public class UserProfile {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    @Column(name = "id", updatable = false, nullable = false)
    private UUID id;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", referencedColumnName = "id", unique = true, nullable = false)
    private User user;

    @Column(name = "age")
    private Integer age;

    @Enumerated(EnumType.STRING)
    @Column(name = "gender", length = 20)
    private GenderType gender;

    @Column(name = "state", length = 100)
    private String state;

    @Column(name = "district", length = 100)
    private String district;

    @Enumerated(EnumType.STRING)
    @Column(name = "caste", length = 20)
    private CasteType caste;

    @Column(name = "annual_income", precision = 15, scale = 2)
    private BigDecimal annualIncome;

    @Column(name = "occupation", length = 50)
    private String occupation;

    @Column(name = "religion", length = 50)
    private String religion = "ALL";

    @Enumerated(EnumType.STRING)
    @Column(name = "marital_status", length = 20)
    private MaritalStatusType maritalStatus = MaritalStatusType.ALL;

    @Column(name = "is_differently_abled", nullable = false)
    private boolean isDifferentlyAbled = false;

    @Column(name = "education_level", length = 50)
    private String educationLevel;

    @Column(name = "is_profile_complete", nullable = false)
    private boolean isProfileComplete = false;

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
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }

    public UserProfile() {
    }

    public UserProfile(User user) {
        this.user = user;
    }

    public boolean checkProfileComplete() {
        this.isProfileComplete = (age != null && gender != null && state != null &&
                caste != null && annualIncome != null && occupation != null);
        return this.isProfileComplete;
    }

    // Getters and Setters
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

    public Integer getAge() {
        return age;
    }

    public void setAge(Integer age) {
        this.age = age;
    }

    public GenderType getGenderType() {
        return gender;
    }

    public String getGender() {
        return gender != null ? gender.name() : null;
    }

    public void setGender(GenderType gender) {
        this.gender = gender;
    }

    public void setGender(Object genderObj) {
        if (genderObj == null) {
            this.gender = null;
        } else if (genderObj instanceof GenderType gt) {
            this.gender = gt;
        } else {
            this.gender = GenderType.fromString(genderObj.toString());
        }
    }

    public String getState() {
        return state;
    }

    public void setState(String state) {
        this.state = state;
    }

    public String getDistrict() {
        return district;
    }

    public void setDistrict(String district) {
        this.district = district;
    }

    public CasteType getCasteType() {
        return caste;
    }

    public String getCaste() {
        return caste != null ? caste.name() : null;
    }

    public void setCaste(CasteType caste) {
        this.caste = caste;
    }

    public void setCaste(Object casteObj) {
        if (casteObj == null) {
            this.caste = null;
        } else if (casteObj instanceof CasteType ct) {
            this.caste = ct;
        } else {
            this.caste = CasteType.fromString(casteObj.toString());
        }
    }

    public BigDecimal getAnnualIncome() {
        return annualIncome;
    }

    public void setAnnualIncome(BigDecimal annualIncome) {
        this.annualIncome = annualIncome;
    }

    // Legacy Number compatibility helper
    public Double getIncome() {
        return annualIncome != null ? annualIncome.doubleValue() : null;
    }

    public void setIncome(Number income) {
        this.annualIncome = income != null ? BigDecimal.valueOf(income.doubleValue()) : null;
    }

    public String getOccupation() {
        return occupation;
    }

    public void setOccupation(String occupation) {
        this.occupation = occupation;
    }

    public String getReligion() {
        return religion;
    }

    public void setReligion(String religion) {
        this.religion = religion;
    }

    public MaritalStatusType getMaritalStatus() {
        return maritalStatus;
    }

    public void setMaritalStatus(MaritalStatusType maritalStatus) {
        this.maritalStatus = maritalStatus;
    }

    // String compatibility helper
    public void setMaritalStatus(String maritalStatusStr) {
        this.maritalStatus = MaritalStatusType.fromString(maritalStatusStr);
    }

    public boolean isDifferentlyAbled() {
        return isDifferentlyAbled;
    }

    public void setDifferentlyAbled(boolean differentlyAbled) {
        isDifferentlyAbled = differentlyAbled;
    }

    public Boolean getIsDisabled() {
        return isDifferentlyAbled;
    }

    public void setIsDisabled(Boolean disabled) {
        this.isDifferentlyAbled = Boolean.TRUE.equals(disabled);
    }

    // Legacy String compatibility for disability
    public String getDisability() {
        return isDifferentlyAbled ? "YES" : "NO";
    }

    public void setDisability(String disabilityStr) {
        if (disabilityStr != null) {
            String lower = disabilityStr.trim().toLowerCase();
            this.isDifferentlyAbled = lower.equals("yes") || lower.equals("true") || lower.contains("disab");
        } else {
            this.isDifferentlyAbled = false;
        }
    }

    public String getEducationLevel() {
        return educationLevel;
    }

    public void setEducationLevel(String educationLevel) {
        this.educationLevel = educationLevel;
    }

    // Legacy compatibility helper
    public String getEducation() {
        return educationLevel;
    }

    public void setEducation(String education) {
        this.educationLevel = education;
    }

    public boolean isProfileComplete() {
        return isProfileComplete;
    }

    public void setProfileComplete(boolean profileComplete) {
        isProfileComplete = profileComplete;
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
