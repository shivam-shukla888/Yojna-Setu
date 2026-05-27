package com.yojnasetu.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;
import org.springframework.web.reactive.function.client.WebClientResponseException;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class GroqService {

    private static final Logger logger = LoggerFactory.getLogger(GroqService.class);

    private final WebClient webClient;
    private final ObjectMapper objectMapper;
    private final String apiKey;
    private final String twilioSid;
    private final String twilioToken;

    public GroqService(@Value("${groq.api.key}") String apiKey,
                       @Value("${twilio.account.sid}") String twilioSid,
                       @Value("${twilio.auth.token}") String twilioToken) {
        this.apiKey = apiKey;
        this.twilioSid = twilioSid;
        this.twilioToken = twilioToken;
        this.webClient = WebClient.builder()
                .baseUrl("https://api.groq.com/openai/v1")
                .defaultHeader("Authorization", "Bearer " + apiKey)
                .defaultHeader("Content-Type", MediaType.APPLICATION_JSON_VALUE)
                .build();
        this.objectMapper = new ObjectMapper();
    }

    public Map<String, Object> extractUserInformation(String inputText) {
        Map<String, Object> requestBody = new HashMap<>();
        requestBody.put("model", "llama-3.1-8b-instant");
        requestBody.put("max_tokens", 500);

        List<Map<String, String>> messages = new ArrayList<>();

        Map<String, String> systemMsg = new HashMap<>();
        systemMsg.put("role", "system");
        systemMsg.put("content", "You are a helpful assistant for Indian government scheme eligibility. Extract user information from the message and return ONLY a valid JSON object with these fields: age (Integer), gender (String: MALE/FEMALE/OTHER), state (String: full state name in English like Uttar Pradesh, Madhya Pradesh, Bihar etc), district (String), income (Long: annual income in rupees), caste (String: GENERAL/OBC/SC/ST), religion (String), occupation (String: FARMER/SALARIED/BUSINESS/STUDENT/OTHER), maritalStatus (String: MARRIED/UNMARRIED). Normalize spelling mistakes, short forms, and colloquial terms strictly according to these rules: 1. Gender: pursh, purush, male, ladka, aadmi, man -> MALE; mahila, female, ladki, aurat, woman -> FEMALE. 2. Caste: gen, general, genral, gneral -> GENERAL; obc, OBC, pichda -> OBC; sc, SC, dalit, anusuchit jati -> SC; st, ST, adivasi, janjati, anusuchit janjati -> ST. 3. Occupation: student, padhna, padh rha, college, school, university -> STUDENT; farmer, kisan, kheti, agriculture, krishi -> FARMER; job, naukri, salaried, service, kaam -> SALARIED; business, vyapar, dukan, shop -> BUSINESS. 4. State: up, U.P -> Uttar Pradesh; mp, M.P -> Madhya Pradesh; uk, uttrakhand -> Uttarakhand; hp -> Himachal Pradesh; raj, rj -> Rajasthan; bihar, br -> Bihar; delhi, dl -> Delhi; mah, mh -> Maharashtra; wb -> West Bengal; kar, kk -> Karnataka. 5. Income: zero or shunya or kuch nahi or nahi hai -> 0; ek lakh or 1L -> 100000; do lakh or 2L -> 200000; teen lakh -> 300000; paanch lakh or 5L -> 500000; das lakh -> 1000000. 6. Religion: Muslim, Musalman, Islam -> MUSLIM; Hindu, Sanatan -> HINDU; Christian, Isai -> CHRISTIAN; Sikh, Sardar -> SIKH; Baudh, Buddhist -> BUDDHIST; Jain -> JAIN. If a field is not mentioned set it as null. Return ONLY raw JSON no markdown no explanation.");
        messages.add(systemMsg);

        Map<String, String> userMsg = new HashMap<>();
        userMsg.put("role", "user");
        userMsg.put("content", inputText);
        messages.add(userMsg);

        requestBody.put("messages", messages);

        try {
            String requestBodyJson = objectMapper.writeValueAsString(requestBody);
            logger.info("Groq API Request Body: {}", requestBodyJson);

            String responseJson = this.webClient.post()
                    .uri("/chat/completions")
                    .bodyValue(requestBody)
                    .retrieve()
                    .bodyToMono(String.class)
                    .block();

            logger.info("Groq API Raw Response: {}", responseJson);

            if (responseJson != null) {
                Map<?, ?> responseMap = objectMapper.readValue(responseJson, Map.class);
                if (responseMap.containsKey("choices")) {
                    List<?> choices = (List<?>) responseMap.get("choices");
                    if (choices != null && !choices.isEmpty()) {
                        Map<?, ?> firstChoice = (Map<?, ?>) choices.get(0);
                        if (firstChoice != null && firstChoice.containsKey("message")) {
                            Map<?, ?> message = (Map<?, ?>) firstChoice.get("message");
                            if (message != null && message.containsKey("content")) {
                                String content = (String) message.get("content");
                                logger.info("Extracted content string: {}", content);
                                return parseJsonContent(content);
                            }
                        }
                    }
                }
            }
            
            throw new RuntimeException("Unexpected response format from Groq API");
        } catch (WebClientResponseException e) {
            logger.error("Groq API WebClientResponseException. Status: {}, Error Body: {}", 
                    e.getStatusCode(), e.getResponseBodyAsString(), e);
            Map<String, Object> errorMap = new HashMap<>();
            errorMap.put("error", "Groq API error (" + e.getStatusCode() + "): " + e.getResponseBodyAsString());
            return errorMap;
        } catch (Exception e) {
            logger.error("General error calling Groq API: ", e);
            Map<String, Object> errorMap = new HashMap<>();
            errorMap.put("error", "Failed to extract information: " + e.getMessage());
            return errorMap;
        }
    }

    @SuppressWarnings("unchecked")
    private Map<String, Object> parseJsonContent(String content) {
        try {
            return objectMapper.readValue(content, Map.class);
        } catch (Exception e) {
            // Attempt cleaning in case of markdown wrappers
            String cleaned = content.trim();
            if (cleaned.startsWith("```json")) {
                cleaned = cleaned.substring(7);
            } else if (cleaned.startsWith("```")) {
                cleaned = cleaned.substring(3);
            }
            
            if (cleaned.endsWith("```")) {
                cleaned = cleaned.substring(0, cleaned.length() - 3);
            }
            cleaned = cleaned.trim();
            
            try {
                return objectMapper.readValue(cleaned, Map.class);
            } catch (Exception ex) {
                logger.error("Failed to parse JSON content: {}", content, ex);
                Map<String, Object> fallbackMap = new HashMap<>();
                fallbackMap.put("raw_content", content);
                fallbackMap.put("error", "JSON parsing error: " + ex.getMessage());
                return fallbackMap;
            }
        }
    }

    public String transcribeAudio(String mediaUrl) {
        java.io.File tempFile = null;
        try {
            logger.info("Downloading audio from: {}", mediaUrl);
            byte[] audioBytes = WebClient.builder()
                    .build()
                    .get()
                    .uri(mediaUrl)
                    .headers(headers -> headers.setBasicAuth(twilioSid, twilioToken))
                    .retrieve()
                    .bodyToMono(byte[].class)
                    .block();

            if (audioBytes == null || audioBytes.length == 0) {
                logger.error("Downloaded audio bytes are empty");
                return null;
            }

            java.io.File tempDir = new java.io.File("/tmp");
            if (!tempDir.exists()) {
                tempDir.mkdirs();
            }
            if (!tempDir.exists() || !tempDir.canWrite()) {
                tempDir = new java.io.File(System.getProperty("java.io.tmpdir"));
            }

            tempFile = java.io.File.createTempFile("twilio_voice_", ".ogg", tempDir);
            java.nio.file.Files.write(tempFile.toPath(), audioBytes);
            logger.info("Saved audio to temp file: {}", tempFile.getAbsolutePath());

            org.springframework.http.client.MultipartBodyBuilder bodyBuilder = new org.springframework.http.client.MultipartBodyBuilder();
            bodyBuilder.part("file", new org.springframework.core.io.FileSystemResource(tempFile));
            bodyBuilder.part("model", "whisper-large-v3-turbo");
            bodyBuilder.part("language", "hi");

            logger.info("Sending audio to Groq Whisper API");
            String responseJson = WebClient.builder()
                    .build()
                    .post()
                    .uri("https://api.groq.com/openai/v1/audio/transcriptions")
                    .header("Authorization", "Bearer " + apiKey)
                    .contentType(MediaType.MULTIPART_FORM_DATA)
                    .bodyValue(bodyBuilder.build())
                    .retrieve()
                    .bodyToMono(String.class)
                    .block();

            logger.info("Groq Whisper API Response: {}", responseJson);
            if (responseJson != null) {
                Map<?, ?> responseMap = objectMapper.readValue(responseJson, Map.class);
                if (responseMap.containsKey("text")) {
                    return (String) responseMap.get("text");
                }
            }
            return null;
        } catch (Exception e) {
            logger.error("Error transcribing audio from: {}", mediaUrl, e);
            return null;
        } finally {
            if (tempFile != null && tempFile.exists()) {
                try {
                    tempFile.delete();
                } catch (Exception e) {
                    logger.warn("Failed to delete temp file: {}", tempFile.getAbsolutePath(), e);
                }
            }
        }
    }
}
