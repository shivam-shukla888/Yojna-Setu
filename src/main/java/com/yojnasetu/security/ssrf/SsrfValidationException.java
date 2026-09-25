package com.yojnasetu.security.ssrf;

public class SsrfValidationException extends RuntimeException {
    public SsrfValidationException(String message) {
        super(message);
    }
}
