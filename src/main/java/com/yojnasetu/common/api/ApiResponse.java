package com.yojnasetu.common.api;

import com.fasterxml.jackson.annotation.JsonInclude;
import java.time.Instant;
import java.util.List;

@JsonInclude(JsonInclude.Include.NON_NULL)
public record ApiResponse<T>(
        boolean success,
        String message,
        T data,
        ApiError error,
        Instant timestamp
) {
    public static <T> ApiResponse<T> success(T data) {
        return new ApiResponse<>(true, "Operation successful", data, null, Instant.now());
    }

    public static <T> ApiResponse<T> success(String message, T data) {
        return new ApiResponse<>(true, message, data, null, Instant.now());
    }

    public static <T> ApiResponse<T> failure(String errorCode, String errorMessage) {
        return new ApiResponse<>(false, errorMessage, null, new ApiError(errorCode, errorMessage, null), Instant.now());
    }

    public static <T> ApiResponse<T> failure(String errorCode, String errorMessage, List<String> details) {
        return new ApiResponse<>(false, errorMessage, null, new ApiError(errorCode, errorMessage, details), Instant.now());
    }

    public record ApiError(
            String code,
            String message,
            List<String> details
    ) {}
}
