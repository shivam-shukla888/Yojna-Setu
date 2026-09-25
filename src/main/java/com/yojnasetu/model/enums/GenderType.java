package com.yojnasetu.model.enums;

public enum GenderType {
    MALE,
    FEMALE,
    TRANSGENDER,
    ALL;

    public static GenderType fromString(String value) {
        if (value == null || value.trim().isEmpty()) {
            return ALL;
        }
        String val = value.trim().toUpperCase();
        for (GenderType gt : values()) {
            if (gt.name().equals(val)) {
                return gt;
            }
        }
        return ALL;
    }
}
