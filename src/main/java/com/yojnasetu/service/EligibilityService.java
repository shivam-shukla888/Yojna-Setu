package com.yojnasetu.service;

import com.yojnasetu.model.Scheme;
import com.yojnasetu.model.UserProfile;
import com.yojnasetu.repository.SchemeRepository;
import com.yojnasetu.repository.UserProfileRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

@Service
public class EligibilityService {

    private final UserProfileRepository userProfileRepository;
    private final SchemeRepository schemeRepository;

    @Autowired
    public EligibilityService(UserProfileRepository userProfileRepository, SchemeRepository schemeRepository) {
        this.userProfileRepository = userProfileRepository;
        this.schemeRepository = schemeRepository;
    }

    public List<Scheme> getEligibleSchemes(String phoneNumber) {
        Optional<UserProfile> profileOpt = userProfileRepository.findByUserPhoneNumber(phoneNumber);
        if (profileOpt.isEmpty()) {
            throw new IllegalArgumentException("UserProfile not found for phone number: " + phoneNumber);
        }

        UserProfile userProfile = profileOpt.get();
        List<Scheme> activeSchemes = schemeRepository.findByIsActiveAndEndDateAfterOrEndDateIsNull(true, java.time.LocalDate.now());
        List<Scheme> eligibleSchemes = new ArrayList<>();

        for (Scheme scheme : activeSchemes) {
            if (isEligible(userProfile, scheme)) {
                eligibleSchemes.add(scheme);
            }
        }

        return eligibleSchemes;
    }

    private boolean isEligible(UserProfile userProfile, Scheme scheme) {
        // Filter out schemes where endDate is not null and endDate is before today
        java.time.LocalDate today = java.time.LocalDate.now();
        if (scheme.getEndDate() != null && scheme.getEndDate().isBefore(today)) {
            return false;
        }

        // Rule 1: Max Income
        if (scheme.getMaxIncome() != null) {
            if (userProfile.getIncome() == null || userProfile.getIncome() > scheme.getMaxIncome()) {
                return false;
            }
        }

        // Rule 2: Min Age
        if (scheme.getMinAge() != null) {
            if (userProfile.getAge() == null || userProfile.getAge() < scheme.getMinAge()) {
                return false;
            }
        }

        // Rule 3: Max Age
        if (scheme.getMaxAge() != null) {
            if (userProfile.getAge() == null || userProfile.getAge() > scheme.getMaxAge()) {
                return false;
            }
        }

        // Rule 4: Eligible Gender (if not 'ALL', must match)
        if (scheme.getEligibleGender() != null && !scheme.getEligibleGender().equalsIgnoreCase("ALL")) {
            if (userProfile.getGender() == null || !scheme.getEligibleGender().equalsIgnoreCase(userProfile.getGender())) {
                return false;
            }
        }

        // Rule 5: Eligible Castes (if not 'ALL', user's caste must be present in comma-separated eligibleCastes string)
        if (scheme.getEligibleCastes() != null && !scheme.getEligibleCastes().equalsIgnoreCase("ALL") && !scheme.getEligibleCastes().trim().isEmpty()) {
            if (userProfile.getCaste() == null) {
                return false;
            }
            boolean casteMatch = false;
            String[] castes = scheme.getEligibleCastes().split(",");
            for (String caste : castes) {
                if (caste.trim().equalsIgnoreCase(userProfile.getCaste().trim())) {
                    casteMatch = true;
                    break;
                }
            }
            if (!casteMatch) {
                return false;
            }
        }

        // Rule 6: Eligible Occupations (if not 'ALL', user's occupation must match)
        if (scheme.getEligibleOccupations() != null && !scheme.getEligibleOccupations().equalsIgnoreCase("ALL") && !scheme.getEligibleOccupations().trim().isEmpty()) {
            if (userProfile.getOccupation() == null) {
                return false;
            }
            boolean occupationMatch = false;
            String[] occupations = scheme.getEligibleOccupations().split(",");
            for (String occupation : occupations) {
                if (occupation.trim().equalsIgnoreCase(userProfile.getOccupation().trim())) {
                    occupationMatch = true;
                    break;
                }
            }
            if (!occupationMatch) {
                return false;
            }
        }

        // Rule 7: Eligible Religions (if not 'ALL', user's religion must be present in comma-separated eligibleReligions string)
        if (scheme.getEligibleReligions() != null && !scheme.getEligibleReligions().equalsIgnoreCase("ALL") && !scheme.getEligibleReligions().trim().isEmpty()) {
            if (userProfile.getReligion() == null) {
                return false;
            }
            boolean religionMatch = false;
            String[] religions = scheme.getEligibleReligions().split(",");
            for (String religion : religions) {
                if (religion.trim().equalsIgnoreCase(userProfile.getReligion().trim())) {
                    religionMatch = true;
                    break;
                }
            }
            if (!religionMatch) {
                return false;
            }
        }

        // Rule 8: Eligible States (if not 'ALL', user's state must match)
        if (scheme.getEligibleStates() != null && !scheme.getEligibleStates().equalsIgnoreCase("ALL") && !scheme.getEligibleStates().trim().isEmpty()) {
            if (userProfile.getState() == null) {
                return false;
            }
            boolean stateMatch = false;
            String[] states = scheme.getEligibleStates().split(",");
            for (String state : states) {
                if (state.trim().equalsIgnoreCase(userProfile.getState().trim())) {
                    stateMatch = true;
                    break;
                }
            }
            if (!stateMatch) {
                return false;
            }
        }

        return true;
    }
}
