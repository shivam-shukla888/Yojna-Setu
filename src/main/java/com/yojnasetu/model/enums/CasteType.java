package com.yojnasetu.model.enums;

public enum CasteType {
    GENERAL,
    OBC,
    SC,
    ST,
    EWS,
    ALL;

    public static CasteType fromString(String value) {
        if (value == null || value.trim().isEmpty()) {
            return ALL;
        }
        String val = value.trim().toUpperCase();
        if (val.contains("GEN")) return GENERAL;
        if (val.contains("OBC")) return OBC;
        if (val.contains("SC")) return SC;
        if (val.contains("ST")) return ST;
        if (val.contains("EWS")) return EWS;
        return ALL;
    }
}
