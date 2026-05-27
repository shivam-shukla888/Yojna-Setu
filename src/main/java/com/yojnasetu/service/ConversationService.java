package com.yojnasetu.service;

import com.yojnasetu.model.Scheme;
import com.yojnasetu.model.User;
import com.yojnasetu.model.UserProfile;
import com.yojnasetu.repository.UserRepository;
import com.yojnasetu.repository.UserProfileRepository;
import com.yojnasetu.repository.SchemeRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@Service
public class ConversationService {

    private static final Logger logger = LoggerFactory.getLogger(ConversationService.class);

    private final UserRepository userRepository;
    private final UserProfileRepository userProfileRepository;
    private final SchemeRepository schemeRepository;
    private final GroqService groqService;
    private final EligibilityService eligibilityService;

    @Autowired
    public ConversationService(UserRepository userRepository,
                               UserProfileRepository userProfileRepository,
                               SchemeRepository schemeRepository,
                               GroqService groqService,
                               EligibilityService eligibilityService) {
        this.userRepository = userRepository;
        this.userProfileRepository = userProfileRepository;
        this.schemeRepository = schemeRepository;
        this.groqService = groqService;
        this.eligibilityService = eligibilityService;
    }

    private final Map<String, Integer> shownCountMap = new ConcurrentHashMap<>();
    private final Map<String, Integer> shownDocsCountMap = new ConcurrentHashMap<>();

    public String processMessage(String phoneNumber, String message) {
        if (message != null) {
            String lowerMsg = message.toLowerCase().trim();
            if (lowerMsg.contains("help") || lowerMsg.contains("madad") || 
                lowerMsg.contains("commands") || lowerMsg.contains("kya kar sakte") || 
                lowerMsg.contains("menu")) {
                return "Yojna Setu mein aapka swagat hai! Yeh commands use karein:\n\n" +
                       "1. namaste - Naya profile banayein\n" +
                       "2. reset - Profile dobara banayein\n" +
                       "3. aur - Agle 5 schemes dekhein\n" +
                       "4. documents - Zaroori kagaz dekhein\n" +
                       "5. aur docs - Agle schemes ke documents\n" +
                       "6. deadline - Aane wali deadlines\n" +
                       "7. help - Yeh menu dobara dekhein\n\n" +
                       "Kisi bhi scheme ka naam likhein jaise 'PM-KISAN' - uski poori detail milegi!";
            }

            if (lowerMsg.contains("reset") || lowerMsg.contains("naya shuru") || 
                lowerMsg.contains("dobara") || lowerMsg.contains("start over") || 
                lowerMsg.contains("clear")) {
                userProfileRepository.findByUserPhoneNumber(phoneNumber).ifPresent(userProfileRepository::delete);
                shownCountMap.remove(phoneNumber);
                shownDocsCountMap.remove(phoneNumber);
                return "Aapki profile reset ho gayi hai. Chalo naye sire se shuru karte hain! Aapki umar kya hai?";
            }

            if (lowerMsg.equals("reminder") || lowerMsg.equals("deadline") || 
                lowerMsg.equals("last date") || lowerMsg.equals("kab tak") ||
                lowerMsg.contains("reminder") || lowerMsg.contains("deadline") || 
                lowerMsg.contains("last date") || lowerMsg.contains("kab tak")) {
                java.util.Optional<UserProfile> profileOpt = userProfileRepository.findByUserPhoneNumber(phoneNumber);
                if (profileOpt.isPresent()) {
                    UserProfile profile = profileOpt.get();
                    boolean isProfileComplete = profile.getAge() != null 
                            && profile.getGender() != null 
                            && profile.getState() != null 
                            && profile.getIncome() != null 
                            && profile.getCaste() != null 
                            && profile.getOccupation() != null
                            && profile.getReligion() != null;
                            
                    if (isProfileComplete) {
                        List<Scheme> eligibleSchemes = eligibilityService.getEligibleSchemes(phoneNumber);
                        java.time.LocalDate today = java.time.LocalDate.now();
                        java.time.LocalDate sixtyDaysLater = today.plusDays(60);
                        
                        List<Scheme> deadlineSchemes = new java.util.ArrayList<>();
                        for (Scheme scheme : eligibleSchemes) {
                            java.time.LocalDate endDate = scheme.getEndDate();
                            if (endDate != null && !endDate.isBefore(today) && !endDate.isAfter(sixtyDaysLater)) {
                                deadlineSchemes.add(scheme);
                            }
                        }
                        
                        if (deadlineSchemes.isEmpty()) {
                            return "Abhi koi upcoming deadline nahi hai.";
                        }
                        
                        StringBuilder response = new StringBuilder("Aapke liye aane wali deadlines:\n\n");
                        int count = 1;
                        java.time.format.DateTimeFormatter dtf = java.time.format.DateTimeFormatter.ofPattern("dd MMM yyyy", java.util.Locale.ENGLISH);
                        for (Scheme scheme : deadlineSchemes) {
                            response.append(count).append(". ").append(scheme.getName()).append("\n");
                            response.append("   Last date: ").append(scheme.getEndDate().format(dtf)).append("\n");
                            response.append("   Apply: ").append(scheme.getApplyUrl() != null ? scheme.getApplyUrl() : "").append("\n\n");
                            count++;
                        }
                        return response.toString().trim();
                    }
                }
            }

            if (lowerMsg.equals("aur") || lowerMsg.contains("aur schemes")) {
                java.util.Optional<UserProfile> profileOpt = userProfileRepository.findByUserPhoneNumber(phoneNumber);
                if (profileOpt.isPresent()) {
                    UserProfile profile = profileOpt.get();
                    boolean isProfileComplete = profile.getAge() != null 
                            && profile.getGender() != null 
                            && profile.getState() != null 
                            && profile.getIncome() != null 
                            && profile.getCaste() != null 
                            && profile.getOccupation() != null
                            && profile.getReligion() != null;
                            
                    if (isProfileComplete) {
                        List<Scheme> eligibleSchemes = eligibilityService.getEligibleSchemes(phoneNumber);
                        int shownCount = shownCountMap.getOrDefault(phoneNumber, 5);
                        
                        if (shownCount >= eligibleSchemes.size()) {
                            return "Aapne sabhi yogya yojnaayein dekh li hain! Naye sire se shuru karne ke liye 'reset' likhein.";
                        }
                        
                        int nextCount = Math.min(shownCount + 5, eligibleSchemes.size());
                        List<Scheme> nextSchemes = eligibleSchemes.subList(shownCount, nextCount);
                        
                        String reply = "Ye lijiye aur yojnaayein:\n\n";
                        int count = shownCount;
                        for (Scheme scheme : nextSchemes) {
                            reply += (count + 1) + ". " + scheme.getName() + "\n";
                            count++;
                        }
                        reply += "\nApply: " + nextSchemes.get(0).getApplyUrl();
                        
                        shownCountMap.put(phoneNumber, nextCount);
                        
                        if (nextCount < eligibleSchemes.size()) {
                            reply += "\n\nAur schemes ke liye 'aur' likhein";
                        } else {
                            reply += "\n\nAapne sabhi yogya yojnaayein dekh li hain!";
                        }
                        
                        System.out.println("Reply length (aur): " + reply.length());
                        logger.info("Reply length (aur): {}", reply.length());
                        return reply;
                    }
                }
            }

            if (lowerMsg.contains("aur docs")) {
                java.util.Optional<UserProfile> profileOpt = userProfileRepository.findByUserPhoneNumber(phoneNumber);
                if (profileOpt.isPresent()) {
                    UserProfile profile = profileOpt.get();
                    boolean isProfileComplete = profile.getAge() != null 
                            && profile.getGender() != null 
                            && profile.getState() != null 
                            && profile.getIncome() != null 
                            && profile.getCaste() != null 
                            && profile.getOccupation() != null
                            && profile.getReligion() != null;
                            
                    if (isProfileComplete) {
                        List<Scheme> eligibleSchemes = eligibilityService.getEligibleSchemes(phoneNumber);
                        int shownDocsCount = shownDocsCountMap.getOrDefault(phoneNumber, 3);
                        
                        if (shownDocsCount >= eligibleSchemes.size()) {
                            return "Aapne sabhi yojnao ke documents dekh liye hain!";
                        }
                        
                        int nextCount = Math.min(shownDocsCount + 3, eligibleSchemes.size());
                        List<Scheme> nextSchemes = eligibleSchemes.subList(shownDocsCount, nextCount);
                        
                        StringBuilder response = new StringBuilder("Ye rahe baaki yojnao ke documents:\n\n");
                        int count = shownDocsCount + 1;
                        for (Scheme scheme : nextSchemes) {
                            response.append(count).append(". ").append(scheme.getName()).append(":\n");
                            String docsField = scheme.getRequiredDocuments();
                            if (docsField != null && !docsField.trim().isEmpty()) {
                                String[] docs = docsField.split(",");
                                for (String doc : docs) {
                                    response.append("   - ").append(doc.trim()).append("\n");
                                }
                            } else {
                                response.append("   - Koi zaroori document nahi hai\n");
                            }
                            response.append("\n");
                            count++;
                        }
                        
                        shownDocsCountMap.put(phoneNumber, nextCount);
                        
                        if (nextCount < eligibleSchemes.size()) {
                            response.append("'aur docs' likhein baaki schemes ke liye.");
                        } else {
                            response.setLength(response.length() - 1); // remove trailing newline
                        }
                        
                        String reply = response.toString().trim();
                        System.out.println("Docs Reply length (aur): " + reply.length());
                        logger.info("Docs Reply length (aur): {}", reply.length());
                        return reply;
                    }
                }
            }

            String trimmedMsg = lowerMsg.trim();
            if (trimmedMsg.equals("documents") || trimmedMsg.equals("document") || 
                trimmedMsg.equals("kagaz") || trimmedMsg.equals("kaagaz") || 
                trimmedMsg.equals("docs") || trimmedMsg.equals("kya chahiye")) {
                java.util.Optional<UserProfile> profileOpt = userProfileRepository.findByUserPhoneNumber(phoneNumber);
                if (profileOpt.isPresent()) {
                    UserProfile profile = profileOpt.get();
                    boolean isProfileComplete = profile.getAge() != null 
                            && profile.getGender() != null 
                            && profile.getState() != null 
                            && profile.getIncome() != null 
                            && profile.getCaste() != null 
                            && profile.getOccupation() != null
                            && profile.getReligion() != null;
                            
                    if (isProfileComplete) {
                        List<Scheme> eligibleSchemes = eligibilityService.getEligibleSchemes(phoneNumber);
                        if (eligibleSchemes.isEmpty()) {
                            return "Aapki eligibility ke mutabik koi active yojna nahi mili.";
                        }
                        
                        int docsCount = Math.min(3, eligibleSchemes.size());
                        List<Scheme> topSchemes = eligibleSchemes.subList(0, docsCount);
                        
                        StringBuilder response = new StringBuilder("Aapke liye zaroori documents:\n\n");
                        int count = 1;
                        for (Scheme scheme : topSchemes) {
                            response.append(count).append(". ").append(scheme.getName()).append(":\n");
                            String docsField = scheme.getRequiredDocuments();
                            if (docsField != null && !docsField.trim().isEmpty()) {
                                String[] docs = docsField.split(",");
                                for (String doc : docs) {
                                    response.append("   - ").append(doc.trim()).append("\n");
                                }
                            } else {
                                response.append("   - Koi zaroori document nahi hai\n");
                            }
                            response.append("\n");
                            count++;
                        }
                        
                        shownDocsCountMap.put(phoneNumber, docsCount);
                        
                        if (eligibleSchemes.size() > 3) {
                            response.append("'aur docs' likhein baaki schemes ke liye.");
                        } else {
                            response.setLength(response.length() - 1); // remove trailing newline
                        }
                        
                        String reply = response.toString().trim();
                        System.out.println("Docs Reply length: " + reply.length());
                        logger.info("Docs Reply length: {}", reply.length());
                        return reply;
                    }
                }
            }

            // Feature 2: Scheme search by name
            java.util.Optional<UserProfile> profileOpt = userProfileRepository.findByUserPhoneNumber(phoneNumber);
            if (profileOpt.isPresent()) {
                UserProfile profile = profileOpt.get();
                boolean isProfileComplete = profile.getAge() != null 
                        && profile.getGender() != null 
                        && profile.getState() != null 
                        && profile.getIncome() != null 
                        && profile.getCaste() != null 
                        && profile.getOccupation() != null
                        && profile.getReligion() != null;
                
                if (isProfileComplete) {
                    List<Scheme> allSchemes = schemeRepository.findAll();
                    Scheme matchedScheme = null;
                    for (Scheme s : allSchemes) {
                        if (s.getName() != null) {
                            String sName = s.getName().toLowerCase().trim();
                            if (lowerMsg.contains(sName) || sName.contains(lowerMsg)) {
                                matchedScheme = s;
                                break;
                            }
                        }
                    }
                    
                    if (matchedScheme != null) {
                        String benefits = matchedScheme.getBenefits() != null ? matchedScheme.getBenefits().trim() : "";
                        if (benefits.length() > 200) {
                            benefits = benefits.substring(0, 200).trim() + "...";
                        }
                        
                        String docsField = matchedScheme.getRequiredDocuments();
                        StringBuilder docsBuilder = new StringBuilder();
                        if (docsField != null && !docsField.trim().isEmpty()) {
                            String[] docs = docsField.split(",");
                            for (String doc : docs) {
                                docsBuilder.append("- ").append(doc.trim()).append("\n");
                            }
                        } else {
                            docsBuilder.append("- Koi zaroori document nahi hai\n");
                        }
                        String docsStr = docsBuilder.toString().trim();
                        if (docsStr.length() > 200) {
                            docsStr = docsStr.substring(0, 200).trim() + "...";
                        }
                        
                        String description = matchedScheme.getDescription() != null ? matchedScheme.getDescription().trim() : "";
                        String applyUrl = matchedScheme.getApplyUrl() != null ? matchedScheme.getApplyUrl().trim() : "";
                        String mode = matchedScheme.getApplicationMode() != null ? matchedScheme.getApplicationMode().trim() : "";
                        
                        String reply = matchedScheme.getName() + "\n\n" +
                                       "Kya milega: " + benefits + "\n" +
                                       "Yogyata: " + description + "\n" +
                                       "Documents:\n" + docsStr + "\n" +
                                       "Apply: " + applyUrl + "\n" +
                                       "Mode: " + mode;
                                       
                        if (reply.length() > 1500) {
                            reply = reply.substring(0, 1500).trim() + "...";
                        }
                        
                        System.out.println("Search Reply length: " + reply.length());
                        logger.info("Search Reply length: {}", reply.length());
                        return reply;
                    }
                }
            }
        }

        // 1) Call GroqService to extract fields from the message
        Map<String, Object> extracted = groqService.extractUserInformation(message);

        // 2) Fetch existing UserProfile, or create a new empty one if not exists
        User user = userRepository.findByPhoneNumber(phoneNumber)
                .orElseGet(() -> {
                    User newUser = new User();
                    newUser.setPhoneNumber(phoneNumber);
                    newUser.setName("User");
                    return userRepository.save(newUser);
                });

        UserProfile profile = userProfileRepository.findByUserPhoneNumber(phoneNumber)
                .orElseGet(() -> {
                    UserProfile newProfile = new UserProfile();
                    newProfile.setUser(user);
                    return newProfile;
                });

        // 3) Merge extracted fields into existing profile (only non-null fields, 0 is a valid value)
        if (extracted != null && !extracted.containsKey("error")) {
            if (extracted.get("age") != null) {
                try {
                    String val = extracted.get("age").toString().trim();
                    if (val.contains(".")) {
                        val = val.substring(0, val.indexOf("."));
                    }
                    profile.setAge(Integer.valueOf(val));
                } catch (Exception ignored) {}
            }
            if (extracted.get("gender") != null) {
                String genderVal = extracted.get("gender").toString().toUpperCase().trim();
                if (genderVal.equals("MALE") || genderVal.equals("FEMALE") || genderVal.equals("OTHER")) {
                    profile.setGender(genderVal);
                } else {
                    profile.setGender(null);
                }
            }
            if (extracted.get("state") != null) {
                profile.setState(extracted.get("state").toString());
            }
            if (extracted.get("district") != null) {
                profile.setDistrict(extracted.get("district").toString());
            }
            if (extracted.get("income") != null) {
                try {
                    String val = extracted.get("income").toString().trim();
                    if (val.contains(".")) {
                        val = val.substring(0, val.indexOf("."));
                    }
                    profile.setIncome(Long.valueOf(val));
                } catch (Exception ignored) {}
            }
            if (extracted.get("caste") != null) {
                String casteVal = extracted.get("caste").toString().toUpperCase().trim();
                if (casteVal.equals("GENERAL") || casteVal.equals("OBC") || casteVal.equals("SC") || casteVal.equals("ST")) {
                    profile.setCaste(casteVal);
                } else {
                    profile.setCaste(null);
                }
            }
            if (extracted.get("religion") != null) {
                profile.setReligion(extracted.get("religion").toString());
            }
            if (extracted.get("occupation") != null) {
                String occVal = extracted.get("occupation").toString().toUpperCase().trim();
                if (occVal.equals("FARMER") || occVal.equals("SALARIED") || occVal.equals("BUSINESS") || occVal.equals("STUDENT")) {
                    profile.setOccupation(occVal);
                } else {
                    profile.setOccupation(null);
                }
            }
            if (extracted.get("maritalStatus") != null) {
                profile.setMaritalStatus(extracted.get("maritalStatus").toString().toUpperCase());
            }
        }

        // 4) Save the updated profile to database
        userProfileRepository.save(profile);

        // 5) Check if profile is complete
        // Complete fields: age, gender, state, income, caste, occupation
        // Note: 0 is a valid value for age and income, so we check for null only.
        boolean isAgeComplete = (profile.getAge() != null);
        boolean isIncomeComplete = (profile.getIncome() != null);

        if (!isAgeComplete) {
            return "Aapki umar kya hai?";
        }
        if (profile.getGender() == null) {
            return "Aap purush hain ya mahila? Sirf 'purush' ya 'mahila' likhein.";
        }
        if (profile.getState() == null) {
            return "Aap kis state mein rehte hain?";
        }
        if (!isIncomeComplete) {
            return "Aapki salana aay kitni hai? (jaise: 50000, 1 lakh, 2.5 lakh)";
        }
        if (profile.getCaste() == null) {
            return "Aapki category likhein: GENERAL, OBC, SC, ya ST";
        }
        if (profile.getOccupation() == null) {
            return "Aap kya kaam karte hain? FARMER, SALARIED, BUSINESS, ya STUDENT likhein";
        }
        if (profile.getReligion() == null) {
            return "Aap kaunse dharm se hain? (HINDU/MUSLIM/CHRISTIAN/SIKH/BUDDHIST/JAIN)";
        }

        // 7) If complete, call EligibilityService and format matching schemes
        List<Scheme> eligibleSchemes = eligibilityService.getEligibleSchemes(phoneNumber);

        if (eligibleSchemes.isEmpty()) {
            return "Badhai ho! Aapki profile poori ho gayi hai. Lekin humein khed hai, aapki eligibility ke mutabik abhi koi active yojna nahi mili.";
        }

        String reply = "Badhai ho! Yogya yojnaayein:\n\n";
        int count = 0;
        for (Scheme scheme : eligibleSchemes) {
            if (count >= 5) break;
            reply += (count + 1) + ". " + scheme.getName() + "\n";
            count++;
        }
        reply += "\nApply: " + eligibleSchemes.get(0).getApplyUrl();
        reply += "\nDocuments jaanne ke liye 'documents' likhein";
        reply += "\nDeadlines ke liye 'deadline' likhein";
        reply += "\n\nAur schemes ke liye 'aur' likhein";

        shownCountMap.put(phoneNumber, Math.min(5, eligibleSchemes.size()));

        System.out.println("Reply length: " + reply.length());
        logger.info("Reply length: {}", reply.length());

        return reply;
    }

    private String getCleanUrl(String url) {
        if (url == null) return "";
        String clean = url.replace("https://", "").replace("http://", "").replace("www.", "");
        if (clean.endsWith("/")) {
            clean = clean.substring(0, clean.length() - 1);
        }
        return clean;
    }
}
