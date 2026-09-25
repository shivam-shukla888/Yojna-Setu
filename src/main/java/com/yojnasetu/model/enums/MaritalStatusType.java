package com.yojnasetu.model.enums;

public enum MaritalStatusType {
    SINGLE,
    MARRIED,
    DIVORCED,
    WIDOWED,
    ALL;

    public static MaritalStatusType fromString(String value) {
        if (value == null || value.trim().isEmpty()) {
            return ALL;
        }
        String val = value.trim().toUpperCase();
        for (MaritalStatusType mst : values()) {
            if (mst.name().equals(val)) {
                return mst;
            }
        }
        return ALL;
    }
}
