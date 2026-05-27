package com.yojnasetu.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotNull;
import java.time.LocalDate;

@Entity
@Table(name = "schemes")
public class Scheme {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotNull
    @Column(name = "name", unique = true, nullable = false)
    private String name;

    @Column(name = "ministry")
    private String ministry;

    @Column(name = "description", length = 1000)
    private String description;

    @Column(name = "min_age")
    private Integer minAge;

    @Column(name = "max_age")
    private Integer maxAge;

    @Column(name = "max_income")
    private Long maxIncome;

    @Column(name = "eligible_gender", columnDefinition = "VARCHAR(255) DEFAULT 'ALL'")
    private String eligibleGender = "ALL";

    @Column(name = "eligible_castes", columnDefinition = "VARCHAR(255)")
    private String eligibleCastes;

    @Column(name = "eligible_states", columnDefinition = "VARCHAR(255) DEFAULT 'ALL'")
    private String eligibleStates = "ALL";

    @Column(name = "eligible_occupations", columnDefinition = "VARCHAR(255) DEFAULT 'ALL'")
    private String eligibleOccupations = "ALL";

    @Column(name = "eligible_religions", columnDefinition = "VARCHAR(255) DEFAULT 'ALL'")
    private String eligibleReligions = "ALL";

    @Column(name = "deadline_alert", columnDefinition = "BOOLEAN DEFAULT false")
    private Boolean deadlineAlert = false;

    @Column(name = "apply_url")
    private String applyUrl;

    @Column(name = "is_active", columnDefinition = "BOOLEAN DEFAULT true")
    private Boolean isActive = true;

    @Column(name = "start_date")
    private LocalDate startDate;

    @Column(name = "end_date")
    private LocalDate endDate;

    @Column(name = "required_documents", length = 1000)
    private String requiredDocuments;

    @Column(name = "benefits", length = 1000)
    private String benefits;

    @Column(name = "application_mode")
    private String applicationMode;

    @Column(name = "application_process", length = 1000)
    private String applicationProcess;

    @PrePersist
    protected void onCreate() {
        if (eligibleGender == null) {
            eligibleGender = "ALL";
        }
        if (eligibleStates == null) {
            eligibleStates = "ALL";
        }
        if (eligibleOccupations == null) {
            eligibleOccupations = "ALL";
        }
        if (eligibleReligions == null) {
            eligibleReligions = "ALL";
        }
        if (isActive == null) {
            isActive = true;
        }
        if (deadlineAlert == null) {
            deadlineAlert = false;
        }
    }

    // Default constructor
    public Scheme() {
    }

    // Constructor with fields
    public Scheme(String name, String ministry, String description, Integer minAge, Integer maxAge, Long maxIncome, 
                  String eligibleGender, String eligibleCastes, String eligibleStates, String eligibleOccupations, 
                  String applyUrl, Boolean isActive) {
        this.name = name;
        this.ministry = ministry;
        this.description = description;
        this.minAge = minAge;
        this.maxAge = maxAge;
        this.maxIncome = maxIncome;
        this.eligibleGender = eligibleGender != null ? eligibleGender : "ALL";
        this.eligibleCastes = eligibleCastes;
        this.eligibleStates = eligibleStates != null ? eligibleStates : "ALL";
        this.eligibleOccupations = eligibleOccupations != null ? eligibleOccupations : "ALL";
        this.applyUrl = applyUrl;
        this.isActive = isActive != null ? isActive : true;
    }

    // Getters and Setters
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getMinistry() {
        return ministry;
    }

    public void setMinistry(String ministry) {
        this.ministry = ministry;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public Integer getMinAge() {
        return minAge;
    }

    public void setMinAge(Integer minAge) {
        this.minAge = minAge;
    }

    public Integer getMaxAge() {
        return maxAge;
    }

    public void setMaxAge(Integer maxAge) {
        this.maxAge = maxAge;
    }

    public Long getMaxIncome() {
        return maxIncome;
    }

    public void setMaxIncome(Long maxIncome) {
        this.maxIncome = maxIncome;
    }

    public String getEligibleGender() {
        return eligibleGender;
    }

    public void setEligibleGender(String eligibleGender) {
        this.eligibleGender = eligibleGender;
    }

    public String getEligibleCastes() {
        return eligibleCastes;
    }

    public void setEligibleCastes(String eligibleCastes) {
        this.eligibleCastes = eligibleCastes;
    }

    public String getEligibleStates() {
        return eligibleStates;
    }

    public void setEligibleStates(String eligibleStates) {
        this.eligibleStates = eligibleStates;
    }

    public String getEligibleOccupations() {
        return eligibleOccupations;
    }

    public void setEligibleOccupations(String eligibleOccupations) {
        this.eligibleOccupations = eligibleOccupations;
    }

    public String getApplyUrl() {
        return applyUrl;
    }

    public void setApplyUrl(String applyUrl) {
        this.applyUrl = applyUrl;
    }

    public Boolean getIsActive() {
        return isActive;
    }

    public void setIsActive(Boolean isActive) {
        this.isActive = isActive;
    }

    public LocalDate getStartDate() {
        return startDate;
    }

    public void setStartDate(LocalDate startDate) {
        this.startDate = startDate;
    }

    public LocalDate getEndDate() {
        return endDate;
    }

    public void setEndDate(LocalDate endDate) {
        this.endDate = endDate;
    }

    public String getRequiredDocuments() {
        return requiredDocuments;
    }

    public void setRequiredDocuments(String requiredDocuments) {
        this.requiredDocuments = requiredDocuments;
    }

    public String getBenefits() {
        return benefits;
    }

    public void setBenefits(String benefits) {
        this.benefits = benefits;
    }

    public String getApplicationMode() {
        return applicationMode;
    }

    public void setApplicationMode(String applicationMode) {
        this.applicationMode = applicationMode;
    }

    public String getApplicationProcess() {
        return applicationProcess;
    }

    public void setApplicationProcess(String applicationProcess) {
        this.applicationProcess = applicationProcess;
    }

    public String getEligibleReligions() {
        return eligibleReligions;
    }

    public void setEligibleReligions(String eligibleReligions) {
        this.eligibleReligions = eligibleReligions != null ? eligibleReligions : "ALL";
    }

    public Boolean getDeadlineAlert() {
        return deadlineAlert;
    }

    public void setDeadlineAlert(Boolean deadlineAlert) {
        this.deadlineAlert = deadlineAlert != null ? deadlineAlert : false;
    }
}
