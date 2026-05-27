package com.yojnasetu.controller;

import com.yojnasetu.model.User;
import com.yojnasetu.model.UserProfile;
import com.yojnasetu.repository.UserRepository;
import com.yojnasetu.repository.UserProfileRepository;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Optional;

@RestController
@RequestMapping("/api/profile")
public class UserProfileController {

    private final UserRepository userRepository;
    private final UserProfileRepository userProfileRepository;

    @Autowired
    public UserProfileController(UserRepository userRepository, UserProfileRepository userProfileRepository) {
        this.userRepository = userRepository;
        this.userProfileRepository = userProfileRepository;
    }

    @PostMapping("/save")
    public ResponseEntity<?> saveProfile(@Valid @RequestBody SaveProfileRequest request) {
        Optional<User> userOpt = userRepository.findByPhoneNumber(request.phoneNumber());
        if (userOpt.isEmpty()) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body("User not found with phone number: " + request.phoneNumber());
        }

        User user = userOpt.get();
        Optional<UserProfile> profileOpt = userProfileRepository.findByUserPhoneNumber(request.phoneNumber());

        UserProfile profile;
        if (profileOpt.isPresent()) {
            profile = profileOpt.get();
        } else {
            profile = new UserProfile();
            profile.setUser(user);
        }

        // Set or update profile fields
        profile.setAge(request.age());
        profile.setGender(request.gender());
        profile.setState(request.state());
        profile.setDistrict(request.district());
        profile.setIncome(request.income());
        profile.setCaste(request.caste());
        profile.setReligion(request.religion());
        profile.setOccupation(request.occupation());
        profile.setMaritalStatus(request.maritalStatus());
        if (request.isDisabled() != null) {
            profile.setIsDisabled(request.isDisabled());
        }

        UserProfile savedProfile = userProfileRepository.save(profile);
        return ResponseEntity.ok(savedProfile);
    }

    @GetMapping("/{phoneNumber}")
    public ResponseEntity<?> getProfileByPhoneNumber(@PathVariable String phoneNumber) {
        Optional<UserProfile> profileOpt = userProfileRepository.findByUserPhoneNumber(phoneNumber);
        if (profileOpt.isEmpty()) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body("Profile not found for phone number: " + phoneNumber);
        }
        return ResponseEntity.ok(profileOpt.get());
    }
}
