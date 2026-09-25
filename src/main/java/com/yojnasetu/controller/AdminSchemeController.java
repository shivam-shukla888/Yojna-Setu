package com.yojnasetu.controller;

import com.yojnasetu.common.api.ApiResponse;
import com.yojnasetu.controller.dto.CreateSchemeRequest;
import com.yojnasetu.model.AuditEvent;
import com.yojnasetu.model.Scheme;
import com.yojnasetu.model.enums.ApplicationModeType;
import com.yojnasetu.model.enums.SchemeCategoryType;
import com.yojnasetu.repository.AuditEventRepository;
import com.yojnasetu.repository.SchemeRepository;
import jakarta.validation.Valid;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/admin")
public class AdminSchemeController {

    private static final Logger log = LoggerFactory.getLogger(AdminSchemeController.class);

    private final SchemeRepository schemeRepository;
    private final AuditEventRepository auditEventRepository;

    public AdminSchemeController(SchemeRepository schemeRepository,
                                 AuditEventRepository auditEventRepository) {
        this.schemeRepository = schemeRepository;
        this.auditEventRepository = auditEventRepository;
    }

    @GetMapping("/schemes")
    public ResponseEntity<ApiResponse<Page<Scheme>>> getAllSchemes(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @RequestParam(defaultValue = "name") String sortBy) {

        PageRequest pageRequest = PageRequest.of(page, size, Sort.by(sortBy).ascending());
        Page<Scheme> schemes = schemeRepository.findAll(pageRequest);
        return ResponseEntity.ok(ApiResponse.success("Schemes retrieved successfully", schemes));
    }

    @GetMapping("/schemes/{id}")
    public ResponseEntity<ApiResponse<Scheme>> getSchemeById(@PathVariable UUID id) {
        return schemeRepository.findById(id)
                .map(scheme -> ResponseEntity.ok(ApiResponse.success("Scheme retrieved successfully", scheme)))
                .orElseGet(() -> ResponseEntity.status(HttpStatus.NOT_FOUND)
                        .body(ApiResponse.failure("NOT_FOUND", "Scheme not found with ID: " + id)));
    }

    @PostMapping("/schemes")
    @Transactional
    public ResponseEntity<ApiResponse<Scheme>> createScheme(@Valid @RequestBody CreateSchemeRequest request) {
        log.info("Admin creating new scheme with code: {}", request.code());

        if (schemeRepository.findByCode(request.code()).isPresent()) {
            return ResponseEntity.status(HttpStatus.CONFLICT)
                    .body(ApiResponse.failure("DUPLICATE_CODE", "Scheme with code " + request.code() + " already exists"));
        }

        Scheme scheme = new Scheme();
        populateSchemeFromRequest(scheme, request);
        scheme.setActive(true);

        Scheme saved = schemeRepository.save(scheme);

        auditEventRepository.save(new AuditEvent(
                "ADMIN",
                "CREATE_SCHEME",
                "SCHEME",
                saved.getId().toString(),
                "Created scheme: " + saved.getCode() + " (" + saved.getName() + ")"
        ));

        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success("Scheme created successfully", saved));
    }

    @PutMapping("/schemes/{id}")
    @Transactional
    public ResponseEntity<ApiResponse<Scheme>> updateScheme(
            @PathVariable UUID id,
            @Valid @RequestBody CreateSchemeRequest request) {

        log.info("Admin updating scheme ID: {}", id);

        return schemeRepository.findById(id).map(scheme -> {
            populateSchemeFromRequest(scheme, request);
            Scheme updated = schemeRepository.save(scheme);

            auditEventRepository.save(new AuditEvent(
                    "ADMIN",
                    "UPDATE_SCHEME",
                    "SCHEME",
                    updated.getId().toString(),
                    "Updated scheme attributes: " + updated.getCode()
            ));

            return ResponseEntity.ok(ApiResponse.success("Scheme updated successfully", updated));
        }).orElseGet(() -> ResponseEntity.status(HttpStatus.NOT_FOUND)
                .body(ApiResponse.failure("NOT_FOUND", "Scheme not found with ID: " + id)));
    }

    @PatchMapping("/schemes/{id}/status")
    @Transactional
    public ResponseEntity<ApiResponse<Scheme>> updateSchemeStatus(
            @PathVariable UUID id,
            @RequestBody Map<String, Boolean> statusUpdate) {

        Boolean isActive = statusUpdate.get("isActive");
        if (isActive == null) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.failure("BAD_REQUEST", "Missing required field: isActive"));
        }

        return schemeRepository.findById(id).map(scheme -> {
            scheme.setActive(isActive);
            Scheme updated = schemeRepository.save(scheme);

            auditEventRepository.save(new AuditEvent(
                    "ADMIN",
                    isActive ? "ACTIVATE_SCHEME" : "DEACTIVATE_SCHEME",
                    "SCHEME",
                    updated.getId().toString(),
                    "Toggled active status to " + isActive + " for scheme " + updated.getCode()
            ));

            return ResponseEntity.ok(ApiResponse.success("Scheme status updated to: " + isActive, updated));
        }).orElseGet(() -> ResponseEntity.status(HttpStatus.NOT_FOUND)
                .body(ApiResponse.failure("NOT_FOUND", "Scheme not found with ID: " + id)));
    }

    @GetMapping("/audit-logs")
    public ResponseEntity<ApiResponse<Page<AuditEvent>>> getAuditLogs(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "50") int size) {

        PageRequest pageRequest = PageRequest.of(page, size, Sort.by("createdAt").descending());
        Page<AuditEvent> logs = auditEventRepository.findAll(pageRequest);
        return ResponseEntity.ok(ApiResponse.success("Audit logs retrieved successfully", logs));
    }

    private void populateSchemeFromRequest(Scheme scheme, CreateSchemeRequest request) {
        scheme.setCode(request.code());
        scheme.setName(request.name());
        scheme.setMinistry(request.ministry());
        scheme.setCategory(request.category() != null ? request.category() : SchemeCategoryType.CENTRAL_GOVERNMENT);
        scheme.setShortDescription(request.shortDescription());
        scheme.setBenefits(request.benefits());
        scheme.setApplicationMode(request.applicationMode() != null ? request.applicationMode() : ApplicationModeType.BOTH);
        scheme.setApplicationProcess(request.applicationProcess());
        scheme.setOfficialUrl(request.officialUrl());
        scheme.setMinAge(request.minAge());
        scheme.setMaxAge(request.maxAge());
        scheme.setMaxIncome(request.maxIncome());
        scheme.setRequiresDisability(Boolean.TRUE.equals(request.requiresDisability()));
        scheme.setTargetState(request.targetState() != null ? request.targetState() : "ALL");
        scheme.setStartDate(request.startDate());
        scheme.setEndDate(request.endDate());

        if (request.applicableCastes() != null) {
            scheme.setApplicableCastes(request.applicableCastes());
        }
        if (request.applicableGenders() != null) {
            scheme.setApplicableGenders(request.applicableGenders());
        }
        if (request.applicableOccupations() != null) {
            scheme.setApplicableOccupations(request.applicableOccupations());
        }
    }
}
