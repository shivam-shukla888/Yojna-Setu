package com.yojnasetu.model;

import com.yojnasetu.model.enums.ApplicationModeType;
import com.yojnasetu.model.enums.CasteType;
import com.yojnasetu.model.enums.GenderType;
import com.yojnasetu.model.enums.SchemeCategoryType;
import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;

@Entity
@Table(name = "schemes", schema = "yojna_setu")
public class Scheme {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    @Column(name = "id", updatable = false, nullable = false)
    private UUID id;

    @Column(name = "code", unique = true, nullable = false, length = 100)
    private String code;

    @Column(name = "name", nullable = false)
    private String name;

    @Column(name = "ministry", nullable = false)
    private String ministry;

    @Enumerated(EnumType.STRING)
    @Column(name = "category", nullable = false)
    private SchemeCategoryType category = SchemeCategoryType.CENTRAL_GOVERNMENT;

    @Column(name = "short_description", columnDefinition = "TEXT", nullable = false)
    private String shortDescription;

    @Column(name = "benefits", columnDefinition = "TEXT", nullable = false)
    private String benefits;

    @Enumerated(EnumType.STRING)
    @Column(name = "application_mode", nullable = false)
    private ApplicationModeType applicationMode = ApplicationModeType.BOTH;

    @Column(name = "application_process", columnDefinition = "TEXT")
    private String applicationProcess;

    @Column(name = "official_url", length = 500)
    private String officialUrl;

    @Column(name = "min_age", nullable = false)
    private Integer minAge = 0;

    @Column(name = "max_age", nullable = false)
    private Integer maxAge = 130;

    @Column(name = "max_income", precision = 15, scale = 2)
    private BigDecimal maxIncome;

    @Column(name = "requires_disability", nullable = false)
    private boolean requiresDisability = false;

    @Column(name = "target_state", nullable = false, length = 100)
    private String targetState = "ALL";

    @Column(name = "start_date")
    private LocalDate startDate;

    @Column(name = "end_date")
    private LocalDate endDate;

    @Column(name = "is_active", nullable = false)
    private boolean isActive = true;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;

    @ElementCollection(fetch = FetchType.EAGER)
    @CollectionTable(name = "scheme_castes", schema = "yojna_setu", joinColumns = @JoinColumn(name = "scheme_id"))
    @Enumerated(EnumType.STRING)
    @Column(name = "caste")
    private Set<CasteType> applicableCastes = new HashSet<>();

    @ElementCollection(fetch = FetchType.EAGER)
    @CollectionTable(name = "scheme_genders", schema = "yojna_setu", joinColumns = @JoinColumn(name = "scheme_id"))
    @Enumerated(EnumType.STRING)
    @Column(name = "gender")
    private Set<GenderType> applicableGenders = new HashSet<>();

    @ElementCollection(fetch = FetchType.EAGER)
    @CollectionTable(name = "scheme_occupations", schema = "yojna_setu", joinColumns = @JoinColumn(name = "scheme_id"))
    @Column(name = "occupation")
    private Set<String> applicableOccupations = new HashSet<>();

    @ElementCollection(fetch = FetchType.LAZY)
    @CollectionTable(name = "scheme_religions", schema = "yojna_setu", joinColumns = @JoinColumn(name = "scheme_id"))
    @Column(name = "religion")
    private Set<String> applicableReligions = new HashSet<>();

    @OneToMany(mappedBy = "scheme", cascade = CascadeType.ALL, orphanRemoval = true, fetch = FetchType.LAZY)
    private List<SchemeDocument> documents;

    @PrePersist
    protected void onCreate() {
        if (createdAt == null) createdAt = LocalDateTime.now();
        if (updatedAt == null) updatedAt = LocalDateTime.now();
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }

    public Scheme() {
    }

    /**
     * Accurate deterministic eligibility verification fixing legacy substring bugs.
     */
    public boolean isEligible(UserProfile profile) {
        if (profile == null) return false;

        // 1. Age Check
        if (profile.getAge() != null) {
            int age = profile.getAge();
            if (minAge != null && age < minAge) return false;
            if (maxAge != null && age > maxAge) return false;
        }

        // 2. Gender Check (Fixed: exact enum match or ALL, no "FEMALE".contains("MALE") bug)
        if (profile.getGender() != null && applicableGenders != null && !applicableGenders.isEmpty()) {
            boolean hasAll = applicableGenders.contains(GenderType.ALL);
            boolean matches = applicableGenders.contains(profile.getGender());
            if (!hasAll && !matches) return false;
        }

        // 3. Caste Check
        if (profile.getCaste() != null && applicableCastes != null && !applicableCastes.isEmpty()) {
            boolean hasAll = applicableCastes.contains(CasteType.ALL);
            boolean matches = applicableCastes.contains(profile.getCaste());
            if (!hasAll && !matches) return false;
        }

        // 4. Income Check
        if (maxIncome != null && profile.getAnnualIncome() != null) {
            if (profile.getAnnualIncome().compareTo(maxIncome) > 0) return false;
        }

        // 5. State Check
        if (targetState != null && !"ALL".equalsIgnoreCase(targetState)) {
            if (profile.getState() == null || !targetState.equalsIgnoreCase(profile.getState().trim())) {
                return false;
            }
        }

        // 6. Disability Check
        if (requiresDisability && !profile.isDifferentlyAbled()) {
            return false;
        }

        // 7. Occupation Check
        if (applicableOccupations != null && !applicableOccupations.isEmpty() && profile.getOccupation() != null) {
            boolean hasAll = applicableOccupations.contains("ALL");
            boolean matches = applicableOccupations.stream()
                    .anyMatch(occ -> occ.equalsIgnoreCase(profile.getOccupation().trim()));
            if (!hasAll && !matches) return false;
        }

        return true;
    }

    // Getters and Setters
    public UUID getId() {
        return id;
    }

    public void setId(UUID id) {
        this.id = id;
    }

    public String getCode() {
        return code;
    }

    public void setCode(String code) {
        this.code = code;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    // Legacy getter alias
    public String getSchemeName() {
        return name;
    }

    public void setSchemeName(String schemeName) {
        this.name = schemeName;
    }

    public String getMinistry() {
        return ministry;
    }

    public void setMinistry(String ministry) {
        this.ministry = ministry;
    }

    public SchemeCategoryType getCategory() {
        return category;
    }

    public void setCategory(SchemeCategoryType category) {
        this.category = category;
    }

    public String getShortDescription() {
        return shortDescription;
    }

    public void setShortDescription(String shortDescription) {
        this.shortDescription = shortDescription;
    }

    // Legacy getter alias
    public String getDescription() {
        return shortDescription;
    }

    public void setDescription(String description) {
        this.shortDescription = description;
    }

    public String getBenefits() {
        return benefits;
    }

    public void setBenefits(String benefits) {
        this.benefits = benefits;
    }

    public ApplicationModeType getApplicationModeType() {
        return applicationMode;
    }

    public String getApplicationMode() {
        return applicationMode != null ? applicationMode.name() : "BOTH";
    }

    public void setApplicationMode(ApplicationModeType applicationMode) {
        this.applicationMode = applicationMode;
    }

    public void setApplicationMode(String mode) {
        if (mode != null) {
            try {
                this.applicationMode = ApplicationModeType.valueOf(mode.toUpperCase().trim());
            } catch (Exception e) {
                this.applicationMode = ApplicationModeType.BOTH;
            }
        }
    }

    public String getEligibleGender() {
        if (applicableGenders == null || applicableGenders.isEmpty()) return "ALL";
        return applicableGenders.stream().map(Enum::name).collect(Collectors.joining(","));
    }

    public String getEligibleCastes() {
        if (applicableCastes == null || applicableCastes.isEmpty()) return "ALL";
        return applicableCastes.stream().map(Enum::name).collect(Collectors.joining(","));
    }

    public String getEligibleOccupations() {
        if (applicableOccupations == null || applicableOccupations.isEmpty()) return "ALL";
        return String.join(",", applicableOccupations);
    }

    public String getEligibleReligions() {
        if (applicableReligions == null || applicableReligions.isEmpty()) return "ALL";
        return String.join(",", applicableReligions);
    }

    public String getEligibleStates() {
        return targetState != null ? targetState : "ALL";
    }

    public String getApplicationProcess() {
        return applicationProcess;
    }

    public void setApplicationProcess(String applicationProcess) {
        this.applicationProcess = applicationProcess;
    }

    public String getOfficialUrl() {
        return officialUrl;
    }

    public void setOfficialUrl(String officialUrl) {
        this.officialUrl = officialUrl;
    }

    // Legacy getter alias
    public String getApplyUrl() {
        return officialUrl;
    }

    public void setApplyUrl(String applyUrl) {
        this.officialUrl = applyUrl;
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

    public BigDecimal getMaxIncomeAmount() {
        return maxIncome;
    }

    public Double getMaxIncome() {
        return maxIncome != null ? maxIncome.doubleValue() : null;
    }

    public void setMaxIncome(BigDecimal maxIncome) {
        this.maxIncome = maxIncome;
    }

    public void setMaxIncome(Double maxIncome) {
        this.maxIncome = maxIncome != null ? BigDecimal.valueOf(maxIncome) : null;
    }

    public boolean isRequiresDisability() {
        return requiresDisability;
    }

    public void setRequiresDisability(boolean requiresDisability) {
        this.requiresDisability = requiresDisability;
    }

    public String getTargetState() {
        return targetState;
    }

    public void setTargetState(String targetState) {
        this.targetState = targetState;
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

    public boolean isActive() {
        return isActive;
    }

    public void setActive(boolean active) {
        isActive = active;
    }

    public Set<CasteType> getApplicableCastes() {
        return applicableCastes;
    }

    public void setApplicableCastes(Set<CasteType> applicableCastes) {
        this.applicableCastes = applicableCastes;
    }

    public Set<GenderType> getApplicableGenders() {
        return applicableGenders;
    }

    public void setApplicableGenders(Set<GenderType> applicableGenders) {
        this.applicableGenders = applicableGenders;
    }

    public Set<String> getApplicableOccupations() {
        return applicableOccupations;
    }

    public void setApplicableOccupations(Set<String> applicableOccupations) {
        this.applicableOccupations = applicableOccupations;
    }

    public Set<String> getApplicableReligions() {
        return applicableReligions;
    }

    public void setApplicableReligions(Set<String> applicableReligions) {
        this.applicableReligions = applicableReligions;
    }

    public List<SchemeDocument> getDocuments() {
        return documents;
    }

    public void setDocuments(List<SchemeDocument> documents) {
        this.documents = documents;
    }

    // Legacy getter alias returning comma-separated documents
    public String getRequiredDocuments() {
        if (documents == null || documents.isEmpty()) return "Aadhaar Card";
        return documents.stream().map(SchemeDocument::getDocumentName).collect(Collectors.joining(", "));
    }
}
