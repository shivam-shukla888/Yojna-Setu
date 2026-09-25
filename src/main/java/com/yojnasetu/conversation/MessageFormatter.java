package com.yojnasetu.conversation;

import com.yojnasetu.model.Scheme;
import com.yojnasetu.model.UserProfile;
import org.springframework.stereotype.Component;

import java.util.List;

@Component
public class MessageFormatter {

    public String formatWelcome(String lang) {
        if ("hi".equalsIgnoreCase(lang)) {
            return "🇮🇳 *नमस्ते! Yojna Setu में आपका स्वागत है.*\n\n" +
                    "मैं आपका सरकारी योजना सहायक हूँ। मैं आपको केंद्र और राज्य सरकार की योजनाओं की सही जानकारी और पात्रता जाँचने में मदद करूँगा।\n\n" +
                    "कृपया अपनी भाषा चुनें:\n" +
                    "1. हिंदी (Hindi)\n" +
                    "2. Hinglish\n" +
                    "3. English";
        }
        return "🇮🇳 *Welcome to Yojna Setu!*\n\n" +
                "I am your official government welfare assistant. I help you discover central and state schemes you qualify for.\n\n" +
                "Please choose your language:\n" +
                "1. हिंदी (Hindi)\n" +
                "2. Hinglish\n" +
                "3. English";
    }

    public String formatAskAge(String lang) {
        if ("hi".equalsIgnoreCase(lang)) return "आपकी उम्र (Age) कितनी है? (उदा. 25)";
        if ("hinglish".equalsIgnoreCase(lang)) return "Aapki age kitni hai? (e.g. 25)";
        return "What is your age? (e.g. 25)";
    }

    public String formatAskGender(String lang) {
        if ("hi".equalsIgnoreCase(lang)) return "आपका लिंग (Gender) क्या है?\n1. पुरुष (Male)\n2. महिला (Female)\n3. अन्य (Other)";
        if ("hinglish".equalsIgnoreCase(lang)) return "Aapka gender kya hai?\n1. Male\n2. Female\n3. Other";
        return "What is your gender?\n1. Male\n2. Female\n3. Other";
    }

    public String formatAskState(String lang) {
        if ("hi".equalsIgnoreCase(lang)) return "आप किस राज्य (State) के निवासी हैं? (उदा. Uttar Pradesh, Bihar, Rajasthan, Maharashtra)";
        if ("hinglish".equalsIgnoreCase(lang)) return "Aap kis state se hain? (e.g. Uttar Pradesh, Bihar, Rajasthan, Maharashtra)";
        return "Which state do you reside in? (e.g. Uttar Pradesh, Bihar, Rajasthan, Maharashtra)";
    }

    public String formatAskCaste(String lang) {
        if ("hi".equalsIgnoreCase(lang)) return "आपकी जाति श्रेणी (Category) क्या है?\n1. General\n2. OBC\n3. SC\n4. ST\n5. EWS";
        if ("hinglish".equalsIgnoreCase(lang)) return "Aapki category kya hai?\n1. General\n2. OBC\n3. SC\n4. ST\n5. EWS";
        return "What is your category/caste?\n1. General\n2. OBC\n3. SC\n4. ST\n5. EWS";
    }

    public String formatAskIncome(String lang) {
        if ("hi".equalsIgnoreCase(lang)) return "आपके परिवार की वार्षिक आय (Annual Family Income) कितनी है? (उदा. 150000 या 0)";
        if ("hinglish".equalsIgnoreCase(lang)) return "Aapki family ki annual income kitni hai? (e.g. 150000 ya 0)";
        return "What is your annual family income? (e.g. 150000 or 0)";
    }

    public String formatAskOccupation(String lang) {
        if ("hi".equalsIgnoreCase(lang)) return "आपका व्यवसाय (Occupation) क्या है?\n1. किसान (Farmer)\n2. छात्र (Student)\n3. व्यापारी / स्वरोजगार (Business)\n4. नौकरीपेशा (Salaried)\n5. अन्य / बेरोजगार (Other)";
        if ("hinglish".equalsIgnoreCase(lang)) return "Aap kya kaam karte hain?\n1. Farmer\n2. Student\n3. Business\n4. Salaried\n5. Other";
        return "What is your occupation?\n1. Farmer\n2. Student\n3. Business\n4. Salaried\n5. Other";
    }

    public String formatProfileReview(UserProfile p, String lang) {
        String incomeStr = p.getAnnualIncome() != null ? "₹" + p.getAnnualIncome().toPlainString() : "N/A";
        if ("hi".equalsIgnoreCase(lang)) {
            return "📋 *आपकी प्रोफाइल जानकारी:*\n" +
                    "• उम्र: " + p.getAge() + " वर्ष\n" +
                    "• लिंग: " + p.getGender() + "\n" +
                    "• राज्य: " + p.getState() + "\n" +
                    "• श्रेणी: " + p.getCaste() + "\n" +
                    "• वार्षिक आय: " + incomeStr + "\n" +
                    "• व्यवसाय: " + p.getOccupation() + "\n\n" +
                    "क्या यह जानकारी सही है?\n" +
                    "1. हाँ, योजनाएं देखें (Confirm)\n" +
                    "2. नहीं, दोबारा भरें (Edit)";
        }
        return "📋 *Your Profile Summary:*\n" +
                "• Age: " + p.getAge() + "\n" +
                "• Gender: " + p.getGender() + "\n" +
                "• State: " + p.getState() + "\n" +
                "• Category: " + p.getCaste() + "\n" +
                "• Income: " + incomeStr + "\n" +
                "• Occupation: " + p.getOccupation() + "\n\n" +
                "Is this information correct?\n" +
                "1. Confirm & View Schemes\n" +
                "2. Edit Profile";
    }

    public String formatSchemeList(List<Scheme> schemes, int page, int pageSize, int totalEligible, String lang) {
        if (schemes == null || schemes.isEmpty()) {
            if ("hi".equalsIgnoreCase(lang)) return "माफ़ कीजिए, आपकी प्रोफाइल के अनुसार कोई सक्रिय योजना नहीं मिली।\n\nप्रोफाइल बदलने के लिए 'reset' भेजें।";
            return "Sorry, no active welfare schemes match your exact profile.\n\nSend 'reset' to update your profile.";
        }

        StringBuilder sb = new StringBuilder();
        if ("hi".equalsIgnoreCase(lang)) {
            sb.append("🎯 *आपके लिए पात्र सरकारी योजनाएं (").append(totalEligible).append(" कुल):*\n\n");
        } else {
            sb.append("🎯 *Schemes You Qualify For (").append(totalEligible).append(" total):*\n\n");
        }

        int startIndex = page * pageSize;
        for (int i = 0; i < schemes.size(); i++) {
            Scheme s = schemes.get(i);
            int number = startIndex + i + 1;
            sb.append("*").append(number).append(". ").append(s.getName()).append("*\n");
            sb.append("   • ").append(s.getShortDescription()).append("\n");
            sb.append("   • *लाभ:* ").append(s.getBenefits()).append("\n\n");
        }

        int shownSoFar = startIndex + schemes.size();
        if (shownSoFar < totalEligible) {
            sb.append("👉 और योजनाएं देखने के लिए *more* या *अगला* भेजें।\n");
        }
        sb.append("👉 किसी योजना की पूरी जानकारी, दस्तावेज़ या आवेदन लिंक के लिए उसका नंबर (उदा. *1*) भेजें।");
        return sb.toString();
    }

    public String formatSchemeDetail(Scheme s, String lang) {
        StringBuilder sb = new StringBuilder();
        sb.append("📌 *").append(s.getName()).append("*\n");
        sb.append("🏛️ *मंत्रालय / विभाग:* ").append(s.getMinistry()).append("\n\n");
        sb.append("🎁 *क्या लाभ मिलेगा:*\n").append(s.getBenefits()).append("\n\n");
        sb.append("📋 *विवरण:* ").append(s.getShortDescription()).append("\n\n");
        sb.append("📄 *ज़रूरी दस्तावेज़:*\n").append(s.getRequiredDocuments()).append("\n\n");
        sb.append("🌐 *आधिकारिक पोर्टल:* ").append(s.getOfficialUrl()).append("\n");
        if (s.getApplicationProcess() != null && !s.getApplicationProcess().isEmpty()) {
            sb.append("📝 *आवेदन कैसे करें:* ").append(s.getApplicationProcess()).append("\n\n");
        }
        sb.append("\n👉 वापस योजनाओं की सूची के लिए *back* भेजें।");
        return sb.toString();
    }

    public String formatHelp(String lang) {
        if ("hi".equalsIgnoreCase(lang)) {
            return "ℹ️ *Yojna Setu सहायता मेनू:*\n\n" +
                    "• *schemes* - अपनी पात्र योजनाएं देखें\n" +
                    "• *more* - अगली योजनाएं देखें\n" +
                    "• *1, 2, 3...* - किसी योजना की पूरी जानकारी देखें\n" +
                    "• *reset* - अपनी प्रोफाइल शुरू से दोबारा बनाएं\n" +
                    "• *help* - यह मेनू देखें";
        }
        return "ℹ️ *Yojna Setu Commands:*\n\n" +
                "• *schemes* - View eligible schemes\n" +
                "• *more* - View next schemes\n" +
                "• *1, 2, 3...* - View scheme details\n" +
                "• *reset* - Restart profile collection\n" +
                "• *help* - View this command list";
    }
}
