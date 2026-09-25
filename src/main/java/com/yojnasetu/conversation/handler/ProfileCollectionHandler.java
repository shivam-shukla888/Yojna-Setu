package com.yojnasetu.conversation.handler;

import com.yojnasetu.conversation.MessageFormatter;
import com.yojnasetu.conversation.model.InboundMessage;
import com.yojnasetu.conversation.model.StateTransitionResult;
import com.yojnasetu.model.ConversationSession;
import com.yojnasetu.model.User;
import com.yojnasetu.model.UserProfile;
import com.yojnasetu.model.enums.CasteType;
import com.yojnasetu.model.enums.GenderType;
import com.yojnasetu.model.enums.SessionStateType;
import com.yojnasetu.repository.UserProfileRepository;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@Component
public class ProfileCollectionHandler implements ConversationStateHandler {

    private final MessageFormatter formatter;
    private final UserProfileRepository userProfileRepository;

    public ProfileCollectionHandler(MessageFormatter formatter, UserProfileRepository userProfileRepository) {
        this.formatter = formatter;
        this.userProfileRepository = userProfileRepository;
    }

    @Override
    public SessionStateType getSupportedState() {
        return SessionStateType.PROFILE_COLLECTION;
    }

    @Override
    public StateTransitionResult handle(InboundMessage message, User user, UserProfile profile, ConversationSession session) {
        String input = message.text().trim();
        String lang = user != null ? user.getPreferredLanguage() : "hi";

        if (profile == null) {
            profile = new UserProfile(user);
        }

        // 1. Process current missing field based on what's null
        if (profile.getAge() == null) {
            Integer parsedAge = extractNumber(input);
            if (parsedAge != null && parsedAge >= 0 && parsedAge <= 120) {
                profile.setAge(parsedAge);
            } else {
                return StateTransitionResult.noChange(SessionStateType.PROFILE_COLLECTION,
                        "कृपया सही उम्र (संख्या में, उदा. 28) लिखें:\n" + formatter.formatAskAge(lang));
            }
        } else if (profile.getGenderType() == null) {
            GenderType g = parseGender(input);
            if (g != null) {
                profile.setGender(g);
            } else {
                return StateTransitionResult.noChange(SessionStateType.PROFILE_COLLECTION,
                        "कृपया सही विकल्प चुनें:\n" + formatter.formatAskGender(lang));
            }
        } else if (profile.getState() == null) {
            if (input.length() >= 2) {
                profile.setState(cleanState(input));
            } else {
                return StateTransitionResult.noChange(SessionStateType.PROFILE_COLLECTION, formatter.formatAskState(lang));
            }
        } else if (profile.getCasteType() == null) {
            CasteType c = parseCaste(input);
            if (c != null) {
                profile.setCaste(c);
            } else {
                return StateTransitionResult.noChange(SessionStateType.PROFILE_COLLECTION,
                        "कृपया अपनी श्रेणी चुनें:\n" + formatter.formatAskCaste(lang));
            }
        } else if (profile.getAnnualIncome() == null) {
            BigDecimal income = extractIncome(input);
            if (income != null) {
                profile.setAnnualIncome(income);
            } else {
                return StateTransitionResult.noChange(SessionStateType.PROFILE_COLLECTION,
                        "कृपया पारिवारिक वार्षिक आय (संख्या में) बताएं:\n" + formatter.formatAskIncome(lang));
            }
        } else if (profile.getOccupation() == null) {
            String occ = parseOccupation(input);
            if (occ != null) {
                profile.setOccupation(occ);
            } else {
                return StateTransitionResult.noChange(SessionStateType.PROFILE_COLLECTION,
                        "कृपया अपना व्यवसाय चुनें:\n" + formatter.formatAskOccupation(lang));
            }
        }

        // Save intermediate state
        userProfileRepository.save(profile);

        // Check next missing question
        if (profile.getAge() == null) {
            return StateTransitionResult.of(SessionStateType.PROFILE_COLLECTION, formatter.formatAskAge(lang));
        } else if (profile.getGenderType() == null) {
            return StateTransitionResult.of(SessionStateType.PROFILE_COLLECTION, formatter.formatAskGender(lang));
        } else if (profile.getState() == null) {
            return StateTransitionResult.of(SessionStateType.PROFILE_COLLECTION, formatter.formatAskState(lang));
        } else if (profile.getCasteType() == null) {
            return StateTransitionResult.of(SessionStateType.PROFILE_COLLECTION, formatter.formatAskCaste(lang));
        } else if (profile.getAnnualIncome() == null) {
            return StateTransitionResult.of(SessionStateType.PROFILE_COLLECTION, formatter.formatAskIncome(lang));
        } else if (profile.getOccupation() == null) {
            return StateTransitionResult.of(SessionStateType.PROFILE_COLLECTION, formatter.formatAskOccupation(lang));
        }

        // All 6 core demographic attributes are collected! Move to PROFILE_REVIEW
        String reviewMsg = formatter.formatProfileReview(profile, lang);
        return StateTransitionResult.of(SessionStateType.PROFILE_REVIEW, reviewMsg);
    }

    private Integer extractNumber(String input) {
        Matcher m = Pattern.compile("\\b(\\d{1,3})\\b").matcher(input);
        if (m.find()) {
            return Integer.parseInt(m.group(1));
        }
        return null;
    }

    private BigDecimal extractIncome(String input) {
        String clean = input.replaceAll("[^0-9]", "");
        if (!clean.isEmpty()) {
            try {
                return new BigDecimal(clean);
            } catch (Exception ignored) {}
        }
        return null;
    }

    private GenderType parseGender(String input) {
        String val = input.trim().toLowerCase();
        if (val.equals("1") || val.contains("male") || val.contains("पुरुष") || val.contains("aadmi")) return GenderType.MALE;
        if (val.equals("2") || val.contains("female") || val.contains("महिला") || val.contains("aurat")) return GenderType.FEMALE;
        if (val.equals("3") || val.contains("other") || val.contains("अन्य")) return GenderType.ALL;
        return null;
    }

    private CasteType parseCaste(String input) {
        String val = input.trim().toLowerCase();
        if (val.equals("1") || val.contains("gen")) return CasteType.GENERAL;
        if (val.equals("2") || val.contains("obc")) return CasteType.OBC;
        if (val.equals("3") || val.contains("sc")) return CasteType.SC;
        if (val.equals("4") || val.contains("st")) return CasteType.ST;
        if (val.equals("5") || val.contains("ews")) return CasteType.EWS;
        return null;
    }

    private String parseOccupation(String input) {
        String val = input.trim().toLowerCase();
        if (val.equals("1") || val.contains("farm") || val.contains("किसान") || val.contains("kisan")) return "FARMER";
        if (val.equals("2") || val.contains("stud") || val.contains("छात्र")) return "STUDENT";
        if (val.equals("3") || val.contains("busi") || val.contains("व्यापार") || val.contains("shop")) return "BUSINESS";
        if (val.equals("4") || val.contains("salar") || val.contains("नौकरी") || val.contains("job")) return "SALARIED";
        if (val.equals("5") || val.contains("other") || val.contains("अन्य") || val.contains("mazdoor")) return "OTHER";
        return input.trim().toUpperCase();
    }

    private String cleanState(String input) {
        String trimmed = input.trim();
        if (trimmed.length() > 100) return trimmed.substring(0, 100);
        return trimmed;
    }
}
