package com.yojnasetu.controller;

import com.yojnasetu.model.User;
import com.yojnasetu.repository.UserRepository;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/users")
public class UserController {

    private final UserRepository userRepository;

    @Autowired
    public UserController(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    @PostMapping("/register")
    public ResponseEntity<User> registerUser(@Valid @RequestBody UserRegisterRequest request) {
        User user = new User();
        user.setPhoneNumber(request.phoneNumber());
        user.setName(request.name());
        User savedUser = userRepository.save(user);
        return ResponseEntity.ok(savedUser);
    }
}
