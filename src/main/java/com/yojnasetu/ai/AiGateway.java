package com.yojnasetu.ai;

import com.yojnasetu.ai.model.ExtractedDemographicsRecord;

import java.util.Optional;

public interface AiGateway {
    Optional<ExtractedDemographicsRecord> extractDemographics(String userMessage);
    Optional<String> transcribeAudio(byte[] audioBytes, String filename, String mimeType);
}
