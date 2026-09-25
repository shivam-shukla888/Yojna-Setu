package com.yojnasetu.config;

import com.yojnasetu.security.ApiKeyAuthenticationFilter;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

@Configuration
@EnableWebSecurity
public class SecurityConfig {

    private final ApiKeyAuthenticationFilter apiKeyFilter;

    public SecurityConfig(ApiKeyAuthenticationFilter apiKeyFilter) {
        this.apiKeyFilter = apiKeyFilter;
    }

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
                .csrf(AbstractHttpConfigurer::disable)
                .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
                .authorizeHttpRequests(auth -> auth
                        // Public & Observability
                        .requestMatchers("/actuator/**").permitAll()
                        .requestMatchers("/api/health").permitAll()
                        // Demo & Webhooks & Static Resources
                        .requestMatchers("/", "/index.html", "/demo.html", "/favicon.ico", "/static/**").permitAll()
                        .requestMatchers("/api/v1/demo/**").permitAll()
                        .requestMatchers("/api/v1/webhooks/**").permitAll()
                        .requestMatchers("/webhook/**").permitAll()
                        // Public schemes
                        .requestMatchers("/api/schemes/**").permitAll()
                        // Admin endpoints require authentication via ApiKeyFilter
                        .requestMatchers("/api/v1/admin/**").hasRole("ADMIN")
                        // Default secure
                        .anyRequest().authenticated()
                )
                .addFilterBefore(apiKeyFilter, UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }
}
