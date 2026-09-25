-- ==============================================================================
-- YOJNA SETU V2 — V2 NORMALIZED SCHEME SEEDING (82 SCHEMES)
-- Normalized 1NF schema migration from legacy data.sql
-- Target Schema: yojna_setu
-- ==============================================================================

DO $$
DECLARE
    v_scheme_id UUID;
BEGIN

    -- Scheme #1: PM-KISAN
    INSERT INTO yojna_setu.schemes (
        code, name, ministry, category, short_description, benefits,
        application_mode, application_process, official_url,
        min_age, max_age, max_income, requires_disability, target_state, start_date, end_date, is_active
    ) VALUES (
        'PM-KISAN', 'PM-KISAN', 'Ministry of Agriculture', 'CENTRAL_GOVERNMENT', 'Pradhan Mantri Kisan Samman Nidhi - income support for farmers', 'Rs 6000 per year in 3 installments of Rs 2000 directly in bank account',
        'BOTH', 'Visit nearest CSC center or apply on pmkisan.gov.in', 'https://pmkisan.gov.in',
        18, 130, 200000, FALSE, 'ALL', '2019-02-01', NULL, TRUE
    ) ON CONFLICT (code) DO UPDATE SET
        name = EXCLUDED.name, short_description = EXCLUDED.short_description, benefits = EXCLUDED.benefits,
        official_url = EXCLUDED.official_url, max_income = EXCLUDED.max_income, target_state = EXCLUDED.target_state,
        updated_at = CURRENT_TIMESTAMP
    RETURNING id INTO v_scheme_id;

    DELETE FROM yojna_setu.scheme_castes WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_genders WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_occupations WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_religions WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_documents WHERE scheme_id = v_scheme_id;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'SC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'ST') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'OBC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'GENERAL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_genders (scheme_id, gender) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_occupations (scheme_id, occupation) VALUES (v_scheme_id, 'FARMER') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_religions (scheme_id, religion) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Aadhaar Card', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Bank Passbook', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Khasra/Khatauni Land Record', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Mobile Number', TRUE);

    -- Scheme #2: PM Fasal Bima Yojana
    INSERT INTO yojna_setu.schemes (
        code, name, ministry, category, short_description, benefits,
        application_mode, application_process, official_url,
        min_age, max_age, max_income, requires_disability, target_state, start_date, end_date, is_active
    ) VALUES (
        'PM-FASAL-BIMA-YOJANA', 'PM Fasal Bima Yojana', 'Ministry of Agriculture', 'CENTRAL_GOVERNMENT', 'Crop insurance against natural calamities pests and diseases', 'Compensation for crop loss at very low premium - 2% for Kharif 1.5% for Rabi crops',
        'BOTH', 'Apply through bank or insurance company before sowing season', 'https://pmfby.gov.in',
        18, 130, NULL, FALSE, 'ALL', '2016-01-13', NULL, TRUE
    ) ON CONFLICT (code) DO UPDATE SET
        name = EXCLUDED.name, short_description = EXCLUDED.short_description, benefits = EXCLUDED.benefits,
        official_url = EXCLUDED.official_url, max_income = EXCLUDED.max_income, target_state = EXCLUDED.target_state,
        updated_at = CURRENT_TIMESTAMP
    RETURNING id INTO v_scheme_id;

    DELETE FROM yojna_setu.scheme_castes WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_genders WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_occupations WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_religions WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_documents WHERE scheme_id = v_scheme_id;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'SC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'ST') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'OBC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'GENERAL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_genders (scheme_id, gender) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_occupations (scheme_id, occupation) VALUES (v_scheme_id, 'FARMER') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_religions (scheme_id, religion) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Aadhaar Card', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Land Record', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Bank Passbook', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Sowing Certificate', TRUE);

    -- Scheme #3: Kisan Credit Card
    INSERT INTO yojna_setu.schemes (
        code, name, ministry, category, short_description, benefits,
        application_mode, application_process, official_url,
        min_age, max_age, max_income, requires_disability, target_state, start_date, end_date, is_active
    ) VALUES (
        'KISAN-CREDIT-CARD', 'Kisan Credit Card', 'Ministry of Agriculture', 'CENTRAL_GOVERNMENT', 'Short term credit for crop cultivation at low interest', 'Credit up to Rs 3 lakh at 4% interest rate after subvention',
        'OFFLINE', 'Visit nearest bank branch with land documents', 'https://pmkisan.gov.in',
        18, 130, NULL, FALSE, 'ALL', '1998-08-01', NULL, TRUE
    ) ON CONFLICT (code) DO UPDATE SET
        name = EXCLUDED.name, short_description = EXCLUDED.short_description, benefits = EXCLUDED.benefits,
        official_url = EXCLUDED.official_url, max_income = EXCLUDED.max_income, target_state = EXCLUDED.target_state,
        updated_at = CURRENT_TIMESTAMP
    RETURNING id INTO v_scheme_id;

    DELETE FROM yojna_setu.scheme_castes WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_genders WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_occupations WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_religions WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_documents WHERE scheme_id = v_scheme_id;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'SC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'ST') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'OBC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'GENERAL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_genders (scheme_id, gender) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_occupations (scheme_id, occupation) VALUES (v_scheme_id, 'FARMER') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_religions (scheme_id, religion) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Aadhaar Card', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Land Record', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Passport Photo', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Bank Account', TRUE);

    -- Scheme #4: PM Kisan Maandhan Yojana
    INSERT INTO yojna_setu.schemes (
        code, name, ministry, category, short_description, benefits,
        application_mode, application_process, official_url,
        min_age, max_age, max_income, requires_disability, target_state, start_date, end_date, is_active
    ) VALUES (
        'PM-KISAN-MAANDHAN-YOJANA', 'PM Kisan Maandhan Yojana', 'Ministry of Agriculture', 'CENTRAL_GOVERNMENT', 'Pension scheme for small and marginal farmers', 'Rs 3000 per month pension after age 60',
        'BOTH', 'Enroll at nearest CSC center', 'https://pmkmy.gov.in',
        18, 40, NULL, FALSE, 'ALL', '2019-08-12', NULL, TRUE
    ) ON CONFLICT (code) DO UPDATE SET
        name = EXCLUDED.name, short_description = EXCLUDED.short_description, benefits = EXCLUDED.benefits,
        official_url = EXCLUDED.official_url, max_income = EXCLUDED.max_income, target_state = EXCLUDED.target_state,
        updated_at = CURRENT_TIMESTAMP
    RETURNING id INTO v_scheme_id;

    DELETE FROM yojna_setu.scheme_castes WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_genders WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_occupations WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_religions WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_documents WHERE scheme_id = v_scheme_id;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'SC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'ST') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'OBC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'GENERAL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_genders (scheme_id, gender) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_occupations (scheme_id, occupation) VALUES (v_scheme_id, 'FARMER') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_religions (scheme_id, religion) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Aadhaar Card', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Bank Passbook', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Land Record', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Mobile Number', TRUE);

    -- Scheme #5: Paramparagat Krishi Vikas Yojana
    INSERT INTO yojna_setu.schemes (
        code, name, ministry, category, short_description, benefits,
        application_mode, application_process, official_url,
        min_age, max_age, max_income, requires_disability, target_state, start_date, end_date, is_active
    ) VALUES (
        'PARAMPARAGAT-KRISHI-VIKAS-YOJANA', 'Paramparagat Krishi Vikas Yojana', 'Ministry of Agriculture', 'CENTRAL_GOVERNMENT', 'Support for organic farming', 'Rs 50000 per hectare for 3 years for organic farming',
        'OFFLINE', 'Contact local agriculture department', 'https://pgsindia-ncof.gov.in',
        18, 130, NULL, FALSE, 'ALL', '2015-01-01', NULL, TRUE
    ) ON CONFLICT (code) DO UPDATE SET
        name = EXCLUDED.name, short_description = EXCLUDED.short_description, benefits = EXCLUDED.benefits,
        official_url = EXCLUDED.official_url, max_income = EXCLUDED.max_income, target_state = EXCLUDED.target_state,
        updated_at = CURRENT_TIMESTAMP
    RETURNING id INTO v_scheme_id;

    DELETE FROM yojna_setu.scheme_castes WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_genders WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_occupations WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_religions WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_documents WHERE scheme_id = v_scheme_id;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'SC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'ST') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'OBC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'GENERAL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_genders (scheme_id, gender) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_occupations (scheme_id, occupation) VALUES (v_scheme_id, 'FARMER') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_religions (scheme_id, religion) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Aadhaar Card', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Land Record', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Bank Passbook', TRUE);

    -- Scheme #6: Ayushman Bharat PMJAY
    INSERT INTO yojna_setu.schemes (
        code, name, ministry, category, short_description, benefits,
        application_mode, application_process, official_url,
        min_age, max_age, max_income, requires_disability, target_state, start_date, end_date, is_active
    ) VALUES (
        'AYUSHMAN-BHARAT-PMJAY', 'Ayushman Bharat PMJAY', 'Ministry of Health', 'CENTRAL_GOVERNMENT', 'Free health insurance for low income families', 'Free treatment up to Rs 5 lakh per family per year at 25000+ empanelled hospitals',
        'OFFLINE', 'Visit nearest empanelled hospital with Aadhaar card', 'https://pmjay.gov.in',
        0, 130, 500000, FALSE, 'ALL', '2018-09-23', NULL, TRUE
    ) ON CONFLICT (code) DO UPDATE SET
        name = EXCLUDED.name, short_description = EXCLUDED.short_description, benefits = EXCLUDED.benefits,
        official_url = EXCLUDED.official_url, max_income = EXCLUDED.max_income, target_state = EXCLUDED.target_state,
        updated_at = CURRENT_TIMESTAMP
    RETURNING id INTO v_scheme_id;

    DELETE FROM yojna_setu.scheme_castes WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_genders WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_occupations WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_religions WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_documents WHERE scheme_id = v_scheme_id;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'SC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'ST') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'OBC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'GENERAL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_genders (scheme_id, gender) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_occupations (scheme_id, occupation) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_religions (scheme_id, religion) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Aadhaar Card', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Ration Card', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Income Certificate', TRUE);

    -- Scheme #7: Ayushman Bharat Senior Citizens
    INSERT INTO yojna_setu.schemes (
        code, name, ministry, category, short_description, benefits,
        application_mode, application_process, official_url,
        min_age, max_age, max_income, requires_disability, target_state, start_date, end_date, is_active
    ) VALUES (
        'AYUSHMAN-BHARAT-SENIOR-CITIZENS', 'Ayushman Bharat Senior Citizens', 'Ministry of Health', 'CENTRAL_GOVERNMENT', 'Free health coverage for all senior citizens above 70', 'Free health coverage up to Rs 5 lakh per year regardless of income',
        'ONLINE', 'Register on pmjay.gov.in with Aadhaar', 'https://pmjay.gov.in',
        70, 130, NULL, FALSE, 'ALL', '2024-10-29', NULL, TRUE
    ) ON CONFLICT (code) DO UPDATE SET
        name = EXCLUDED.name, short_description = EXCLUDED.short_description, benefits = EXCLUDED.benefits,
        official_url = EXCLUDED.official_url, max_income = EXCLUDED.max_income, target_state = EXCLUDED.target_state,
        updated_at = CURRENT_TIMESTAMP
    RETURNING id INTO v_scheme_id;

    DELETE FROM yojna_setu.scheme_castes WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_genders WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_occupations WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_religions WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_documents WHERE scheme_id = v_scheme_id;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'SC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'ST') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'OBC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'GENERAL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_genders (scheme_id, gender) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_occupations (scheme_id, occupation) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_religions (scheme_id, religion) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Aadhaar Card', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Age Proof', TRUE);

    -- Scheme #8: Janani Suraksha Yojana
    INSERT INTO yojna_setu.schemes (
        code, name, ministry, category, short_description, benefits,
        application_mode, application_process, official_url,
        min_age, max_age, max_income, requires_disability, target_state, start_date, end_date, is_active
    ) VALUES (
        'JANANI-SURAKSHA-YOJANA', 'Janani Suraksha Yojana', 'Ministry of Health', 'CENTRAL_GOVERNMENT', 'Cash assistance for pregnant women for institutional delivery', 'Rs 1400 in rural areas Rs 1000 in urban areas cash assistance after delivery',
        'OFFLINE', 'Register with ASHA worker or ANM during pregnancy', 'https://nhm.gov.in',
        19, 130, NULL, FALSE, 'ALL', '2005-04-12', NULL, TRUE
    ) ON CONFLICT (code) DO UPDATE SET
        name = EXCLUDED.name, short_description = EXCLUDED.short_description, benefits = EXCLUDED.benefits,
        official_url = EXCLUDED.official_url, max_income = EXCLUDED.max_income, target_state = EXCLUDED.target_state,
        updated_at = CURRENT_TIMESTAMP
    RETURNING id INTO v_scheme_id;

    DELETE FROM yojna_setu.scheme_castes WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_genders WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_occupations WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_religions WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_documents WHERE scheme_id = v_scheme_id;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'SC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'ST') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'OBC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'GENERAL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_genders (scheme_id, gender) VALUES (v_scheme_id, 'FEMALE') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_occupations (scheme_id, occupation) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_religions (scheme_id, religion) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Aadhaar Card', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'BPL Card', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'JSY Card from ANM', TRUE);

    -- Scheme #9: PM Surakshit Matritva Abhiyan
    INSERT INTO yojna_setu.schemes (
        code, name, ministry, category, short_description, benefits,
        application_mode, application_process, official_url,
        min_age, max_age, max_income, requires_disability, target_state, start_date, end_date, is_active
    ) VALUES (
        'PM-SURAKSHIT-MATRITVA-ABHIYAN', 'PM Surakshit Matritva Abhiyan', 'Ministry of Health', 'CENTRAL_GOVERNMENT', 'Free antenatal checkup on 9th of every month', 'Free comprehensive antenatal checkup blood test ultrasound on 9th of every month',
        'OFFLINE', 'Visit nearest government health facility on 9th of month', 'https://pmsma.nhm.gov.in',
        18, 130, NULL, FALSE, 'ALL', '2016-06-09', NULL, TRUE
    ) ON CONFLICT (code) DO UPDATE SET
        name = EXCLUDED.name, short_description = EXCLUDED.short_description, benefits = EXCLUDED.benefits,
        official_url = EXCLUDED.official_url, max_income = EXCLUDED.max_income, target_state = EXCLUDED.target_state,
        updated_at = CURRENT_TIMESTAMP
    RETURNING id INTO v_scheme_id;

    DELETE FROM yojna_setu.scheme_castes WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_genders WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_occupations WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_religions WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_documents WHERE scheme_id = v_scheme_id;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'SC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'ST') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'OBC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'GENERAL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_genders (scheme_id, gender) VALUES (v_scheme_id, 'FEMALE') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_occupations (scheme_id, occupation) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_religions (scheme_id, religion) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Aadhaar Card', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Pregnancy proof', TRUE);

    -- Scheme #10: Post Matric SC Scholarship
    INSERT INTO yojna_setu.schemes (
        code, name, ministry, category, short_description, benefits,
        application_mode, application_process, official_url,
        min_age, max_age, max_income, requires_disability, target_state, start_date, end_date, is_active
    ) VALUES (
        'POST-MATRIC-SC-SCHOLARSHIP', 'Post Matric SC Scholarship', 'Ministry of Social Justice', 'CENTRAL_GOVERNMENT', 'Scholarship for SC students at post matriculation level', 'Full tuition fee plus maintenance allowance Rs 380-1200 per month',
        'ONLINE', 'Apply on scholarships.gov.in before October 31', 'https://scholarships.gov.in',
        15, 30, 250000, FALSE, 'ALL', '2022-07-01', '2026-10-31', TRUE
    ) ON CONFLICT (code) DO UPDATE SET
        name = EXCLUDED.name, short_description = EXCLUDED.short_description, benefits = EXCLUDED.benefits,
        official_url = EXCLUDED.official_url, max_income = EXCLUDED.max_income, target_state = EXCLUDED.target_state,
        updated_at = CURRENT_TIMESTAMP
    RETURNING id INTO v_scheme_id;

    DELETE FROM yojna_setu.scheme_castes WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_genders WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_occupations WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_religions WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_documents WHERE scheme_id = v_scheme_id;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'SC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_genders (scheme_id, gender) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_occupations (scheme_id, occupation) VALUES (v_scheme_id, 'STUDENT') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_religions (scheme_id, religion) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Aadhaar Card', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Caste Certificate', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Income Certificate', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Previous Marksheet', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Bank Passbook', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Bonafide Certificate', TRUE);

    -- Scheme #11: Post Matric ST Scholarship
    INSERT INTO yojna_setu.schemes (
        code, name, ministry, category, short_description, benefits,
        application_mode, application_process, official_url,
        min_age, max_age, max_income, requires_disability, target_state, start_date, end_date, is_active
    ) VALUES (
        'POST-MATRIC-ST-SCHOLARSHIP', 'Post Matric ST Scholarship', 'Ministry of Tribal Affairs', 'CENTRAL_GOVERNMENT', 'Scholarship for ST students at post matriculation level', 'Full tuition fee plus maintenance allowance',
        'ONLINE', 'Apply on scholarships.gov.in before October 31', 'https://scholarships.gov.in',
        15, 30, 250000, FALSE, 'ALL', '2022-07-01', '2026-10-31', TRUE
    ) ON CONFLICT (code) DO UPDATE SET
        name = EXCLUDED.name, short_description = EXCLUDED.short_description, benefits = EXCLUDED.benefits,
        official_url = EXCLUDED.official_url, max_income = EXCLUDED.max_income, target_state = EXCLUDED.target_state,
        updated_at = CURRENT_TIMESTAMP
    RETURNING id INTO v_scheme_id;

    DELETE FROM yojna_setu.scheme_castes WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_genders WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_occupations WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_religions WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_documents WHERE scheme_id = v_scheme_id;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'ST') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_genders (scheme_id, gender) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_occupations (scheme_id, occupation) VALUES (v_scheme_id, 'STUDENT') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_religions (scheme_id, religion) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Aadhaar Card', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Caste Certificate', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Income Certificate', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Previous Marksheet', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Bank Passbook', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Bonafide Certificate', TRUE);

    -- Scheme #12: Post Matric OBC Scholarship
    INSERT INTO yojna_setu.schemes (
        code, name, ministry, category, short_description, benefits,
        application_mode, application_process, official_url,
        min_age, max_age, max_income, requires_disability, target_state, start_date, end_date, is_active
    ) VALUES (
        'POST-MATRIC-OBC-SCHOLARSHIP', 'Post Matric OBC Scholarship', 'Ministry of Social Justice', 'CENTRAL_GOVERNMENT', 'Scholarship for OBC students at post matriculation level', 'Tuition fee and maintenance allowance for post matric education',
        'ONLINE', 'Apply on scholarships.gov.in', 'https://scholarships.gov.in',
        15, 30, 300000, FALSE, 'ALL', '2022-07-01', '2026-10-31', TRUE
    ) ON CONFLICT (code) DO UPDATE SET
        name = EXCLUDED.name, short_description = EXCLUDED.short_description, benefits = EXCLUDED.benefits,
        official_url = EXCLUDED.official_url, max_income = EXCLUDED.max_income, target_state = EXCLUDED.target_state,
        updated_at = CURRENT_TIMESTAMP
    RETURNING id INTO v_scheme_id;

    DELETE FROM yojna_setu.scheme_castes WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_genders WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_occupations WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_religions WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_documents WHERE scheme_id = v_scheme_id;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'OBC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_genders (scheme_id, gender) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_occupations (scheme_id, occupation) VALUES (v_scheme_id, 'STUDENT') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_religions (scheme_id, religion) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Aadhaar Card', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'OBC Certificate', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Income Certificate', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Previous Marksheet', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Bank Passbook', TRUE);

    -- Scheme #13: National Means Cum Merit Scholarship
    INSERT INTO yojna_setu.schemes (
        code, name, ministry, category, short_description, benefits,
        application_mode, application_process, official_url,
        min_age, max_age, max_income, requires_disability, target_state, start_date, end_date, is_active
    ) VALUES (
        'NATIONAL-MEANS-CUM-MERIT-SCHOLARSHIP', 'National Means Cum Merit Scholarship', 'Ministry of Education', 'CENTRAL_GOVERNMENT', 'Scholarship for meritorious students from economically weaker sections', 'Rs 12000 per year for class 9 to 12 students',
        'ONLINE', 'Apply after qualifying NMMS exam', 'https://scholarships.gov.in',
        13, 18, 350000, FALSE, 'ALL', '2008-05-15', NULL, TRUE
    ) ON CONFLICT (code) DO UPDATE SET
        name = EXCLUDED.name, short_description = EXCLUDED.short_description, benefits = EXCLUDED.benefits,
        official_url = EXCLUDED.official_url, max_income = EXCLUDED.max_income, target_state = EXCLUDED.target_state,
        updated_at = CURRENT_TIMESTAMP
    RETURNING id INTO v_scheme_id;

    DELETE FROM yojna_setu.scheme_castes WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_genders WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_occupations WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_religions WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_documents WHERE scheme_id = v_scheme_id;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'SC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'ST') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'OBC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'GENERAL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_genders (scheme_id, gender) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_occupations (scheme_id, occupation) VALUES (v_scheme_id, 'STUDENT') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_religions (scheme_id, religion) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Aadhaar Card', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Income Certificate', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Class 7 Marksheet', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Bank Passbook', TRUE);

    -- Scheme #14: Central Sector Scholarship
    INSERT INTO yojna_setu.schemes (
        code, name, ministry, category, short_description, benefits,
        application_mode, application_process, official_url,
        min_age, max_age, max_income, requires_disability, target_state, start_date, end_date, is_active
    ) VALUES (
        'CENTRAL-SECTOR-SCHOLARSHIP', 'Central Sector Scholarship', 'Ministry of Education', 'CENTRAL_GOVERNMENT', 'Scholarship for students in top 20 percentile of class 12', 'Rs 12000 per year for UG Rs 20000 per year for PG',
        'ONLINE', 'Apply on scholarships.gov.in within 3 months of admission', 'https://scholarships.gov.in',
        17, 25, 800000, FALSE, 'ALL', '2008-01-01', NULL, TRUE
    ) ON CONFLICT (code) DO UPDATE SET
        name = EXCLUDED.name, short_description = EXCLUDED.short_description, benefits = EXCLUDED.benefits,
        official_url = EXCLUDED.official_url, max_income = EXCLUDED.max_income, target_state = EXCLUDED.target_state,
        updated_at = CURRENT_TIMESTAMP
    RETURNING id INTO v_scheme_id;

    DELETE FROM yojna_setu.scheme_castes WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_genders WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_occupations WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_religions WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_documents WHERE scheme_id = v_scheme_id;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'SC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'ST') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'OBC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'GENERAL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_genders (scheme_id, gender) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_occupations (scheme_id, occupation) VALUES (v_scheme_id, 'STUDENT') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_religions (scheme_id, religion) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Aadhaar Card', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Class 12 Marksheet', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Income Certificate', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Bank Passbook', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Admission Letter', TRUE);

    -- Scheme #15: PM Vidya Lakshmi
    INSERT INTO yojna_setu.schemes (
        code, name, ministry, category, short_description, benefits,
        application_mode, application_process, official_url,
        min_age, max_age, max_income, requires_disability, target_state, start_date, end_date, is_active
    ) VALUES (
        'PM-VIDYA-LAKSHMI', 'PM Vidya Lakshmi', 'Ministry of Education', 'CENTRAL_GOVERNMENT', 'Education loan at subsidized interest for higher education', 'Education loans up to Rs 7.5 lakh without collateral at subsidized rates',
        'ONLINE', 'Apply on vidyalakshmi.co.in and choose from multiple banks', 'https://vidyalakshmi.co.in',
        18, 35, NULL, FALSE, 'ALL', '2015-08-15', NULL, TRUE
    ) ON CONFLICT (code) DO UPDATE SET
        name = EXCLUDED.name, short_description = EXCLUDED.short_description, benefits = EXCLUDED.benefits,
        official_url = EXCLUDED.official_url, max_income = EXCLUDED.max_income, target_state = EXCLUDED.target_state,
        updated_at = CURRENT_TIMESTAMP
    RETURNING id INTO v_scheme_id;

    DELETE FROM yojna_setu.scheme_castes WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_genders WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_occupations WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_religions WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_documents WHERE scheme_id = v_scheme_id;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'SC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'ST') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'OBC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'GENERAL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_genders (scheme_id, gender) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_occupations (scheme_id, occupation) VALUES (v_scheme_id, 'STUDENT') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_religions (scheme_id, religion) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Aadhaar Card', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Admission Letter', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Academic Records', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Income Certificate', TRUE);

    -- Scheme #16: Ishan Uday Scholarship NE
    INSERT INTO yojna_setu.schemes (
        code, name, ministry, category, short_description, benefits,
        application_mode, application_process, official_url,
        min_age, max_age, max_income, requires_disability, target_state, start_date, end_date, is_active
    ) VALUES (
        'ISHAN-UDAY-SCHOLARSHIP-NE', 'Ishan Uday Scholarship NE', 'Ministry of Education', 'STATE_GOVERNMENT', 'Special scholarship for students from North East region', 'Rs 5400 per month for general courses Rs 7800 for technical courses',
        'ONLINE', 'Apply on scholarships.gov.in', 'https://scholarships.gov.in',
        17, 30, 600000, FALSE, 'Assam,Meghalaya,Manipur,Mizoram,Nagaland,Tripura,Arunachal Pradesh,Sikkim', '2014-01-01', NULL, TRUE
    ) ON CONFLICT (code) DO UPDATE SET
        name = EXCLUDED.name, short_description = EXCLUDED.short_description, benefits = EXCLUDED.benefits,
        official_url = EXCLUDED.official_url, max_income = EXCLUDED.max_income, target_state = EXCLUDED.target_state,
        updated_at = CURRENT_TIMESTAMP
    RETURNING id INTO v_scheme_id;

    DELETE FROM yojna_setu.scheme_castes WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_genders WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_occupations WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_religions WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_documents WHERE scheme_id = v_scheme_id;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'SC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'ST') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'OBC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'GENERAL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_genders (scheme_id, gender) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_occupations (scheme_id, occupation) VALUES (v_scheme_id, 'STUDENT') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_religions (scheme_id, religion) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Aadhaar Card', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Income Certificate', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Domicile Certificate', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Admission Letter', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Marksheet', TRUE);

    -- Scheme #17: Tata Capital Pankh Scholarship
    INSERT INTO yojna_setu.schemes (
        code, name, ministry, category, short_description, benefits,
        application_mode, application_process, official_url,
        min_age, max_age, max_income, requires_disability, target_state, start_date, end_date, is_active
    ) VALUES (
        'TATA-CAPITAL-PANKH-SCHOLARSHIP', 'Tata Capital Pankh Scholarship', 'Tata Capital (Private)', 'PRIVATE', 'Scholarship for students from low income families for higher education', 'Up to Rs 50000 per year for tuition and other education expenses',
        'ONLINE', 'Apply on buddy4study.com between August and September', 'https://www.buddy4study.com/tata-capital-pankh-scholarship',
        16, 25, 400000, FALSE, 'ALL', '2025-08-01', '2026-09-30', TRUE
    ) ON CONFLICT (code) DO UPDATE SET
        name = EXCLUDED.name, short_description = EXCLUDED.short_description, benefits = EXCLUDED.benefits,
        official_url = EXCLUDED.official_url, max_income = EXCLUDED.max_income, target_state = EXCLUDED.target_state,
        updated_at = CURRENT_TIMESTAMP
    RETURNING id INTO v_scheme_id;

    DELETE FROM yojna_setu.scheme_castes WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_genders WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_occupations WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_religions WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_documents WHERE scheme_id = v_scheme_id;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'SC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'ST') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'OBC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'GENERAL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_genders (scheme_id, gender) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_occupations (scheme_id, occupation) VALUES (v_scheme_id, 'STUDENT') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_religions (scheme_id, religion) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Aadhaar Card', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Income Certificate', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Previous Marksheet', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Admission Letter', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Bank Passbook', TRUE);

    -- Scheme #18: Reliance Foundation Scholarship UG
    INSERT INTO yojna_setu.schemes (
        code, name, ministry, category, short_description, benefits,
        application_mode, application_process, official_url,
        min_age, max_age, max_income, requires_disability, target_state, start_date, end_date, is_active
    ) VALUES (
        'RELIANCE-FOUNDATION-SCHOLARSHIP-UG', 'Reliance Foundation Scholarship UG', 'Reliance Foundation (Private)', 'PRIVATE', 'Scholarship for outstanding undergraduate students', 'Up to Rs 2 lakh per year plus mentoring and industry exposure',
        'ONLINE', 'Apply on reliancefoundation.org between August and October', 'https://www.reliancefoundation.org/scholarships',
        17, 25, NULL, FALSE, 'ALL', '2025-08-01', '2025-10-07', TRUE
    ) ON CONFLICT (code) DO UPDATE SET
        name = EXCLUDED.name, short_description = EXCLUDED.short_description, benefits = EXCLUDED.benefits,
        official_url = EXCLUDED.official_url, max_income = EXCLUDED.max_income, target_state = EXCLUDED.target_state,
        updated_at = CURRENT_TIMESTAMP
    RETURNING id INTO v_scheme_id;

    DELETE FROM yojna_setu.scheme_castes WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_genders WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_occupations WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_religions WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_documents WHERE scheme_id = v_scheme_id;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'SC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'ST') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'OBC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'GENERAL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_genders (scheme_id, gender) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_occupations (scheme_id, occupation) VALUES (v_scheme_id, 'STUDENT') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_religions (scheme_id, religion) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Aadhaar Card', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Admission Letter', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Class 12 Marksheet', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Bank Passbook', TRUE);

    -- Scheme #19: HDFC Badhte Kadam Scholarship
    INSERT INTO yojna_setu.schemes (
        code, name, ministry, category, short_description, benefits,
        application_mode, application_process, official_url,
        min_age, max_age, max_income, requires_disability, target_state, start_date, end_date, is_active
    ) VALUES (
        'HDFC-BADHTE-KADAM-SCHOLARSHIP', 'HDFC Badhte Kadam Scholarship', 'HDFC Bank (Private)', 'PRIVATE', 'Scholarship for students from disadvantaged backgrounds', 'Up to Rs 1 lakh for all education related expenses',
        'ONLINE', 'Apply on HDFC bank website or buddy4study.com', 'https://www.hdfcbank.com/personal/borrow/popular-loans/educational-loan/badhte-kadam',
        15, 25, 250000, FALSE, 'ALL', '2025-08-01', '2026-03-31', TRUE
    ) ON CONFLICT (code) DO UPDATE SET
        name = EXCLUDED.name, short_description = EXCLUDED.short_description, benefits = EXCLUDED.benefits,
        official_url = EXCLUDED.official_url, max_income = EXCLUDED.max_income, target_state = EXCLUDED.target_state,
        updated_at = CURRENT_TIMESTAMP
    RETURNING id INTO v_scheme_id;

    DELETE FROM yojna_setu.scheme_castes WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_genders WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_occupations WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_religions WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_documents WHERE scheme_id = v_scheme_id;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'SC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'ST') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'OBC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'GENERAL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_genders (scheme_id, gender) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_occupations (scheme_id, occupation) VALUES (v_scheme_id, 'STUDENT') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_religions (scheme_id, religion) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Aadhaar Card', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Income Certificate', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Previous Marksheet', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Bank Passbook', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Admission Letter', TRUE);

    -- Scheme #20: Infosys Foundation STEM Stars
    INSERT INTO yojna_setu.schemes (
        code, name, ministry, category, short_description, benefits,
        application_mode, application_process, official_url,
        min_age, max_age, max_income, requires_disability, target_state, start_date, end_date, is_active
    ) VALUES (
        'INFOSYS-FOUNDATION-STEM-STARS', 'Infosys Foundation STEM Stars', 'Infosys Foundation (Private)', 'PRIVATE', 'Scholarship for female students in STEM courses', 'Up to Rs 1 lakh per year for female students in engineering science technology',
        'ONLINE', 'Apply on Infosys Foundation website', 'https://www.infosys.com/infosys-foundation',
        17, 25, 800000, FALSE, 'ALL', '2025-07-01', '2026-01-31', TRUE
    ) ON CONFLICT (code) DO UPDATE SET
        name = EXCLUDED.name, short_description = EXCLUDED.short_description, benefits = EXCLUDED.benefits,
        official_url = EXCLUDED.official_url, max_income = EXCLUDED.max_income, target_state = EXCLUDED.target_state,
        updated_at = CURRENT_TIMESTAMP
    RETURNING id INTO v_scheme_id;

    DELETE FROM yojna_setu.scheme_castes WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_genders WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_occupations WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_religions WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_documents WHERE scheme_id = v_scheme_id;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'SC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'ST') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'OBC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'GENERAL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_genders (scheme_id, gender) VALUES (v_scheme_id, 'FEMALE') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_occupations (scheme_id, occupation) VALUES (v_scheme_id, 'STUDENT') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_religions (scheme_id, religion) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Aadhaar Card', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Admission Letter', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Class 12 Marksheet', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Income Certificate', TRUE);

    -- Scheme #21: SBI Asha Scholarship
    INSERT INTO yojna_setu.schemes (
        code, name, ministry, category, short_description, benefits,
        application_mode, application_process, official_url,
        min_age, max_age, max_income, requires_disability, target_state, start_date, end_date, is_active
    ) VALUES (
        'SBI-ASHA-SCHOLARSHIP', 'SBI Asha Scholarship', 'SBI Foundation (Private)', 'PRIVATE', 'Scholarship for meritorious students from low income families', 'Rs 15000 to Rs 20 lakh depending on course and institution',
        'ONLINE', 'Apply on SBI Foundation website between July and November', 'https://www.sbifoundation.in',
        15, 25, 600000, FALSE, 'ALL', '2025-07-01', '2025-11-30', TRUE
    ) ON CONFLICT (code) DO UPDATE SET
        name = EXCLUDED.name, short_description = EXCLUDED.short_description, benefits = EXCLUDED.benefits,
        official_url = EXCLUDED.official_url, max_income = EXCLUDED.max_income, target_state = EXCLUDED.target_state,
        updated_at = CURRENT_TIMESTAMP
    RETURNING id INTO v_scheme_id;

    DELETE FROM yojna_setu.scheme_castes WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_genders WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_occupations WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_religions WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_documents WHERE scheme_id = v_scheme_id;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'SC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'ST') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'OBC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'GENERAL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_genders (scheme_id, gender) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_occupations (scheme_id, occupation) VALUES (v_scheme_id, 'STUDENT') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_religions (scheme_id, religion) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Aadhaar Card', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Income Certificate', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Previous Marksheet', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Bank Passbook', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Admission Letter', TRUE);

    -- Scheme #22: Aditya Birla Scholarship
    INSERT INTO yojna_setu.schemes (
        code, name, ministry, category, short_description, benefits,
        application_mode, application_process, official_url,
        min_age, max_age, max_income, requires_disability, target_state, start_date, end_date, is_active
    ) VALUES (
        'ADITYA-BIRLA-SCHOLARSHIP', 'Aditya Birla Scholarship', 'Aditya Birla Group (Private)', 'PRIVATE', 'Scholarship for students in IIT IIM and other top institutions', 'Rs 65000 per year for IIT students Rs 175000 for IIM students',
        'ONLINE', 'Apply on adityabirlascholars.net after getting admission in top institutes', 'https://adityabirlascholars.net',
        17, 25, NULL, FALSE, 'ALL', '2025-08-01', '2025-09-30', TRUE
    ) ON CONFLICT (code) DO UPDATE SET
        name = EXCLUDED.name, short_description = EXCLUDED.short_description, benefits = EXCLUDED.benefits,
        official_url = EXCLUDED.official_url, max_income = EXCLUDED.max_income, target_state = EXCLUDED.target_state,
        updated_at = CURRENT_TIMESTAMP
    RETURNING id INTO v_scheme_id;

    DELETE FROM yojna_setu.scheme_castes WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_genders WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_occupations WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_religions WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_documents WHERE scheme_id = v_scheme_id;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'SC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'ST') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'OBC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'GENERAL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_genders (scheme_id, gender) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_occupations (scheme_id, occupation) VALUES (v_scheme_id, 'STUDENT') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_religions (scheme_id, religion) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Aadhaar Card', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Admission Letter from IIT/IIM/BITS/Law School', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Marksheet', TRUE);

    -- Scheme #23: Bharti Airtel Scholarship
    INSERT INTO yojna_setu.schemes (
        code, name, ministry, category, short_description, benefits,
        application_mode, application_process, official_url,
        min_age, max_age, max_income, requires_disability, target_state, start_date, end_date, is_active
    ) VALUES (
        'BHARTI-AIRTEL-SCHOLARSHIP', 'Bharti Airtel Scholarship', 'Bharti Foundation (Private)', 'PRIVATE', 'Full scholarship for students in top 50 NIRF institutes', '100% tuition hostel mess fees plus laptop in first year',
        'ONLINE', 'Apply through Bharti Foundation website', 'https://www.bhartiairtel.in/bharti-foundation',
        17, 22, 800000, FALSE, 'ALL', '2025-07-01', '2025-10-31', TRUE
    ) ON CONFLICT (code) DO UPDATE SET
        name = EXCLUDED.name, short_description = EXCLUDED.short_description, benefits = EXCLUDED.benefits,
        official_url = EXCLUDED.official_url, max_income = EXCLUDED.max_income, target_state = EXCLUDED.target_state,
        updated_at = CURRENT_TIMESTAMP
    RETURNING id INTO v_scheme_id;

    DELETE FROM yojna_setu.scheme_castes WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_genders WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_occupations WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_religions WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_documents WHERE scheme_id = v_scheme_id;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'SC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'ST') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'OBC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'GENERAL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_genders (scheme_id, gender) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_occupations (scheme_id, occupation) VALUES (v_scheme_id, 'STUDENT') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_religions (scheme_id, religion) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Aadhaar Card', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Admission Letter from top 50 NIRF institute', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Income Certificate', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Marksheet', TRUE);

    -- Scheme #24: Buddy4Study India Foundation Scholarship
    INSERT INTO yojna_setu.schemes (
        code, name, ministry, category, short_description, benefits,
        application_mode, application_process, official_url,
        min_age, max_age, max_income, requires_disability, target_state, start_date, end_date, is_active
    ) VALUES (
        'BUDDY4STUDY-INDIA-FOUNDATION-SCHOLARSHIP', 'Buddy4Study India Foundation Scholarship', 'Buddy4Study (Private)', 'PRIVATE', 'Scholarship aggregator platform with multiple scholarships', 'Various scholarships ranging from Rs 10000 to Rs 2 lakh',
        'ONLINE', 'Register on buddy4study.com and apply for multiple scholarships', 'https://www.buddy4study.com',
        14, 30, 600000, FALSE, 'ALL', '2025-06-01', NULL, TRUE
    ) ON CONFLICT (code) DO UPDATE SET
        name = EXCLUDED.name, short_description = EXCLUDED.short_description, benefits = EXCLUDED.benefits,
        official_url = EXCLUDED.official_url, max_income = EXCLUDED.max_income, target_state = EXCLUDED.target_state,
        updated_at = CURRENT_TIMESTAMP
    RETURNING id INTO v_scheme_id;

    DELETE FROM yojna_setu.scheme_castes WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_genders WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_occupations WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_religions WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_documents WHERE scheme_id = v_scheme_id;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'SC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'ST') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'OBC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'GENERAL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_genders (scheme_id, gender) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_occupations (scheme_id, occupation) VALUES (v_scheme_id, 'STUDENT') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_religions (scheme_id, religion) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Aadhaar Card', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Income Certificate', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Marksheet', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Bank Passbook', TRUE);

    -- Scheme #25: PM Awas Yojana Urban
    INSERT INTO yojna_setu.schemes (
        code, name, ministry, category, short_description, benefits,
        application_mode, application_process, official_url,
        min_age, max_age, max_income, requires_disability, target_state, start_date, end_date, is_active
    ) VALUES (
        'PM-AWAS-YOJANA-URBAN', 'PM Awas Yojana Urban', 'Ministry of Housing', 'CENTRAL_GOVERNMENT', 'Subsidized housing for urban poor', 'Interest subsidy up to Rs 2.67 lakh on home loan or direct assistance up to Rs 1.5 lakh',
        'BOTH', 'Apply through local municipal office or pmaymis.gov.in', 'https://pmaymis.gov.in',
        18, 130, 300000, FALSE, 'ALL', '2015-06-25', NULL, TRUE
    ) ON CONFLICT (code) DO UPDATE SET
        name = EXCLUDED.name, short_description = EXCLUDED.short_description, benefits = EXCLUDED.benefits,
        official_url = EXCLUDED.official_url, max_income = EXCLUDED.max_income, target_state = EXCLUDED.target_state,
        updated_at = CURRENT_TIMESTAMP
    RETURNING id INTO v_scheme_id;

    DELETE FROM yojna_setu.scheme_castes WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_genders WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_occupations WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_religions WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_documents WHERE scheme_id = v_scheme_id;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'SC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'ST') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'OBC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'GENERAL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_genders (scheme_id, gender) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_occupations (scheme_id, occupation) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_religions (scheme_id, religion) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Aadhaar Card', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Income Certificate', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Property Documents', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Bank Passbook', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Passport Photo', TRUE);

    -- Scheme #26: PM Awas Yojana Gramin
    INSERT INTO yojna_setu.schemes (
        code, name, ministry, category, short_description, benefits,
        application_mode, application_process, official_url,
        min_age, max_age, max_income, requires_disability, target_state, start_date, end_date, is_active
    ) VALUES (
        'PM-AWAS-YOJANA-GRAMIN', 'PM Awas Yojana Gramin', 'Ministry of Rural Development', 'CENTRAL_GOVERNMENT', 'Financial assistance for rural house construction', 'Rs 1.2 lakh in plains Rs 1.3 lakh in hilly areas directly in bank account',
        'OFFLINE', 'Apply through gram panchayat office', 'https://pmayg.nic.in',
        18, 130, 200000, FALSE, 'ALL', '2016-11-20', NULL, TRUE
    ) ON CONFLICT (code) DO UPDATE SET
        name = EXCLUDED.name, short_description = EXCLUDED.short_description, benefits = EXCLUDED.benefits,
        official_url = EXCLUDED.official_url, max_income = EXCLUDED.max_income, target_state = EXCLUDED.target_state,
        updated_at = CURRENT_TIMESTAMP
    RETURNING id INTO v_scheme_id;

    DELETE FROM yojna_setu.scheme_castes WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_genders WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_occupations WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_religions WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_documents WHERE scheme_id = v_scheme_id;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'SC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'ST') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'OBC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'GENERAL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_genders (scheme_id, gender) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_occupations (scheme_id, occupation) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_religions (scheme_id, religion) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Aadhaar Card', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'BPL Certificate', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Bank Passbook', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Land Document', TRUE);

    -- Scheme #27: PM Jan Dhan Yojana
    INSERT INTO yojna_setu.schemes (
        code, name, ministry, category, short_description, benefits,
        application_mode, application_process, official_url,
        min_age, max_age, max_income, requires_disability, target_state, start_date, end_date, is_active
    ) VALUES (
        'PM-JAN-DHAN-YOJANA', 'PM Jan Dhan Yojana', 'Ministry of Finance', 'CENTRAL_GOVERNMENT', 'Zero balance bank account for all citizens', 'Zero balance account RuPay debit card Rs 2 lakh accident insurance Rs 10000 overdraft',
        'OFFLINE', 'Visit any bank branch with Aadhaar card', 'https://pmjdy.gov.in',
        18, 130, NULL, FALSE, 'ALL', '2014-08-28', NULL, TRUE
    ) ON CONFLICT (code) DO UPDATE SET
        name = EXCLUDED.name, short_description = EXCLUDED.short_description, benefits = EXCLUDED.benefits,
        official_url = EXCLUDED.official_url, max_income = EXCLUDED.max_income, target_state = EXCLUDED.target_state,
        updated_at = CURRENT_TIMESTAMP
    RETURNING id INTO v_scheme_id;

    DELETE FROM yojna_setu.scheme_castes WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_genders WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_occupations WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_religions WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_documents WHERE scheme_id = v_scheme_id;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'SC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'ST') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'OBC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'GENERAL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_genders (scheme_id, gender) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_occupations (scheme_id, occupation) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_religions (scheme_id, religion) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Aadhaar Card or any government ID', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Passport Photo', TRUE);

    -- Scheme #28: PM Jeevan Jyoti Bima Yojana
    INSERT INTO yojna_setu.schemes (
        code, name, ministry, category, short_description, benefits,
        application_mode, application_process, official_url,
        min_age, max_age, max_income, requires_disability, target_state, start_date, end_date, is_active
    ) VALUES (
        'PM-JEEVAN-JYOTI-BIMA-YOJANA', 'PM Jeevan Jyoti Bima Yojana', 'Ministry of Finance', 'CENTRAL_GOVERNMENT', 'Life insurance at Rs 436 per year', 'Rs 2 lakh life insurance cover at premium of Rs 436 per year auto deducted from bank',
        'OFFLINE', 'Enroll through any bank where you have account', 'https://jansuraksha.gov.in',
        18, 50, NULL, FALSE, 'ALL', '2015-05-09', NULL, TRUE
    ) ON CONFLICT (code) DO UPDATE SET
        name = EXCLUDED.name, short_description = EXCLUDED.short_description, benefits = EXCLUDED.benefits,
        official_url = EXCLUDED.official_url, max_income = EXCLUDED.max_income, target_state = EXCLUDED.target_state,
        updated_at = CURRENT_TIMESTAMP
    RETURNING id INTO v_scheme_id;

    DELETE FROM yojna_setu.scheme_castes WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_genders WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_occupations WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_religions WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_documents WHERE scheme_id = v_scheme_id;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'SC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'ST') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'OBC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'GENERAL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_genders (scheme_id, gender) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_occupations (scheme_id, occupation) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_religions (scheme_id, religion) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Aadhaar Card', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Bank Account', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Mobile Number', TRUE);

    -- Scheme #29: PM Suraksha Bima Yojana
    INSERT INTO yojna_setu.schemes (
        code, name, ministry, category, short_description, benefits,
        application_mode, application_process, official_url,
        min_age, max_age, max_income, requires_disability, target_state, start_date, end_date, is_active
    ) VALUES (
        'PM-SURAKSHA-BIMA-YOJANA', 'PM Suraksha Bima Yojana', 'Ministry of Finance', 'CENTRAL_GOVERNMENT', 'Accident insurance at Rs 20 per year', 'Rs 2 lakh accidental death Rs 1 lakh partial disability at only Rs 20 per year',
        'OFFLINE', 'Enroll through any bank where you have account', 'https://jansuraksha.gov.in',
        18, 70, NULL, FALSE, 'ALL', '2015-05-09', NULL, TRUE
    ) ON CONFLICT (code) DO UPDATE SET
        name = EXCLUDED.name, short_description = EXCLUDED.short_description, benefits = EXCLUDED.benefits,
        official_url = EXCLUDED.official_url, max_income = EXCLUDED.max_income, target_state = EXCLUDED.target_state,
        updated_at = CURRENT_TIMESTAMP
    RETURNING id INTO v_scheme_id;

    DELETE FROM yojna_setu.scheme_castes WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_genders WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_occupations WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_religions WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_documents WHERE scheme_id = v_scheme_id;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'SC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'ST') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'OBC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'GENERAL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_genders (scheme_id, gender) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_occupations (scheme_id, occupation) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_religions (scheme_id, religion) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Aadhaar Card', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Bank Account', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Mobile Number', TRUE);

    -- Scheme #30: Atal Pension Yojana
    INSERT INTO yojna_setu.schemes (
        code, name, ministry, category, short_description, benefits,
        application_mode, application_process, official_url,
        min_age, max_age, max_income, requires_disability, target_state, start_date, end_date, is_active
    ) VALUES (
        'ATAL-PENSION-YOJANA', 'Atal Pension Yojana', 'Ministry of Finance', 'CENTRAL_GOVERNMENT', 'Guaranteed pension for unorganized sector workers', 'Guaranteed pension Rs 1000-5000 per month after age 60 based on contribution',
        'OFFLINE', 'Enroll through bank with Aadhaar and bank account', 'https://npscra.nsdl.co.in',
        18, 40, NULL, FALSE, 'ALL', '2015-06-01', NULL, TRUE
    ) ON CONFLICT (code) DO UPDATE SET
        name = EXCLUDED.name, short_description = EXCLUDED.short_description, benefits = EXCLUDED.benefits,
        official_url = EXCLUDED.official_url, max_income = EXCLUDED.max_income, target_state = EXCLUDED.target_state,
        updated_at = CURRENT_TIMESTAMP
    RETURNING id INTO v_scheme_id;

    DELETE FROM yojna_setu.scheme_castes WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_genders WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_occupations WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_religions WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_documents WHERE scheme_id = v_scheme_id;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'SC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'ST') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'OBC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'GENERAL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_genders (scheme_id, gender) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_occupations (scheme_id, occupation) VALUES (v_scheme_id, 'OTHER') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_occupations (scheme_id, occupation) VALUES (v_scheme_id, 'FARMER') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_occupations (scheme_id, occupation) VALUES (v_scheme_id, 'BUSINESS') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_religions (scheme_id, religion) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Aadhaar Card', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Bank Account', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Mobile Number', TRUE);

    -- Scheme #31: PM Mudra Yojana
    INSERT INTO yojna_setu.schemes (
        code, name, ministry, category, short_description, benefits,
        application_mode, application_process, official_url,
        min_age, max_age, max_income, requires_disability, target_state, start_date, end_date, is_active
    ) VALUES (
        'PM-MUDRA-YOJANA', 'PM Mudra Yojana', 'Ministry of Finance', 'CENTRAL_GOVERNMENT', 'Collateral free business loans up to Rs 10 lakh', 'Shishu up to Rs 50000 Kishore Rs 50000-5 lakh Tarun Rs 5-10 lakh at low interest',
        'OFFLINE', 'Apply at nearest bank NBFC or MFI with business plan', 'https://mudra.org.in',
        18, 130, NULL, FALSE, 'ALL', '2015-04-08', NULL, TRUE
    ) ON CONFLICT (code) DO UPDATE SET
        name = EXCLUDED.name, short_description = EXCLUDED.short_description, benefits = EXCLUDED.benefits,
        official_url = EXCLUDED.official_url, max_income = EXCLUDED.max_income, target_state = EXCLUDED.target_state,
        updated_at = CURRENT_TIMESTAMP
    RETURNING id INTO v_scheme_id;

    DELETE FROM yojna_setu.scheme_castes WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_genders WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_occupations WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_religions WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_documents WHERE scheme_id = v_scheme_id;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'SC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'ST') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'OBC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'GENERAL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_genders (scheme_id, gender) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_occupations (scheme_id, occupation) VALUES (v_scheme_id, 'BUSINESS') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_religions (scheme_id, religion) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Aadhaar Card', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Business Plan', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Bank Statement', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Passport Photo', TRUE);

    -- Scheme #32: Stand Up India
    INSERT INTO yojna_setu.schemes (
        code, name, ministry, category, short_description, benefits,
        application_mode, application_process, official_url,
        min_age, max_age, max_income, requires_disability, target_state, start_date, end_date, is_active
    ) VALUES (
        'STAND-UP-INDIA', 'Stand Up India', 'Ministry of Finance', 'CENTRAL_GOVERNMENT', 'Loans for SC ST and women entrepreneurs', 'Rs 10 lakh to 1 crore bank loan for setting up new enterprise',
        'ONLINE', 'Apply on standupmitra.in or visit bank branch', 'https://standupmitra.in',
        18, 130, NULL, FALSE, 'ALL', '2016-04-05', NULL, TRUE
    ) ON CONFLICT (code) DO UPDATE SET
        name = EXCLUDED.name, short_description = EXCLUDED.short_description, benefits = EXCLUDED.benefits,
        official_url = EXCLUDED.official_url, max_income = EXCLUDED.max_income, target_state = EXCLUDED.target_state,
        updated_at = CURRENT_TIMESTAMP
    RETURNING id INTO v_scheme_id;

    DELETE FROM yojna_setu.scheme_castes WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_genders WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_occupations WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_religions WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_documents WHERE scheme_id = v_scheme_id;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'SC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'ST') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_genders (scheme_id, gender) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_occupations (scheme_id, occupation) VALUES (v_scheme_id, 'BUSINESS') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_religions (scheme_id, religion) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Aadhaar Card', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Caste Certificate', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Business Plan', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Bank Statement', TRUE);

    -- Scheme #33: PM Kaushal Vikas Yojana 4.0
    INSERT INTO yojna_setu.schemes (
        code, name, ministry, category, short_description, benefits,
        application_mode, application_process, official_url,
        min_age, max_age, max_income, requires_disability, target_state, start_date, end_date, is_active
    ) VALUES (
        'PM-KAUSHAL-VIKAS-YOJANA-4-0', 'PM Kaushal Vikas Yojana 4.0', 'Ministry of Skill Development', 'CENTRAL_GOVERNMENT', 'Free skill training with certificate and placement support', 'Free training certificate Rs 8000 stipend and placement assistance',
        'OFFLINE', 'Register at nearest PMKVY training center', 'https://pmkvyofficial.org',
        15, 45, NULL, FALSE, 'ALL', '2022-01-01', NULL, TRUE
    ) ON CONFLICT (code) DO UPDATE SET
        name = EXCLUDED.name, short_description = EXCLUDED.short_description, benefits = EXCLUDED.benefits,
        official_url = EXCLUDED.official_url, max_income = EXCLUDED.max_income, target_state = EXCLUDED.target_state,
        updated_at = CURRENT_TIMESTAMP
    RETURNING id INTO v_scheme_id;

    DELETE FROM yojna_setu.scheme_castes WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_genders WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_occupations WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_religions WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_documents WHERE scheme_id = v_scheme_id;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'SC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'ST') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'OBC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'GENERAL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_genders (scheme_id, gender) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_occupations (scheme_id, occupation) VALUES (v_scheme_id, 'OTHER') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_occupations (scheme_id, occupation) VALUES (v_scheme_id, 'STUDENT') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_religions (scheme_id, religion) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Aadhaar Card', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Bank Passbook', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Passport Photo', TRUE);

    -- Scheme #34: PM Vishwakarma Yojana
    INSERT INTO yojna_setu.schemes (
        code, name, ministry, category, short_description, benefits,
        application_mode, application_process, official_url,
        min_age, max_age, max_income, requires_disability, target_state, start_date, end_date, is_active
    ) VALUES (
        'PM-VISHWAKARMA-YOJANA', 'PM Vishwakarma Yojana', 'Ministry of MSME', 'CENTRAL_GOVERNMENT', 'Support for traditional artisans and craftspeople', 'Rs 15000 toolkit Rs 500 per day training stipend Rs 1 lakh then Rs 2 lakh loan at 5% interest',
        'ONLINE', 'Register on pmvishwakarma.gov.in through CSC', 'https://pmvishwakarma.gov.in',
        18, 130, NULL, FALSE, 'ALL', '2023-09-17', NULL, TRUE
    ) ON CONFLICT (code) DO UPDATE SET
        name = EXCLUDED.name, short_description = EXCLUDED.short_description, benefits = EXCLUDED.benefits,
        official_url = EXCLUDED.official_url, max_income = EXCLUDED.max_income, target_state = EXCLUDED.target_state,
        updated_at = CURRENT_TIMESTAMP
    RETURNING id INTO v_scheme_id;

    DELETE FROM yojna_setu.scheme_castes WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_genders WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_occupations WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_religions WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_documents WHERE scheme_id = v_scheme_id;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'SC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'ST') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'OBC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'GENERAL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_genders (scheme_id, gender) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_occupations (scheme_id, occupation) VALUES (v_scheme_id, 'OTHER') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_occupations (scheme_id, occupation) VALUES (v_scheme_id, 'BUSINESS') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_religions (scheme_id, religion) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Aadhaar Card', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Proof of traditional craft skill', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Bank Passbook', TRUE);

    -- Scheme #35: PMEGP
    INSERT INTO yojna_setu.schemes (
        code, name, ministry, category, short_description, benefits,
        application_mode, application_process, official_url,
        min_age, max_age, max_income, requires_disability, target_state, start_date, end_date, is_active
    ) VALUES (
        'PMEGP', 'PMEGP', 'Ministry of MSME', 'CENTRAL_GOVERNMENT', 'Subsidy for setting up micro enterprises', '15-35% subsidy on project cost up to Rs 50 lakh for manufacturing Rs 20 lakh for services',
        'ONLINE', 'Apply on kviconline.gov.in with project report', 'https://kviconline.gov.in',
        18, 35, NULL, FALSE, 'ALL', '2008-08-15', NULL, TRUE
    ) ON CONFLICT (code) DO UPDATE SET
        name = EXCLUDED.name, short_description = EXCLUDED.short_description, benefits = EXCLUDED.benefits,
        official_url = EXCLUDED.official_url, max_income = EXCLUDED.max_income, target_state = EXCLUDED.target_state,
        updated_at = CURRENT_TIMESTAMP
    RETURNING id INTO v_scheme_id;

    DELETE FROM yojna_setu.scheme_castes WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_genders WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_occupations WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_religions WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_documents WHERE scheme_id = v_scheme_id;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'SC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'ST') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'OBC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'GENERAL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_genders (scheme_id, gender) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_occupations (scheme_id, occupation) VALUES (v_scheme_id, 'BUSINESS') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_occupations (scheme_id, occupation) VALUES (v_scheme_id, 'OTHER') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_religions (scheme_id, religion) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Aadhaar Card', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Project Report', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Qualification Certificate', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Caste Certificate if applicable', TRUE);

    -- Scheme #36: Deen Dayal Upadhyaya Grameen Kaushalya
    INSERT INTO yojna_setu.schemes (
        code, name, ministry, category, short_description, benefits,
        application_mode, application_process, official_url,
        min_age, max_age, max_income, requires_disability, target_state, start_date, end_date, is_active
    ) VALUES (
        'DEEN-DAYAL-UPADHYAYA-GRAMEEN-KAUSHALYA', 'Deen Dayal Upadhyaya Grameen Kaushalya', 'Ministry of Rural Development', 'CENTRAL_GOVERNMENT', 'Free skill training for rural BPL youth with placement', 'Free residential training placement guarantee post placement support for 1 year',
        'OFFLINE', 'Contact nearest DDU-GKY training partner', 'https://ddugky.gov.in',
        15, 35, 200000, FALSE, 'ALL', '2014-09-25', NULL, TRUE
    ) ON CONFLICT (code) DO UPDATE SET
        name = EXCLUDED.name, short_description = EXCLUDED.short_description, benefits = EXCLUDED.benefits,
        official_url = EXCLUDED.official_url, max_income = EXCLUDED.max_income, target_state = EXCLUDED.target_state,
        updated_at = CURRENT_TIMESTAMP
    RETURNING id INTO v_scheme_id;

    DELETE FROM yojna_setu.scheme_castes WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_genders WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_occupations WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_religions WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_documents WHERE scheme_id = v_scheme_id;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'SC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'ST') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'OBC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'GENERAL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_genders (scheme_id, gender) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_occupations (scheme_id, occupation) VALUES (v_scheme_id, 'OTHER') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_occupations (scheme_id, occupation) VALUES (v_scheme_id, 'STUDENT') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_religions (scheme_id, religion) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Aadhaar Card', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'BPL Certificate', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Bank Passbook', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Passport Photo', TRUE);

    -- Scheme #37: Beti Bachao Beti Padhao
    INSERT INTO yojna_setu.schemes (
        code, name, ministry, category, short_description, benefits,
        application_mode, application_process, official_url,
        min_age, max_age, max_income, requires_disability, target_state, start_date, end_date, is_active
    ) VALUES (
        'BETI-BACHAO-BETI-PADHAO', 'Beti Bachao Beti Padhao', 'Ministry of WCD', 'CENTRAL_GOVERNMENT', 'Girl child education and welfare scheme', 'Awareness benefits conditional cash in some states improved welfare services',
        'OFFLINE', 'Contact nearest Anganwadi center', 'https://wcd.nic.in',
        0, 18, NULL, FALSE, 'ALL', '2015-01-22', NULL, TRUE
    ) ON CONFLICT (code) DO UPDATE SET
        name = EXCLUDED.name, short_description = EXCLUDED.short_description, benefits = EXCLUDED.benefits,
        official_url = EXCLUDED.official_url, max_income = EXCLUDED.max_income, target_state = EXCLUDED.target_state,
        updated_at = CURRENT_TIMESTAMP
    RETURNING id INTO v_scheme_id;

    DELETE FROM yojna_setu.scheme_castes WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_genders WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_occupations WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_religions WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_documents WHERE scheme_id = v_scheme_id;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'SC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'ST') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'OBC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'GENERAL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_genders (scheme_id, gender) VALUES (v_scheme_id, 'FEMALE') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_occupations (scheme_id, occupation) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_religions (scheme_id, religion) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Birth Certificate', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Aadhaar Card', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Parents Aadhaar', TRUE);

    -- Scheme #38: Sukanya Samridhi Yojana
    INSERT INTO yojna_setu.schemes (
        code, name, ministry, category, short_description, benefits,
        application_mode, application_process, official_url,
        min_age, max_age, max_income, requires_disability, target_state, start_date, end_date, is_active
    ) VALUES (
        'SUKANYA-SAMRIDHI-YOJANA', 'Sukanya Samridhi Yojana', 'Ministry of Finance', 'CENTRAL_GOVERNMENT', 'High interest savings for girl child education and marriage', '8.2% interest rate tax free maturity amount for education or marriage at age 21',
        'OFFLINE', 'Open account at post office or authorized bank before girl turns 10', 'https://nsiindia.gov.in',
        0, 10, NULL, FALSE, 'ALL', '2015-01-22', NULL, TRUE
    ) ON CONFLICT (code) DO UPDATE SET
        name = EXCLUDED.name, short_description = EXCLUDED.short_description, benefits = EXCLUDED.benefits,
        official_url = EXCLUDED.official_url, max_income = EXCLUDED.max_income, target_state = EXCLUDED.target_state,
        updated_at = CURRENT_TIMESTAMP
    RETURNING id INTO v_scheme_id;

    DELETE FROM yojna_setu.scheme_castes WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_genders WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_occupations WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_religions WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_documents WHERE scheme_id = v_scheme_id;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'SC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'ST') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'OBC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'GENERAL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_genders (scheme_id, gender) VALUES (v_scheme_id, 'FEMALE') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_occupations (scheme_id, occupation) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_religions (scheme_id, religion) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Girl Birth Certificate', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Parents Aadhaar', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Address Proof', TRUE);

    -- Scheme #39: PM Matru Vandana Yojana
    INSERT INTO yojna_setu.schemes (
        code, name, ministry, category, short_description, benefits,
        application_mode, application_process, official_url,
        min_age, max_age, max_income, requires_disability, target_state, start_date, end_date, is_active
    ) VALUES (
        'PM-MATRU-VANDANA-YOJANA', 'PM Matru Vandana Yojana', 'Ministry of WCD', 'CENTRAL_GOVERNMENT', 'Cash incentive for pregnant and lactating mothers', 'Rs 5000 in 3 installments for first live birth Rs 6000 for second if girl child',
        'OFFLINE', 'Register with ASHA worker or Anganwadi within 150 days of pregnancy', 'https://pmmvy.wcd.gov.in',
        19, 130, NULL, FALSE, 'ALL', '2017-01-01', NULL, TRUE
    ) ON CONFLICT (code) DO UPDATE SET
        name = EXCLUDED.name, short_description = EXCLUDED.short_description, benefits = EXCLUDED.benefits,
        official_url = EXCLUDED.official_url, max_income = EXCLUDED.max_income, target_state = EXCLUDED.target_state,
        updated_at = CURRENT_TIMESTAMP
    RETURNING id INTO v_scheme_id;

    DELETE FROM yojna_setu.scheme_castes WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_genders WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_occupations WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_religions WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_documents WHERE scheme_id = v_scheme_id;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'SC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'ST') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'OBC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'GENERAL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_genders (scheme_id, gender) VALUES (v_scheme_id, 'FEMALE') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_occupations (scheme_id, occupation) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_religions (scheme_id, religion) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Aadhaar Card', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Bank Passbook', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'MCP Card', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Mobile Number', TRUE);

    -- Scheme #40: One Stop Centre Sakhi
    INSERT INTO yojna_setu.schemes (
        code, name, ministry, category, short_description, benefits,
        application_mode, application_process, official_url,
        min_age, max_age, max_income, requires_disability, target_state, start_date, end_date, is_active
    ) VALUES (
        'ONE-STOP-CENTRE-SAKHI', 'One Stop Centre Sakhi', 'Ministry of WCD', 'CENTRAL_GOVERNMENT', 'Support for women affected by violence', 'Free shelter medical legal police and psychological support for women in distress',
        'OFFLINE', 'Call helpline 181 or visit nearest Sakhi center', 'https://wcd.nic.in',
        18, 130, NULL, FALSE, 'ALL', '2015-04-01', NULL, TRUE
    ) ON CONFLICT (code) DO UPDATE SET
        name = EXCLUDED.name, short_description = EXCLUDED.short_description, benefits = EXCLUDED.benefits,
        official_url = EXCLUDED.official_url, max_income = EXCLUDED.max_income, target_state = EXCLUDED.target_state,
        updated_at = CURRENT_TIMESTAMP
    RETURNING id INTO v_scheme_id;

    DELETE FROM yojna_setu.scheme_castes WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_genders WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_occupations WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_religions WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_documents WHERE scheme_id = v_scheme_id;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'SC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'ST') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'OBC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'GENERAL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_genders (scheme_id, gender) VALUES (v_scheme_id, 'FEMALE') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_occupations (scheme_id, occupation) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_religions (scheme_id, religion) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'No documents required for emergency help', TRUE);

    -- Scheme #41: PM Ujjwala Yojana 2.0
    INSERT INTO yojna_setu.schemes (
        code, name, ministry, category, short_description, benefits,
        application_mode, application_process, official_url,
        min_age, max_age, max_income, requires_disability, target_state, start_date, end_date, is_active
    ) VALUES (
        'PM-UJJWALA-YOJANA-2-0', 'PM Ujjwala Yojana 2.0', 'Ministry of Petroleum', 'CENTRAL_GOVERNMENT', 'Free LPG connection for BPL women', 'Free LPG connection with first refill free and stove deposit waived',
        'OFFLINE', 'Apply at nearest LPG distributor with BPL card', 'https://pmuy.gov.in',
        18, 130, 200000, FALSE, 'ALL', '2021-08-10', NULL, TRUE
    ) ON CONFLICT (code) DO UPDATE SET
        name = EXCLUDED.name, short_description = EXCLUDED.short_description, benefits = EXCLUDED.benefits,
        official_url = EXCLUDED.official_url, max_income = EXCLUDED.max_income, target_state = EXCLUDED.target_state,
        updated_at = CURRENT_TIMESTAMP
    RETURNING id INTO v_scheme_id;

    DELETE FROM yojna_setu.scheme_castes WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_genders WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_occupations WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_religions WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_documents WHERE scheme_id = v_scheme_id;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'SC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'ST') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'OBC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'GENERAL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_genders (scheme_id, gender) VALUES (v_scheme_id, 'FEMALE') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_occupations (scheme_id, occupation) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_religions (scheme_id, religion) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Aadhaar Card', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'BPL Ration Card', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Bank Passbook', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Passport Photo', TRUE);

    -- Scheme #42: Indira Gandhi Old Age Pension
    INSERT INTO yojna_setu.schemes (
        code, name, ministry, category, short_description, benefits,
        application_mode, application_process, official_url,
        min_age, max_age, max_income, requires_disability, target_state, start_date, end_date, is_active
    ) VALUES (
        'INDIRA-GANDHI-OLD-AGE-PENSION', 'Indira Gandhi Old Age Pension', 'Ministry of Rural Development', 'CENTRAL_GOVERNMENT', 'Monthly pension for BPL elderly citizens', 'Rs 200-500 per month pension directly in bank account',
        'OFFLINE', 'Apply at gram panchayat or municipality office', 'https://nsap.nic.in',
        60, 130, 150000, FALSE, 'ALL', '1995-08-15', NULL, TRUE
    ) ON CONFLICT (code) DO UPDATE SET
        name = EXCLUDED.name, short_description = EXCLUDED.short_description, benefits = EXCLUDED.benefits,
        official_url = EXCLUDED.official_url, max_income = EXCLUDED.max_income, target_state = EXCLUDED.target_state,
        updated_at = CURRENT_TIMESTAMP
    RETURNING id INTO v_scheme_id;

    DELETE FROM yojna_setu.scheme_castes WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_genders WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_occupations WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_religions WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_documents WHERE scheme_id = v_scheme_id;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'SC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'ST') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'OBC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'GENERAL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_genders (scheme_id, gender) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_occupations (scheme_id, occupation) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_religions (scheme_id, religion) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Aadhaar Card', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Age Proof', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'BPL Certificate', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Bank Passbook', TRUE);

    -- Scheme #43: Indira Gandhi Widow Pension
    INSERT INTO yojna_setu.schemes (
        code, name, ministry, category, short_description, benefits,
        application_mode, application_process, official_url,
        min_age, max_age, max_income, requires_disability, target_state, start_date, end_date, is_active
    ) VALUES (
        'INDIRA-GANDHI-WIDOW-PENSION', 'Indira Gandhi Widow Pension', 'Ministry of Rural Development', 'CENTRAL_GOVERNMENT', 'Monthly pension for BPL widows', 'Rs 300 per month pension directly in bank account',
        'OFFLINE', 'Apply at gram panchayat or municipality office', 'https://nsap.nic.in',
        40, 79, 150000, FALSE, 'ALL', '1995-08-15', NULL, TRUE
    ) ON CONFLICT (code) DO UPDATE SET
        name = EXCLUDED.name, short_description = EXCLUDED.short_description, benefits = EXCLUDED.benefits,
        official_url = EXCLUDED.official_url, max_income = EXCLUDED.max_income, target_state = EXCLUDED.target_state,
        updated_at = CURRENT_TIMESTAMP
    RETURNING id INTO v_scheme_id;

    DELETE FROM yojna_setu.scheme_castes WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_genders WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_occupations WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_religions WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_documents WHERE scheme_id = v_scheme_id;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'SC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'ST') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'OBC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'GENERAL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_genders (scheme_id, gender) VALUES (v_scheme_id, 'FEMALE') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_occupations (scheme_id, occupation) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_religions (scheme_id, religion) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Aadhaar Card', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Husband Death Certificate', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'BPL Certificate', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Bank Passbook', TRUE);

    -- Scheme #44: Indira Gandhi Disability Pension
    INSERT INTO yojna_setu.schemes (
        code, name, ministry, category, short_description, benefits,
        application_mode, application_process, official_url,
        min_age, max_age, max_income, requires_disability, target_state, start_date, end_date, is_active
    ) VALUES (
        'INDIRA-GANDHI-DISABILITY-PENSION', 'Indira Gandhi Disability Pension', 'Ministry of Rural Development', 'CENTRAL_GOVERNMENT', 'Monthly pension for severely disabled BPL persons', 'Rs 300 per month pension for persons with 80% or more disability',
        'OFFLINE', 'Apply at gram panchayat or municipality office', 'https://nsap.nic.in',
        18, 79, 150000, TRUE, 'ALL', '2009-11-01', NULL, TRUE
    ) ON CONFLICT (code) DO UPDATE SET
        name = EXCLUDED.name, short_description = EXCLUDED.short_description, benefits = EXCLUDED.benefits,
        official_url = EXCLUDED.official_url, max_income = EXCLUDED.max_income, target_state = EXCLUDED.target_state,
        updated_at = CURRENT_TIMESTAMP
    RETURNING id INTO v_scheme_id;

    DELETE FROM yojna_setu.scheme_castes WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_genders WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_occupations WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_religions WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_documents WHERE scheme_id = v_scheme_id;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'SC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'ST') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'OBC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'GENERAL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_genders (scheme_id, gender) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_occupations (scheme_id, occupation) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_religions (scheme_id, religion) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Aadhaar Card', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Disability Certificate 80% or more', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'BPL Certificate', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Bank Passbook', TRUE);

    -- Scheme #45: Unique Disability ID UDID
    INSERT INTO yojna_setu.schemes (
        code, name, ministry, category, short_description, benefits,
        application_mode, application_process, official_url,
        min_age, max_age, max_income, requires_disability, target_state, start_date, end_date, is_active
    ) VALUES (
        'UNIQUE-DISABILITY-ID-UDID', 'Unique Disability ID UDID', 'Ministry of Social Justice', 'CENTRAL_GOVERNMENT', 'Disability ID card for accessing all disability benefits', 'UDID card to access all disability schemes and reservations in one place',
        'ONLINE', 'Apply on swavlambancard.gov.in', 'https://swavlambancard.gov.in',
        0, 130, NULL, TRUE, 'ALL', '2016-06-01', NULL, TRUE
    ) ON CONFLICT (code) DO UPDATE SET
        name = EXCLUDED.name, short_description = EXCLUDED.short_description, benefits = EXCLUDED.benefits,
        official_url = EXCLUDED.official_url, max_income = EXCLUDED.max_income, target_state = EXCLUDED.target_state,
        updated_at = CURRENT_TIMESTAMP
    RETURNING id INTO v_scheme_id;

    DELETE FROM yojna_setu.scheme_castes WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_genders WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_occupations WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_religions WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_documents WHERE scheme_id = v_scheme_id;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'SC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'ST') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'OBC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'GENERAL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_genders (scheme_id, gender) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_occupations (scheme_id, occupation) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_religions (scheme_id, religion) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Aadhaar Card', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Disability Certificate from government hospital', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Passport Photo', TRUE);

    -- Scheme #46: Mahatma Gandhi NREGA
    INSERT INTO yojna_setu.schemes (
        code, name, ministry, category, short_description, benefits,
        application_mode, application_process, official_url,
        min_age, max_age, max_income, requires_disability, target_state, start_date, end_date, is_active
    ) VALUES (
        'MAHATMA-GANDHI-NREGA', 'Mahatma Gandhi NREGA', 'Ministry of Rural Development', 'CENTRAL_GOVERNMENT', '100 days guaranteed wage employment for rural households', 'Minimum 100 days wage employment per year at Rs 230-400 per day based on state',
        'OFFLINE', 'Register at gram panchayat to get job card then demand work', 'https://nrega.nic.in',
        18, 130, NULL, FALSE, 'ALL', '2006-02-02', NULL, TRUE
    ) ON CONFLICT (code) DO UPDATE SET
        name = EXCLUDED.name, short_description = EXCLUDED.short_description, benefits = EXCLUDED.benefits,
        official_url = EXCLUDED.official_url, max_income = EXCLUDED.max_income, target_state = EXCLUDED.target_state,
        updated_at = CURRENT_TIMESTAMP
    RETURNING id INTO v_scheme_id;

    DELETE FROM yojna_setu.scheme_castes WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_genders WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_occupations WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_religions WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_documents WHERE scheme_id = v_scheme_id;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'SC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'ST') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'OBC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'GENERAL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_genders (scheme_id, gender) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_occupations (scheme_id, occupation) VALUES (v_scheme_id, 'OTHER') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_occupations (scheme_id, occupation) VALUES (v_scheme_id, 'FARMER') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_religions (scheme_id, religion) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Aadhaar Card', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Bank Passbook', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Job Card', TRUE);

    -- Scheme #47: PM Garib Kalyan Anna Yojana
    INSERT INTO yojna_setu.schemes (
        code, name, ministry, category, short_description, benefits,
        application_mode, application_process, official_url,
        min_age, max_age, max_income, requires_disability, target_state, start_date, end_date, is_active
    ) VALUES (
        'PM-GARIB-KALYAN-ANNA-YOJANA', 'PM Garib Kalyan Anna Yojana', 'Ministry of Consumer Affairs', 'CENTRAL_GOVERNMENT', 'Free food grain for poor families', '5 kg free food grain per person per month under National Food Security Act',
        'OFFLINE', 'Collect from nearest ration shop with ration card', 'https://dfpd.gov.in',
        18, 130, 150000, FALSE, 'ALL', '2020-03-26', NULL, TRUE
    ) ON CONFLICT (code) DO UPDATE SET
        name = EXCLUDED.name, short_description = EXCLUDED.short_description, benefits = EXCLUDED.benefits,
        official_url = EXCLUDED.official_url, max_income = EXCLUDED.max_income, target_state = EXCLUDED.target_state,
        updated_at = CURRENT_TIMESTAMP
    RETURNING id INTO v_scheme_id;

    DELETE FROM yojna_setu.scheme_castes WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_genders WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_occupations WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_religions WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_documents WHERE scheme_id = v_scheme_id;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'SC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'ST') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'OBC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'GENERAL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_genders (scheme_id, gender) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_occupations (scheme_id, occupation) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_religions (scheme_id, religion) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Ration Card', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Aadhaar Card', TRUE);

    -- Scheme #48: Annapurna Scheme
    INSERT INTO yojna_setu.schemes (
        code, name, ministry, category, short_description, benefits,
        application_mode, application_process, official_url,
        min_age, max_age, max_income, requires_disability, target_state, start_date, end_date, is_active
    ) VALUES (
        'ANNAPURNA-SCHEME', 'Annapurna Scheme', 'Ministry of Rural Development', 'CENTRAL_GOVERNMENT', 'Free food grain for senior citizens not covered by pension', '10 kg free food grain per month for eligible senior citizens',
        'OFFLINE', 'Apply at gram panchayat or district food office', 'https://dfpd.gov.in',
        65, 130, NULL, FALSE, 'ALL', '2000-04-01', NULL, TRUE
    ) ON CONFLICT (code) DO UPDATE SET
        name = EXCLUDED.name, short_description = EXCLUDED.short_description, benefits = EXCLUDED.benefits,
        official_url = EXCLUDED.official_url, max_income = EXCLUDED.max_income, target_state = EXCLUDED.target_state,
        updated_at = CURRENT_TIMESTAMP
    RETURNING id INTO v_scheme_id;

    DELETE FROM yojna_setu.scheme_castes WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_genders WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_occupations WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_religions WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_documents WHERE scheme_id = v_scheme_id;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'SC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'ST') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'OBC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'GENERAL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_genders (scheme_id, gender) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_occupations (scheme_id, occupation) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_religions (scheme_id, religion) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Aadhaar Card', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Age Proof', TRUE);

    -- Scheme #49: Startup India Seed Fund
    INSERT INTO yojna_setu.schemes (
        code, name, ministry, category, short_description, benefits,
        application_mode, application_process, official_url,
        min_age, max_age, max_income, requires_disability, target_state, start_date, end_date, is_active
    ) VALUES (
        'STARTUP-INDIA-SEED-FUND', 'Startup India Seed Fund', 'Ministry of Commerce', 'CENTRAL_GOVERNMENT', 'Funding support for early stage startups', 'Up to Rs 20 lakh grant and Rs 50 lakh convertible debentures for startups',
        'ONLINE', 'Register on startupindia.gov.in and apply for seed fund', 'https://startupindia.gov.in',
        18, 45, NULL, FALSE, 'ALL', '2021-04-01', NULL, TRUE
    ) ON CONFLICT (code) DO UPDATE SET
        name = EXCLUDED.name, short_description = EXCLUDED.short_description, benefits = EXCLUDED.benefits,
        official_url = EXCLUDED.official_url, max_income = EXCLUDED.max_income, target_state = EXCLUDED.target_state,
        updated_at = CURRENT_TIMESTAMP
    RETURNING id INTO v_scheme_id;

    DELETE FROM yojna_setu.scheme_castes WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_genders WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_occupations WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_religions WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_documents WHERE scheme_id = v_scheme_id;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'SC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'ST') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'OBC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'GENERAL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_genders (scheme_id, gender) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_occupations (scheme_id, occupation) VALUES (v_scheme_id, 'BUSINESS') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_religions (scheme_id, religion) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Aadhaar Card', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'DPIIT Registration', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Business Plan', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Bank Account', TRUE);

    -- Scheme #50: PM SVANidhi
    INSERT INTO yojna_setu.schemes (
        code, name, ministry, category, short_description, benefits,
        application_mode, application_process, official_url,
        min_age, max_age, max_income, requires_disability, target_state, start_date, end_date, is_active
    ) VALUES (
        'PM-SVANIDHI', 'PM SVANidhi', 'Ministry of Housing', 'CENTRAL_GOVERNMENT', 'Working capital loan for street vendors', 'Rs 10000 then Rs 20000 then Rs 50000 collateral free loan at subsidized interest',
        'ONLINE', 'Apply on pmsvanidhi.mohua.gov.in or through urban local body', 'https://pmsvanidhi.mohua.gov.in',
        18, 130, NULL, FALSE, 'ALL', '2020-06-01', NULL, TRUE
    ) ON CONFLICT (code) DO UPDATE SET
        name = EXCLUDED.name, short_description = EXCLUDED.short_description, benefits = EXCLUDED.benefits,
        official_url = EXCLUDED.official_url, max_income = EXCLUDED.max_income, target_state = EXCLUDED.target_state,
        updated_at = CURRENT_TIMESTAMP
    RETURNING id INTO v_scheme_id;

    DELETE FROM yojna_setu.scheme_castes WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_genders WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_occupations WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_religions WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_documents WHERE scheme_id = v_scheme_id;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'SC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'ST') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'OBC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'GENERAL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_genders (scheme_id, gender) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_occupations (scheme_id, occupation) VALUES (v_scheme_id, 'BUSINESS') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_occupations (scheme_id, occupation) VALUES (v_scheme_id, 'OTHER') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_religions (scheme_id, religion) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Aadhaar Card', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Vending Certificate or Letter of Recommendation', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Bank Passbook', TRUE);

    -- Scheme #51: Venture Capital Fund for SC
    INSERT INTO yojna_setu.schemes (
        code, name, ministry, category, short_description, benefits,
        application_mode, application_process, official_url,
        min_age, max_age, max_income, requires_disability, target_state, start_date, end_date, is_active
    ) VALUES (
        'VENTURE-CAPITAL-FUND-FOR-SC', 'Venture Capital Fund for SC', 'Ministry of Social Justice', 'CENTRAL_GOVERNMENT', 'Equity funding for SC entrepreneurs', 'Concessional finance up to Rs 15 lakh at 4% interest for SC entrepreneurs',
        'OFFLINE', 'Contact National Scheduled Castes Finance Corporation', 'https://socialjustice.gov.in',
        18, 130, NULL, FALSE, 'ALL', '2014-01-01', NULL, TRUE
    ) ON CONFLICT (code) DO UPDATE SET
        name = EXCLUDED.name, short_description = EXCLUDED.short_description, benefits = EXCLUDED.benefits,
        official_url = EXCLUDED.official_url, max_income = EXCLUDED.max_income, target_state = EXCLUDED.target_state,
        updated_at = CURRENT_TIMESTAMP
    RETURNING id INTO v_scheme_id;

    DELETE FROM yojna_setu.scheme_castes WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_genders WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_occupations WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_religions WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_documents WHERE scheme_id = v_scheme_id;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'SC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_genders (scheme_id, gender) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_occupations (scheme_id, occupation) VALUES (v_scheme_id, 'BUSINESS') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_religions (scheme_id, religion) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Aadhaar Card', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Caste Certificate', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Business Plan', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Company Registration', TRUE);

    -- Scheme #52: National Overseas Scholarship SC ST
    INSERT INTO yojna_setu.schemes (
        code, name, ministry, category, short_description, benefits,
        application_mode, application_process, official_url,
        min_age, max_age, max_income, requires_disability, target_state, start_date, end_date, is_active
    ) VALUES (
        'NATIONAL-OVERSEAS-SCHOLARSHIP-SC-ST', 'National Overseas Scholarship SC ST', 'Ministry of Social Justice', 'CENTRAL_GOVERNMENT', 'Scholarship for SC ST students to study abroad', 'Full financial support for masters and PhD abroad including tuition living expenses airfare',
        'ONLINE', 'Apply on nosmsje.gov.in when notification released', 'https://nosmsje.gov.in',
        18, 35, 600000, FALSE, 'ALL', '2022-01-01', NULL, TRUE
    ) ON CONFLICT (code) DO UPDATE SET
        name = EXCLUDED.name, short_description = EXCLUDED.short_description, benefits = EXCLUDED.benefits,
        official_url = EXCLUDED.official_url, max_income = EXCLUDED.max_income, target_state = EXCLUDED.target_state,
        updated_at = CURRENT_TIMESTAMP
    RETURNING id INTO v_scheme_id;

    DELETE FROM yojna_setu.scheme_castes WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_genders WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_occupations WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_religions WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_documents WHERE scheme_id = v_scheme_id;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'SC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'ST') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_genders (scheme_id, gender) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_occupations (scheme_id, occupation) VALUES (v_scheme_id, 'STUDENT') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_religions (scheme_id, religion) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Aadhaar Card', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Caste Certificate', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Admission Letter from foreign university', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Income Certificate', TRUE);

    -- Scheme #53: Eklavya Residential School Scheme
    INSERT INTO yojna_setu.schemes (
        code, name, ministry, category, short_description, benefits,
        application_mode, application_process, official_url,
        min_age, max_age, max_income, requires_disability, target_state, start_date, end_date, is_active
    ) VALUES (
        'EKLAVYA-RESIDENTIAL-SCHOOL-SCHEME', 'Eklavya Residential School Scheme', 'Ministry of Tribal Affairs', 'CENTRAL_GOVERNMENT', 'Free residential school for ST students in tribal areas', 'Free quality residential education from class 6 to 12 with all facilities',
        'OFFLINE', 'Apply through nearest EMRS school or tribal welfare office', 'https://tribal.nic.in',
        6, 18, NULL, FALSE, 'ALL', '1998-01-01', NULL, TRUE
    ) ON CONFLICT (code) DO UPDATE SET
        name = EXCLUDED.name, short_description = EXCLUDED.short_description, benefits = EXCLUDED.benefits,
        official_url = EXCLUDED.official_url, max_income = EXCLUDED.max_income, target_state = EXCLUDED.target_state,
        updated_at = CURRENT_TIMESTAMP
    RETURNING id INTO v_scheme_id;

    DELETE FROM yojna_setu.scheme_castes WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_genders WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_occupations WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_religions WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_documents WHERE scheme_id = v_scheme_id;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'ST') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_genders (scheme_id, gender) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_occupations (scheme_id, occupation) VALUES (v_scheme_id, 'STUDENT') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_religions (scheme_id, religion) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Aadhaar Card', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Caste Certificate', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Birth Certificate', TRUE);

    -- Scheme #54: e-Shram Card
    INSERT INTO yojna_setu.schemes (
        code, name, ministry, category, short_description, benefits,
        application_mode, application_process, official_url,
        min_age, max_age, max_income, requires_disability, target_state, start_date, end_date, is_active
    ) VALUES (
        'E-SHRAM-CARD', 'e-Shram Card', 'Ministry of Labour', 'CENTRAL_GOVERNMENT', 'Universal identity card for unorganized workers with accident insurance', 'Free e-Shram card with Rs 2 lakh accident insurance and access to 12+ government schemes',
        'ONLINE', 'Register free on eshram.gov.in or nearest CSC center in 5 minutes', 'https://eshram.gov.in',
        16, 59, 180000, FALSE, 'ALL', '2021-08-26', NULL, TRUE
    ) ON CONFLICT (code) DO UPDATE SET
        name = EXCLUDED.name, short_description = EXCLUDED.short_description, benefits = EXCLUDED.benefits,
        official_url = EXCLUDED.official_url, max_income = EXCLUDED.max_income, target_state = EXCLUDED.target_state,
        updated_at = CURRENT_TIMESTAMP
    RETURNING id INTO v_scheme_id;

    DELETE FROM yojna_setu.scheme_castes WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_genders WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_occupations WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_religions WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_documents WHERE scheme_id = v_scheme_id;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'SC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'ST') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'OBC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'GENERAL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_genders (scheme_id, gender) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_occupations (scheme_id, occupation) VALUES (v_scheme_id, 'OTHER') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_occupations (scheme_id, occupation) VALUES (v_scheme_id, 'FARMER') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_religions (scheme_id, religion) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Aadhaar Card', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Bank Passbook', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Mobile Number linked to Aadhaar', TRUE);

    -- Scheme #55: PM Shram Yogi Maandhan
    INSERT INTO yojna_setu.schemes (
        code, name, ministry, category, short_description, benefits,
        application_mode, application_process, official_url,
        min_age, max_age, max_income, requires_disability, target_state, start_date, end_date, is_active
    ) VALUES (
        'PM-SHRAM-YOGI-MAANDHAN', 'PM Shram Yogi Maandhan', 'Ministry of Labour', 'CENTRAL_GOVERNMENT', 'Pension scheme for unorganized sector workers - rickshaw pullers street vendors mazdoor', 'Rs 3000 per month guaranteed pension after age 60 government matches your contribution',
        'OFFLINE', 'Enroll at nearest CSC center with Aadhaar and bank passbook', 'https://maandhan.in',
        18, 40, 180000, FALSE, 'ALL', '2019-02-15', NULL, TRUE
    ) ON CONFLICT (code) DO UPDATE SET
        name = EXCLUDED.name, short_description = EXCLUDED.short_description, benefits = EXCLUDED.benefits,
        official_url = EXCLUDED.official_url, max_income = EXCLUDED.max_income, target_state = EXCLUDED.target_state,
        updated_at = CURRENT_TIMESTAMP
    RETURNING id INTO v_scheme_id;

    DELETE FROM yojna_setu.scheme_castes WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_genders WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_occupations WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_religions WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_documents WHERE scheme_id = v_scheme_id;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'SC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'ST') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'OBC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'GENERAL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_genders (scheme_id, gender) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_occupations (scheme_id, occupation) VALUES (v_scheme_id, 'OTHER') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_occupations (scheme_id, occupation) VALUES (v_scheme_id, 'FARMER') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_religions (scheme_id, religion) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Aadhaar Card', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Bank Passbook', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Mobile Number', TRUE);

    -- Scheme #56: Building Construction Workers Welfare
    INSERT INTO yojna_setu.schemes (
        code, name, ministry, category, short_description, benefits,
        application_mode, application_process, official_url,
        min_age, max_age, max_income, requires_disability, target_state, start_date, end_date, is_active
    ) VALUES (
        'BUILDING-CONSTRUCTION-WORKERS-WELFARE', 'Building Construction Workers Welfare', 'Ministry of Labour', 'CENTRAL_GOVERNMENT', 'Welfare benefits for construction workers registered with BOCW board', 'Pension accident insurance maternity benefit education scholarship housing loan and more',
        'OFFLINE', 'Register at state BOCW welfare board office with proof of 90 days construction work', 'https://bocw.gov.in',
        18, 60, NULL, FALSE, 'ALL', '1996-08-19', NULL, TRUE
    ) ON CONFLICT (code) DO UPDATE SET
        name = EXCLUDED.name, short_description = EXCLUDED.short_description, benefits = EXCLUDED.benefits,
        official_url = EXCLUDED.official_url, max_income = EXCLUDED.max_income, target_state = EXCLUDED.target_state,
        updated_at = CURRENT_TIMESTAMP
    RETURNING id INTO v_scheme_id;

    DELETE FROM yojna_setu.scheme_castes WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_genders WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_occupations WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_religions WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_documents WHERE scheme_id = v_scheme_id;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'SC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'ST') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'OBC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'GENERAL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_genders (scheme_id, gender) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_occupations (scheme_id, occupation) VALUES (v_scheme_id, 'OTHER') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_religions (scheme_id, religion) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Aadhaar Card', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Proof of construction work for 90 days', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Bank Passbook', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Passport Photo', TRUE);

    -- Scheme #57: National Career Service Portal
    INSERT INTO yojna_setu.schemes (
        code, name, ministry, category, short_description, benefits,
        application_mode, application_process, official_url,
        min_age, max_age, max_income, requires_disability, target_state, start_date, end_date, is_active
    ) VALUES (
        'NATIONAL-CAREER-SERVICE-PORTAL', 'National Career Service Portal', 'Ministry of Labour', 'CENTRAL_GOVERNMENT', 'Free government job portal connecting job seekers with employers', 'Free job matching career counseling skill courses and employment fair notifications',
        'ONLINE', 'Register free on ncs.gov.in and upload resume', 'https://ncs.gov.in',
        18, 130, NULL, FALSE, 'ALL', '2015-07-20', NULL, TRUE
    ) ON CONFLICT (code) DO UPDATE SET
        name = EXCLUDED.name, short_description = EXCLUDED.short_description, benefits = EXCLUDED.benefits,
        official_url = EXCLUDED.official_url, max_income = EXCLUDED.max_income, target_state = EXCLUDED.target_state,
        updated_at = CURRENT_TIMESTAMP
    RETURNING id INTO v_scheme_id;

    DELETE FROM yojna_setu.scheme_castes WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_genders WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_occupations WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_religions WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_documents WHERE scheme_id = v_scheme_id;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'SC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'ST') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'OBC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'GENERAL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_genders (scheme_id, gender) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_occupations (scheme_id, occupation) VALUES (v_scheme_id, 'OTHER') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_occupations (scheme_id, occupation) VALUES (v_scheme_id, 'STUDENT') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_religions (scheme_id, religion) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Aadhaar Card', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Educational Certificates', TRUE);

    -- Scheme #58: Employment Linked Incentive Scheme
    INSERT INTO yojna_setu.schemes (
        code, name, ministry, category, short_description, benefits,
        application_mode, application_process, official_url,
        min_age, max_age, max_income, requires_disability, target_state, start_date, end_date, is_active
    ) VALUES (
        'EMPLOYMENT-LINKED-INCENTIVE-SCHEME', 'Employment Linked Incentive Scheme', 'Ministry of Labour', 'CENTRAL_GOVERNMENT', 'Rs 15000 for first time employees joining formal workforce', 'One month salary up to Rs 15000 for first time EPFO registered employees',
        'ONLINE', 'Employer registers on EPFO portal benefit credited automatically', 'https://labour.gov.in',
        18, 35, NULL, FALSE, 'ALL', '2024-08-01', NULL, TRUE
    ) ON CONFLICT (code) DO UPDATE SET
        name = EXCLUDED.name, short_description = EXCLUDED.short_description, benefits = EXCLUDED.benefits,
        official_url = EXCLUDED.official_url, max_income = EXCLUDED.max_income, target_state = EXCLUDED.target_state,
        updated_at = CURRENT_TIMESTAMP
    RETURNING id INTO v_scheme_id;

    DELETE FROM yojna_setu.scheme_castes WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_genders WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_occupations WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_religions WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_documents WHERE scheme_id = v_scheme_id;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'SC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'ST') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'OBC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'GENERAL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_genders (scheme_id, gender) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_occupations (scheme_id, occupation) VALUES (v_scheme_id, 'SALARIED') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_religions (scheme_id, religion) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Aadhaar Card', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'EPFO UAN Number', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Bank Passbook', TRUE);

    -- Scheme #59: Pre Matric Minority Scholarship
    INSERT INTO yojna_setu.schemes (
        code, name, ministry, category, short_description, benefits,
        application_mode, application_process, official_url,
        min_age, max_age, max_income, requires_disability, target_state, start_date, end_date, is_active
    ) VALUES (
        'PRE-MATRIC-MINORITY-SCHOLARSHIP', 'Pre Matric Minority Scholarship', 'Ministry of Minority Affairs', 'CENTRAL_GOVERNMENT', 'Scholarship for minority students in class 1 to 10', 'Rs 1000-7000 per year for minority students in class 1 to 10',
        'ONLINE', 'Apply on scholarships.gov.in before October 31', 'https://scholarships.gov.in',
        6, 16, 100000, FALSE, 'ALL', '2022-07-01', '2026-10-31', TRUE
    ) ON CONFLICT (code) DO UPDATE SET
        name = EXCLUDED.name, short_description = EXCLUDED.short_description, benefits = EXCLUDED.benefits,
        official_url = EXCLUDED.official_url, max_income = EXCLUDED.max_income, target_state = EXCLUDED.target_state,
        updated_at = CURRENT_TIMESTAMP
    RETURNING id INTO v_scheme_id;

    DELETE FROM yojna_setu.scheme_castes WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_genders WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_occupations WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_religions WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_documents WHERE scheme_id = v_scheme_id;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'SC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'ST') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'OBC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'GENERAL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_genders (scheme_id, gender) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_occupations (scheme_id, occupation) VALUES (v_scheme_id, 'STUDENT') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_religions (scheme_id, religion) VALUES (v_scheme_id, 'MUSLIM') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_religions (scheme_id, religion) VALUES (v_scheme_id, 'CHRISTIAN') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_religions (scheme_id, religion) VALUES (v_scheme_id, 'SIKH') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_religions (scheme_id, religion) VALUES (v_scheme_id, 'BUDDHIST') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_religions (scheme_id, religion) VALUES (v_scheme_id, 'JAIN') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Aadhaar Card', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Minority Community Certificate', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Income Certificate', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Previous Marksheet', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Bank Passbook', TRUE);

    -- Scheme #60: Post Matric Minority Scholarship
    INSERT INTO yojna_setu.schemes (
        code, name, ministry, category, short_description, benefits,
        application_mode, application_process, official_url,
        min_age, max_age, max_income, requires_disability, target_state, start_date, end_date, is_active
    ) VALUES (
        'POST-MATRIC-MINORITY-SCHOLARSHIP', 'Post Matric Minority Scholarship', 'Ministry of Minority Affairs', 'CENTRAL_GOVERNMENT', 'Scholarship for minority students after class 10', 'Up to Rs 3000 per year maintenance plus course fees for post matric minority students',
        'ONLINE', 'Apply on scholarships.gov.in before October 31', 'https://scholarships.gov.in',
        15, 30, 200000, FALSE, 'ALL', '2022-07-01', '2026-10-31', TRUE
    ) ON CONFLICT (code) DO UPDATE SET
        name = EXCLUDED.name, short_description = EXCLUDED.short_description, benefits = EXCLUDED.benefits,
        official_url = EXCLUDED.official_url, max_income = EXCLUDED.max_income, target_state = EXCLUDED.target_state,
        updated_at = CURRENT_TIMESTAMP
    RETURNING id INTO v_scheme_id;

    DELETE FROM yojna_setu.scheme_castes WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_genders WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_occupations WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_religions WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_documents WHERE scheme_id = v_scheme_id;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'SC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'ST') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'OBC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'GENERAL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_genders (scheme_id, gender) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_occupations (scheme_id, occupation) VALUES (v_scheme_id, 'STUDENT') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_religions (scheme_id, religion) VALUES (v_scheme_id, 'MUSLIM') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_religions (scheme_id, religion) VALUES (v_scheme_id, 'CHRISTIAN') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_religions (scheme_id, religion) VALUES (v_scheme_id, 'SIKH') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_religions (scheme_id, religion) VALUES (v_scheme_id, 'BUDDHIST') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_religions (scheme_id, religion) VALUES (v_scheme_id, 'JAIN') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Aadhaar Card', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Minority Community Certificate', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Income Certificate', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Previous Marksheet', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Bank Passbook', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Bonafide Certificate', TRUE);

    -- Scheme #61: Naya Savera Free Coaching
    INSERT INTO yojna_setu.schemes (
        code, name, ministry, category, short_description, benefits,
        application_mode, application_process, official_url,
        min_age, max_age, max_income, requires_disability, target_state, start_date, end_date, is_active
    ) VALUES (
        'NAYA-SAVERA-FREE-COACHING', 'Naya Savera Free Coaching', 'Ministry of Minority Affairs', 'CENTRAL_GOVERNMENT', 'Free coaching for minority students for competitive exams UPSC SSC IIT', 'Free coaching for government exams UPSC SSC banking technical courses with stipend',
        'OFFLINE', 'Contact nearest Naya Savera coaching center or apply through minority affairs ministry', 'https://minorityaffairs.gov.in',
        18, 35, 600000, FALSE, 'ALL', '2009-01-01', NULL, TRUE
    ) ON CONFLICT (code) DO UPDATE SET
        name = EXCLUDED.name, short_description = EXCLUDED.short_description, benefits = EXCLUDED.benefits,
        official_url = EXCLUDED.official_url, max_income = EXCLUDED.max_income, target_state = EXCLUDED.target_state,
        updated_at = CURRENT_TIMESTAMP
    RETURNING id INTO v_scheme_id;

    DELETE FROM yojna_setu.scheme_castes WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_genders WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_occupations WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_religions WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_documents WHERE scheme_id = v_scheme_id;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'SC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'ST') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'OBC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'GENERAL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_genders (scheme_id, gender) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_occupations (scheme_id, occupation) VALUES (v_scheme_id, 'STUDENT') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_religions (scheme_id, religion) VALUES (v_scheme_id, 'MUSLIM') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_religions (scheme_id, religion) VALUES (v_scheme_id, 'CHRISTIAN') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_religions (scheme_id, religion) VALUES (v_scheme_id, 'SIKH') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_religions (scheme_id, religion) VALUES (v_scheme_id, 'BUDDHIST') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_religions (scheme_id, religion) VALUES (v_scheme_id, 'JAIN') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Aadhaar Card', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Minority Certificate', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Income Certificate', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Educational Qualification', TRUE);

    -- Scheme #62: Nai Udaan UPSC Support
    INSERT INTO yojna_setu.schemes (
        code, name, ministry, category, short_description, benefits,
        application_mode, application_process, official_url,
        min_age, max_age, max_income, requires_disability, target_state, start_date, end_date, is_active
    ) VALUES (
        'NAI-UDAAN-UPSC-SUPPORT', 'Nai Udaan UPSC Support', 'Ministry of Minority Affairs', 'CENTRAL_GOVERNMENT', 'Financial support for minority students who clear UPSC SSC prelims', 'Rs 65000 per year for UPSC mains preparation for minority students clearing prelims',
        'ONLINE', 'Apply through National Minorities Development and Finance Corporation', 'https://minorityaffairs.gov.in',
        21, 35, NULL, FALSE, 'ALL', '2014-01-01', NULL, TRUE
    ) ON CONFLICT (code) DO UPDATE SET
        name = EXCLUDED.name, short_description = EXCLUDED.short_description, benefits = EXCLUDED.benefits,
        official_url = EXCLUDED.official_url, max_income = EXCLUDED.max_income, target_state = EXCLUDED.target_state,
        updated_at = CURRENT_TIMESTAMP
    RETURNING id INTO v_scheme_id;

    DELETE FROM yojna_setu.scheme_castes WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_genders WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_occupations WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_religions WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_documents WHERE scheme_id = v_scheme_id;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'SC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'ST') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'OBC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'GENERAL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_genders (scheme_id, gender) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_occupations (scheme_id, occupation) VALUES (v_scheme_id, 'STUDENT') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_religions (scheme_id, religion) VALUES (v_scheme_id, 'MUSLIM') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_religions (scheme_id, religion) VALUES (v_scheme_id, 'CHRISTIAN') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_religions (scheme_id, religion) VALUES (v_scheme_id, 'SIKH') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_religions (scheme_id, religion) VALUES (v_scheme_id, 'BUDDHIST') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_religions (scheme_id, religion) VALUES (v_scheme_id, 'JAIN') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Aadhaar Card', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Minority Certificate', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'UPSC/SSC Prelims Result', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Bank Passbook', TRUE);

    -- Scheme #63: PM VIKAS Skill Minorities
    INSERT INTO yojna_setu.schemes (
        code, name, ministry, category, short_description, benefits,
        application_mode, application_process, official_url,
        min_age, max_age, max_income, requires_disability, target_state, start_date, end_date, is_active
    ) VALUES (
        'PM-VIKAS-SKILL-MINORITIES', 'PM VIKAS Skill Minorities', 'Ministry of Minority Affairs', 'CENTRAL_GOVERNMENT', 'Free skill training and entrepreneurship for minority youth', 'Free skill training in modern trades with placement support and entrepreneurship development',
        'OFFLINE', 'Contact nearest PM VIKAS training center through minority affairs ministry', 'https://minorityaffairs.gov.in',
        14, 35, NULL, FALSE, 'ALL', '2023-01-01', NULL, TRUE
    ) ON CONFLICT (code) DO UPDATE SET
        name = EXCLUDED.name, short_description = EXCLUDED.short_description, benefits = EXCLUDED.benefits,
        official_url = EXCLUDED.official_url, max_income = EXCLUDED.max_income, target_state = EXCLUDED.target_state,
        updated_at = CURRENT_TIMESTAMP
    RETURNING id INTO v_scheme_id;

    DELETE FROM yojna_setu.scheme_castes WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_genders WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_occupations WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_religions WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_documents WHERE scheme_id = v_scheme_id;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'SC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'ST') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'OBC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'GENERAL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_genders (scheme_id, gender) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_occupations (scheme_id, occupation) VALUES (v_scheme_id, 'OTHER') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_occupations (scheme_id, occupation) VALUES (v_scheme_id, 'STUDENT') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_religions (scheme_id, religion) VALUES (v_scheme_id, 'MUSLIM') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_religions (scheme_id, religion) VALUES (v_scheme_id, 'CHRISTIAN') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_religions (scheme_id, religion) VALUES (v_scheme_id, 'SIKH') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_religions (scheme_id, religion) VALUES (v_scheme_id, 'BUDDHIST') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_religions (scheme_id, religion) VALUES (v_scheme_id, 'JAIN') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Aadhaar Card', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Minority Certificate', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Educational Certificate', TRUE);

    -- Scheme #64: NMDFC Loan Minorities
    INSERT INTO yojna_setu.schemes (
        code, name, ministry, category, short_description, benefits,
        application_mode, application_process, official_url,
        min_age, max_age, max_income, requires_disability, target_state, start_date, end_date, is_active
    ) VALUES (
        'NMDFC-LOAN-MINORITIES', 'NMDFC Loan Minorities', 'Ministry of Minority Affairs', 'CENTRAL_GOVERNMENT', 'Concessional loans for self employment for minority communities', 'Loans up to Rs 20 lakh at 6% interest rate for business education and housing for minorities',
        'OFFLINE', 'Apply through State Channelising Agency or NMDFC website', 'https://nmdfc.org',
        18, 55, 600000, FALSE, 'ALL', '1994-09-01', NULL, TRUE
    ) ON CONFLICT (code) DO UPDATE SET
        name = EXCLUDED.name, short_description = EXCLUDED.short_description, benefits = EXCLUDED.benefits,
        official_url = EXCLUDED.official_url, max_income = EXCLUDED.max_income, target_state = EXCLUDED.target_state,
        updated_at = CURRENT_TIMESTAMP
    RETURNING id INTO v_scheme_id;

    DELETE FROM yojna_setu.scheme_castes WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_genders WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_occupations WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_religions WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_documents WHERE scheme_id = v_scheme_id;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'SC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'ST') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'OBC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'GENERAL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_genders (scheme_id, gender) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_occupations (scheme_id, occupation) VALUES (v_scheme_id, 'BUSINESS') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_occupations (scheme_id, occupation) VALUES (v_scheme_id, 'OTHER') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_religions (scheme_id, religion) VALUES (v_scheme_id, 'MUSLIM') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_religions (scheme_id, religion) VALUES (v_scheme_id, 'CHRISTIAN') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_religions (scheme_id, religion) VALUES (v_scheme_id, 'SIKH') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_religions (scheme_id, religion) VALUES (v_scheme_id, 'BUDDHIST') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_religions (scheme_id, religion) VALUES (v_scheme_id, 'JAIN') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Aadhaar Card', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Minority Certificate', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Income Certificate', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Business Plan', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Bank Passbook', TRUE);

    -- Scheme #65: Nai Roshni Minority Women
    INSERT INTO yojna_setu.schemes (
        code, name, ministry, category, short_description, benefits,
        application_mode, application_process, official_url,
        min_age, max_age, max_income, requires_disability, target_state, start_date, end_date, is_active
    ) VALUES (
        'NAI-ROSHNI-MINORITY-WOMEN', 'Nai Roshni Minority Women', 'Ministry of Minority Affairs', 'CENTRAL_GOVERNMENT', 'Leadership development program for minority women', 'Free training in leadership communication legal rights financial literacy for minority women',
        'OFFLINE', 'Contact nearest NGO implementing Nai Roshni or apply through minority affairs ministry', 'https://minorityaffairs.gov.in',
        18, 65, NULL, FALSE, 'ALL', '2012-01-01', NULL, TRUE
    ) ON CONFLICT (code) DO UPDATE SET
        name = EXCLUDED.name, short_description = EXCLUDED.short_description, benefits = EXCLUDED.benefits,
        official_url = EXCLUDED.official_url, max_income = EXCLUDED.max_income, target_state = EXCLUDED.target_state,
        updated_at = CURRENT_TIMESTAMP
    RETURNING id INTO v_scheme_id;

    DELETE FROM yojna_setu.scheme_castes WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_genders WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_occupations WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_religions WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_documents WHERE scheme_id = v_scheme_id;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'SC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'ST') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'OBC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'GENERAL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_genders (scheme_id, gender) VALUES (v_scheme_id, 'FEMALE') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_occupations (scheme_id, occupation) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_religions (scheme_id, religion) VALUES (v_scheme_id, 'MUSLIM') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_religions (scheme_id, religion) VALUES (v_scheme_id, 'CHRISTIAN') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_religions (scheme_id, religion) VALUES (v_scheme_id, 'SIKH') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_religions (scheme_id, religion) VALUES (v_scheme_id, 'BUDDHIST') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_religions (scheme_id, religion) VALUES (v_scheme_id, 'JAIN') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Aadhaar Card', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Minority Certificate', TRUE);

    -- Scheme #66: Maulana Azad National Fellowship
    INSERT INTO yojna_setu.schemes (
        code, name, ministry, category, short_description, benefits,
        application_mode, application_process, official_url,
        min_age, max_age, max_income, requires_disability, target_state, start_date, end_date, is_active
    ) VALUES (
        'MAULANA-AZAD-NATIONAL-FELLOWSHIP', 'Maulana Azad National Fellowship', 'Ministry of Minority Affairs', 'CENTRAL_GOVERNMENT', 'Fellowship for minority students pursuing MPhil and PhD', 'Fellowship stipend for minority research scholars',
        'ONLINE', 'Apply through UGC portal when notified', 'https://minorityaffairs.gov.in',
        21, 40, NULL, FALSE, 'ALL', '2009-04-01', NULL, TRUE
    ) ON CONFLICT (code) DO UPDATE SET
        name = EXCLUDED.name, short_description = EXCLUDED.short_description, benefits = EXCLUDED.benefits,
        official_url = EXCLUDED.official_url, max_income = EXCLUDED.max_income, target_state = EXCLUDED.target_state,
        updated_at = CURRENT_TIMESTAMP
    RETURNING id INTO v_scheme_id;

    DELETE FROM yojna_setu.scheme_castes WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_genders WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_occupations WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_religions WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_documents WHERE scheme_id = v_scheme_id;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'SC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'ST') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'OBC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'GENERAL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_genders (scheme_id, gender) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_occupations (scheme_id, occupation) VALUES (v_scheme_id, 'STUDENT') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_religions (scheme_id, religion) VALUES (v_scheme_id, 'MUSLIM') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_religions (scheme_id, religion) VALUES (v_scheme_id, 'CHRISTIAN') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_religions (scheme_id, religion) VALUES (v_scheme_id, 'SIKH') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_religions (scheme_id, religion) VALUES (v_scheme_id, 'BUDDHIST') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_religions (scheme_id, religion) VALUES (v_scheme_id, 'JAIN') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Aadhaar Card', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Minority Certificate', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Admission Letter', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Marksheet', TRUE);

    -- Scheme #67: ADIP Assistive Devices
    INSERT INTO yojna_setu.schemes (
        code, name, ministry, category, short_description, benefits,
        application_mode, application_process, official_url,
        min_age, max_age, max_income, requires_disability, target_state, start_date, end_date, is_active
    ) VALUES (
        'ADIP-ASSISTIVE-DEVICES', 'ADIP Assistive Devices', 'Ministry of Social Justice', 'CENTRAL_GOVERNMENT', 'Free assistive devices for disabled persons - wheelchair hearing aid tricycle', 'Free wheelchair tricycle hearing aid artificial limbs crutches visual aids worth Rs 10000-1 lakh',
        'OFFLINE', 'Apply at ALIMCO camp or nearest district rehabilitation center', 'https://alimco.in',
        0, 130, 200000, TRUE, 'ALL', '1981-01-01', NULL, TRUE
    ) ON CONFLICT (code) DO UPDATE SET
        name = EXCLUDED.name, short_description = EXCLUDED.short_description, benefits = EXCLUDED.benefits,
        official_url = EXCLUDED.official_url, max_income = EXCLUDED.max_income, target_state = EXCLUDED.target_state,
        updated_at = CURRENT_TIMESTAMP
    RETURNING id INTO v_scheme_id;

    DELETE FROM yojna_setu.scheme_castes WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_genders WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_occupations WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_religions WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_documents WHERE scheme_id = v_scheme_id;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'SC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'ST') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'OBC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'GENERAL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_genders (scheme_id, gender) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_occupations (scheme_id, occupation) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_religions (scheme_id, religion) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Aadhaar Card', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Disability Certificate 40% or more', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Income Certificate', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Passport Photo', TRUE);

    -- Scheme #68: Scholarship for Disabled Students
    INSERT INTO yojna_setu.schemes (
        code, name, ministry, category, short_description, benefits,
        application_mode, application_process, official_url,
        min_age, max_age, max_income, requires_disability, target_state, start_date, end_date, is_active
    ) VALUES (
        'SCHOLARSHIP-FOR-DISABLED-STUDENTS', 'Scholarship for Disabled Students', 'Ministry of Social Justice', 'CENTRAL_GOVERNMENT', 'Scholarship for students with disabilities', 'Rs 1200 per month stipend plus extra coaching allowance for disabled students',
        'ONLINE', 'Apply on scholarships.gov.in under disabled category', 'https://scholarships.gov.in',
        6, 30, 250000, TRUE, 'ALL', '2014-01-01', NULL, TRUE
    ) ON CONFLICT (code) DO UPDATE SET
        name = EXCLUDED.name, short_description = EXCLUDED.short_description, benefits = EXCLUDED.benefits,
        official_url = EXCLUDED.official_url, max_income = EXCLUDED.max_income, target_state = EXCLUDED.target_state,
        updated_at = CURRENT_TIMESTAMP
    RETURNING id INTO v_scheme_id;

    DELETE FROM yojna_setu.scheme_castes WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_genders WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_occupations WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_religions WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_documents WHERE scheme_id = v_scheme_id;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'SC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'ST') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'OBC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'GENERAL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_genders (scheme_id, gender) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_occupations (scheme_id, occupation) VALUES (v_scheme_id, 'STUDENT') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_religions (scheme_id, religion) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Aadhaar Card', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Disability Certificate 40%', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Income Certificate', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Previous Marksheet', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Bank Passbook', TRUE);

    -- Scheme #69: National Handicapped Finance Corporation Loan
    INSERT INTO yojna_setu.schemes (
        code, name, ministry, category, short_description, benefits,
        application_mode, application_process, official_url,
        min_age, max_age, max_income, requires_disability, target_state, start_date, end_date, is_active
    ) VALUES (
        'NATIONAL-HANDICAPPED-FINANCE-CORPORATION-LOAN', 'National Handicapped Finance Corporation Loan', 'Ministry of Social Justice', 'CENTRAL_GOVERNMENT', 'Concessional loans for disabled persons for self employment', 'Loans up to Rs 25 lakh at 5% interest for disabled persons for business education housing',
        'OFFLINE', 'Apply through State Channelising Agency or NHFDC', 'https://nhfdc.nic.in',
        18, 55, 300000, TRUE, 'ALL', '1997-01-01', NULL, TRUE
    ) ON CONFLICT (code) DO UPDATE SET
        name = EXCLUDED.name, short_description = EXCLUDED.short_description, benefits = EXCLUDED.benefits,
        official_url = EXCLUDED.official_url, max_income = EXCLUDED.max_income, target_state = EXCLUDED.target_state,
        updated_at = CURRENT_TIMESTAMP
    RETURNING id INTO v_scheme_id;

    DELETE FROM yojna_setu.scheme_castes WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_genders WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_occupations WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_religions WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_documents WHERE scheme_id = v_scheme_id;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'SC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'ST') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'OBC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'GENERAL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_genders (scheme_id, gender) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_occupations (scheme_id, occupation) VALUES (v_scheme_id, 'BUSINESS') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_occupations (scheme_id, occupation) VALUES (v_scheme_id, 'OTHER') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_religions (scheme_id, religion) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Aadhaar Card', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Disability Certificate 40%', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Income Certificate', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Business Plan', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Bank Passbook', TRUE);

    -- Scheme #70: Divyangjan Sports Award
    INSERT INTO yojna_setu.schemes (
        code, name, ministry, category, short_description, benefits,
        application_mode, application_process, official_url,
        min_age, max_age, max_income, requires_disability, target_state, start_date, end_date, is_active
    ) VALUES (
        'DIVYANGJAN-SPORTS-AWARD', 'Divyangjan Sports Award', 'Ministry of Sports', 'CENTRAL_GOVERNMENT', 'Financial support and recognition for disabled athletes', 'Cash award Rs 5-75 lakh for para athletes representing India in national international events',
        'OFFLINE', 'Apply through state sports authority or Paralympic committee', 'https://yas.nic.in',
        10, 130, NULL, TRUE, 'ALL', '2000-01-01', NULL, TRUE
    ) ON CONFLICT (code) DO UPDATE SET
        name = EXCLUDED.name, short_description = EXCLUDED.short_description, benefits = EXCLUDED.benefits,
        official_url = EXCLUDED.official_url, max_income = EXCLUDED.max_income, target_state = EXCLUDED.target_state,
        updated_at = CURRENT_TIMESTAMP
    RETURNING id INTO v_scheme_id;

    DELETE FROM yojna_setu.scheme_castes WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_genders WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_occupations WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_religions WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_documents WHERE scheme_id = v_scheme_id;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'SC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'ST') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'OBC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'GENERAL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_genders (scheme_id, gender) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_occupations (scheme_id, occupation) VALUES (v_scheme_id, 'OTHER') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_religions (scheme_id, religion) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Aadhaar Card', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Disability Certificate', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Sports Achievement Certificate', TRUE);

    -- Scheme #71: PM Surya Ghar Muft Bijli
    INSERT INTO yojna_setu.schemes (
        code, name, ministry, category, short_description, benefits,
        application_mode, application_process, official_url,
        min_age, max_age, max_income, requires_disability, target_state, start_date, end_date, is_active
    ) VALUES (
        'PM-SURYA-GHAR-MUFT-BIJLI', 'PM Surya Ghar Muft Bijli', 'Ministry of New and Renewable Energy', 'CENTRAL_GOVERNMENT', 'Free solar rooftop installation with 300 units free electricity per month', '300 units free electricity per month after rooftop solar installation subsidy up to Rs 78000',
        'ONLINE', 'Apply on pmsuryagarh.gov.in and select empanelled vendor', 'https://pmsuryagarh.gov.in',
        18, 130, 150000, FALSE, 'ALL', '2024-02-15', NULL, TRUE
    ) ON CONFLICT (code) DO UPDATE SET
        name = EXCLUDED.name, short_description = EXCLUDED.short_description, benefits = EXCLUDED.benefits,
        official_url = EXCLUDED.official_url, max_income = EXCLUDED.max_income, target_state = EXCLUDED.target_state,
        updated_at = CURRENT_TIMESTAMP
    RETURNING id INTO v_scheme_id;

    DELETE FROM yojna_setu.scheme_castes WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_genders WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_occupations WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_religions WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_documents WHERE scheme_id = v_scheme_id;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'SC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'ST') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'OBC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'GENERAL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_genders (scheme_id, gender) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_occupations (scheme_id, occupation) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_religions (scheme_id, religion) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Aadhaar Card', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Electricity Bill', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Bank Passbook', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Property Document', TRUE);

    -- Scheme #72: Vishwakarma Credit Guarantee
    INSERT INTO yojna_setu.schemes (
        code, name, ministry, category, short_description, benefits,
        application_mode, application_process, official_url,
        min_age, max_age, max_income, requires_disability, target_state, start_date, end_date, is_active
    ) VALUES (
        'VISHWAKARMA-CREDIT-GUARANTEE', 'Vishwakarma Credit Guarantee', 'Ministry of MSME', 'CENTRAL_GOVERNMENT', 'Credit guarantee for traditional craftsmen and artisans', 'Collateral free loan Rs 1 lakh then Rs 2 lakh at 5% interest with credit guarantee',
        'ONLINE', 'First register on pmvishwakarma.gov.in then apply for loan through bank', 'https://pmvishwakarma.gov.in',
        18, 130, NULL, FALSE, 'ALL', '2023-09-17', NULL, TRUE
    ) ON CONFLICT (code) DO UPDATE SET
        name = EXCLUDED.name, short_description = EXCLUDED.short_description, benefits = EXCLUDED.benefits,
        official_url = EXCLUDED.official_url, max_income = EXCLUDED.max_income, target_state = EXCLUDED.target_state,
        updated_at = CURRENT_TIMESTAMP
    RETURNING id INTO v_scheme_id;

    DELETE FROM yojna_setu.scheme_castes WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_genders WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_occupations WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_religions WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_documents WHERE scheme_id = v_scheme_id;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'SC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'ST') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'OBC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'GENERAL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_genders (scheme_id, gender) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_occupations (scheme_id, occupation) VALUES (v_scheme_id, 'OTHER') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_occupations (scheme_id, occupation) VALUES (v_scheme_id, 'BUSINESS') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_religions (scheme_id, religion) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Aadhaar Card', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'PM Vishwakarma Registration', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Bank Passbook', TRUE);

    -- Scheme #73: UP Kanya Sumangala Yojana
    INSERT INTO yojna_setu.schemes (
        code, name, ministry, category, short_description, benefits,
        application_mode, application_process, official_url,
        min_age, max_age, max_income, requires_disability, target_state, start_date, end_date, is_active
    ) VALUES (
        'UP-KANYA-SUMANGALA-YOJANA', 'UP Kanya Sumangala Yojana', 'UP Government', 'STATE_GOVERNMENT', 'Financial support for girl child in UP', 'Rs 15000 in 6 installments from birth to class 12 for girl child in UP',
        'ONLINE', 'Apply on mksy.up.gov.in', 'https://mksy.up.gov.in',
        0, 18, 300000, FALSE, 'Uttar Pradesh', '2019-04-01', NULL, TRUE
    ) ON CONFLICT (code) DO UPDATE SET
        name = EXCLUDED.name, short_description = EXCLUDED.short_description, benefits = EXCLUDED.benefits,
        official_url = EXCLUDED.official_url, max_income = EXCLUDED.max_income, target_state = EXCLUDED.target_state,
        updated_at = CURRENT_TIMESTAMP
    RETURNING id INTO v_scheme_id;

    DELETE FROM yojna_setu.scheme_castes WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_genders WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_occupations WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_religions WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_documents WHERE scheme_id = v_scheme_id;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'SC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'ST') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'OBC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'GENERAL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_genders (scheme_id, gender) VALUES (v_scheme_id, 'FEMALE') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_occupations (scheme_id, occupation) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_religions (scheme_id, religion) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Aadhaar Card', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Birth Certificate', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Bank Passbook', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Income Certificate', TRUE);

    -- Scheme #74: UP Mukhyamantri Abhyudaya Yojana
    INSERT INTO yojna_setu.schemes (
        code, name, ministry, category, short_description, benefits,
        application_mode, application_process, official_url,
        min_age, max_age, max_income, requires_disability, target_state, start_date, end_date, is_active
    ) VALUES (
        'UP-MUKHYAMANTRI-ABHYUDAYA-YOJANA', 'UP Mukhyamantri Abhyudaya Yojana', 'UP Government', 'STATE_GOVERNMENT', 'Free UPSC IAS PCS coaching for UP students', 'Free coaching for UPSC IAS PCS NDA CDS JEE NEET with study material',
        'ONLINE', 'Apply on abhyuday.up.gov.in', 'https://abhyuday.up.gov.in',
        18, 35, NULL, FALSE, 'Uttar Pradesh', '2021-02-16', '2026-07-20', TRUE
    ) ON CONFLICT (code) DO UPDATE SET
        name = EXCLUDED.name, short_description = EXCLUDED.short_description, benefits = EXCLUDED.benefits,
        official_url = EXCLUDED.official_url, max_income = EXCLUDED.max_income, target_state = EXCLUDED.target_state,
        updated_at = CURRENT_TIMESTAMP
    RETURNING id INTO v_scheme_id;

    DELETE FROM yojna_setu.scheme_castes WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_genders WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_occupations WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_religions WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_documents WHERE scheme_id = v_scheme_id;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'SC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'ST') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'OBC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'GENERAL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_genders (scheme_id, gender) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_occupations (scheme_id, occupation) VALUES (v_scheme_id, 'STUDENT') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_religions (scheme_id, religion) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Aadhaar Card', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Domicile Certificate', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Educational Certificate', TRUE);

    -- Scheme #75: UP Berojgari Bhatta
    INSERT INTO yojna_setu.schemes (
        code, name, ministry, category, short_description, benefits,
        application_mode, application_process, official_url,
        min_age, max_age, max_income, requires_disability, target_state, start_date, end_date, is_active
    ) VALUES (
        'UP-BEROJGARI-BHATTA', 'UP Berojgari Bhatta', 'UP Government', 'STATE_GOVERNMENT', 'Unemployment allowance for educated UP youth', 'Rs 1000-1500 per month unemployment allowance for graduate postgraduate youth in UP',
        'ONLINE', 'Register on sewayojan.up.nic.in', 'https://sewayojan.up.nic.in',
        18, 35, NULL, FALSE, 'Uttar Pradesh', '2019-01-01', NULL, TRUE
    ) ON CONFLICT (code) DO UPDATE SET
        name = EXCLUDED.name, short_description = EXCLUDED.short_description, benefits = EXCLUDED.benefits,
        official_url = EXCLUDED.official_url, max_income = EXCLUDED.max_income, target_state = EXCLUDED.target_state,
        updated_at = CURRENT_TIMESTAMP
    RETURNING id INTO v_scheme_id;

    DELETE FROM yojna_setu.scheme_castes WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_genders WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_occupations WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_religions WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_documents WHERE scheme_id = v_scheme_id;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'SC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'ST') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'OBC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'GENERAL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_genders (scheme_id, gender) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_occupations (scheme_id, occupation) VALUES (v_scheme_id, 'OTHER') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_occupations (scheme_id, occupation) VALUES (v_scheme_id, 'STUDENT') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_religions (scheme_id, religion) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Aadhaar Card', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Domicile Certificate', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Educational Certificate', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Bank Passbook', TRUE);

    -- Scheme #76: UP Vridha Pension Yojana
    INSERT INTO yojna_setu.schemes (
        code, name, ministry, category, short_description, benefits,
        application_mode, application_process, official_url,
        min_age, max_age, max_income, requires_disability, target_state, start_date, end_date, is_active
    ) VALUES (
        'UP-VRIDHA-PENSION-YOJANA', 'UP Vridha Pension Yojana', 'UP Government', 'STATE_GOVERNMENT', 'Old age pension for elderly in UP', 'Rs 1000 per month pension for elderly above 60 in UP',
        'ONLINE', 'Apply on sspy-up.gov.in', 'https://sspy-up.gov.in',
        60, 130, 200000, FALSE, 'Uttar Pradesh', '2016-01-01', NULL, TRUE
    ) ON CONFLICT (code) DO UPDATE SET
        name = EXCLUDED.name, short_description = EXCLUDED.short_description, benefits = EXCLUDED.benefits,
        official_url = EXCLUDED.official_url, max_income = EXCLUDED.max_income, target_state = EXCLUDED.target_state,
        updated_at = CURRENT_TIMESTAMP
    RETURNING id INTO v_scheme_id;

    DELETE FROM yojna_setu.scheme_castes WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_genders WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_occupations WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_religions WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_documents WHERE scheme_id = v_scheme_id;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'SC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'ST') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'OBC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'GENERAL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_genders (scheme_id, gender) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_occupations (scheme_id, occupation) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_religions (scheme_id, religion) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Aadhaar Card', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Age Proof', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Bank Passbook', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Income Certificate', TRUE);

    -- Scheme #77: Bihar Student Credit Card
    INSERT INTO yojna_setu.schemes (
        code, name, ministry, category, short_description, benefits,
        application_mode, application_process, official_url,
        min_age, max_age, max_income, requires_disability, target_state, start_date, end_date, is_active
    ) VALUES (
        'BIHAR-STUDENT-CREDIT-CARD', 'Bihar Student Credit Card', 'Bihar Government', 'STATE_GOVERNMENT', 'Education loan up to Rs 4 lakh for Bihar students', 'Education loan up to Rs 4 lakh at 4% interest for boys 1% for girls',
        'ONLINE', 'Apply on 7nischay portal', 'https://7nischay-yuvaupmission.bihar.gov.in',
        18, 25, NULL, FALSE, 'Bihar', '2016-10-02', '2026-06-15', TRUE
    ) ON CONFLICT (code) DO UPDATE SET
        name = EXCLUDED.name, short_description = EXCLUDED.short_description, benefits = EXCLUDED.benefits,
        official_url = EXCLUDED.official_url, max_income = EXCLUDED.max_income, target_state = EXCLUDED.target_state,
        updated_at = CURRENT_TIMESTAMP
    RETURNING id INTO v_scheme_id;

    DELETE FROM yojna_setu.scheme_castes WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_genders WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_occupations WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_religions WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_documents WHERE scheme_id = v_scheme_id;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'SC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'ST') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'OBC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'GENERAL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_genders (scheme_id, gender) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_occupations (scheme_id, occupation) VALUES (v_scheme_id, 'STUDENT') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_religions (scheme_id, religion) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Aadhaar Card', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Domicile Certificate', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Admission Letter', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Class 12 Marksheet', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Bank Passbook', TRUE);

    -- Scheme #78: Bihar Mukhyamantri Kanya Utthan Yojana
    INSERT INTO yojna_setu.schemes (
        code, name, ministry, category, short_description, benefits,
        application_mode, application_process, official_url,
        min_age, max_age, max_income, requires_disability, target_state, start_date, end_date, is_active
    ) VALUES (
        'BIHAR-MUKHYAMANTRI-KANYA-UTTHAN-YOJANA', 'Bihar Mukhyamantri Kanya Utthan Yojana', 'Bihar Government', 'STATE_GOVERNMENT', 'Financial incentive for girl child education in Bihar', 'Rs 50000 total incentive from birth to graduation for girl child in Bihar',
        'ONLINE', 'Apply through school or edudbt.bih.nic.in', 'https://edudbt.bih.nic.in',
        0, 25, NULL, FALSE, 'Bihar', '2019-04-01', NULL, TRUE
    ) ON CONFLICT (code) DO UPDATE SET
        name = EXCLUDED.name, short_description = EXCLUDED.short_description, benefits = EXCLUDED.benefits,
        official_url = EXCLUDED.official_url, max_income = EXCLUDED.max_income, target_state = EXCLUDED.target_state,
        updated_at = CURRENT_TIMESTAMP
    RETURNING id INTO v_scheme_id;

    DELETE FROM yojna_setu.scheme_castes WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_genders WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_occupations WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_religions WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_documents WHERE scheme_id = v_scheme_id;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'SC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'ST') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'OBC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'GENERAL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_genders (scheme_id, gender) VALUES (v_scheme_id, 'FEMALE') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_occupations (scheme_id, occupation) VALUES (v_scheme_id, 'STUDENT') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_religions (scheme_id, religion) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Aadhaar Card', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Birth Certificate', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Bank Passbook', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Educational Certificate', TRUE);

    -- Scheme #79: Rajasthan Mukhyamantri Chiranjeevi Yojana
    INSERT INTO yojna_setu.schemes (
        code, name, ministry, category, short_description, benefits,
        application_mode, application_process, official_url,
        min_age, max_age, max_income, requires_disability, target_state, start_date, end_date, is_active
    ) VALUES (
        'RAJASTHAN-MUKHYAMANTRI-CHIRANJEEVI-YOJANA', 'Rajasthan Mukhyamantri Chiranjeevi Yojana', 'Rajasthan Government', 'STATE_GOVERNMENT', 'Free health insurance for all Rajasthan families', 'Free health insurance up to Rs 25 lakh per year for all Rajasthan families',
        'ONLINE', 'Register on chiranjeevi.rajasthan.gov.in', 'https://chiranjeevi.rajasthan.gov.in',
        0, 130, NULL, FALSE, 'Rajasthan', '2021-05-01', NULL, TRUE
    ) ON CONFLICT (code) DO UPDATE SET
        name = EXCLUDED.name, short_description = EXCLUDED.short_description, benefits = EXCLUDED.benefits,
        official_url = EXCLUDED.official_url, max_income = EXCLUDED.max_income, target_state = EXCLUDED.target_state,
        updated_at = CURRENT_TIMESTAMP
    RETURNING id INTO v_scheme_id;

    DELETE FROM yojna_setu.scheme_castes WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_genders WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_occupations WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_religions WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_documents WHERE scheme_id = v_scheme_id;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'SC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'ST') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'OBC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'GENERAL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_genders (scheme_id, gender) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_occupations (scheme_id, occupation) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_religions (scheme_id, religion) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Aadhaar Card', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Jan Aadhaar Card', TRUE);

    -- Scheme #80: MP Mukhyamantri Medhavi Vidyarthi Yojana
    INSERT INTO yojna_setu.schemes (
        code, name, ministry, category, short_description, benefits,
        application_mode, application_process, official_url,
        min_age, max_age, max_income, requires_disability, target_state, start_date, end_date, is_active
    ) VALUES (
        'MP-MUKHYAMANTRI-MEDHAVI-VIDYARTHI-YOJANA', 'MP Mukhyamantri Medhavi Vidyarthi Yojana', 'MP Government', 'STATE_GOVERNMENT', 'Free higher education for meritorious MP students', 'Full tuition fee paid by MP government for students scoring 70% in class 12',
        'ONLINE', 'Apply on medhavikalyan.mp.gov.in', 'https://medhavikalyan.mp.gov.in',
        17, 25, 600000, FALSE, 'Madhya Pradesh', '2017-06-01', NULL, TRUE
    ) ON CONFLICT (code) DO UPDATE SET
        name = EXCLUDED.name, short_description = EXCLUDED.short_description, benefits = EXCLUDED.benefits,
        official_url = EXCLUDED.official_url, max_income = EXCLUDED.max_income, target_state = EXCLUDED.target_state,
        updated_at = CURRENT_TIMESTAMP
    RETURNING id INTO v_scheme_id;

    DELETE FROM yojna_setu.scheme_castes WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_genders WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_occupations WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_religions WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_documents WHERE scheme_id = v_scheme_id;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'SC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'ST') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'OBC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'GENERAL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_genders (scheme_id, gender) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_occupations (scheme_id, occupation) VALUES (v_scheme_id, 'STUDENT') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_religions (scheme_id, religion) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Aadhaar Card', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Class 12 Marksheet 70% or above', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Income Certificate', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Admission Letter', TRUE);

    -- Scheme #81: West Bengal Kanyashree Prakalpa
    INSERT INTO yojna_setu.schemes (
        code, name, ministry, category, short_description, benefits,
        application_mode, application_process, official_url,
        min_age, max_age, max_income, requires_disability, target_state, start_date, end_date, is_active
    ) VALUES (
        'WEST-BENGAL-KANYASHREE-PRAKALPA', 'West Bengal Kanyashree Prakalpa', 'WB Government', 'STATE_GOVERNMENT', 'Scholarship for girl students in West Bengal', 'Rs 1000 per year annual scholarship and Rs 25000 one time grant for girls in WB',
        'ONLINE', 'Apply through school on wbkanyashree.gov.in', 'https://wbkanyashree.gov.in',
        13, 18, 120000, FALSE, 'West Bengal', '2013-10-01', NULL, TRUE
    ) ON CONFLICT (code) DO UPDATE SET
        name = EXCLUDED.name, short_description = EXCLUDED.short_description, benefits = EXCLUDED.benefits,
        official_url = EXCLUDED.official_url, max_income = EXCLUDED.max_income, target_state = EXCLUDED.target_state,
        updated_at = CURRENT_TIMESTAMP
    RETURNING id INTO v_scheme_id;

    DELETE FROM yojna_setu.scheme_castes WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_genders WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_occupations WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_religions WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_documents WHERE scheme_id = v_scheme_id;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'SC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'ST') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'OBC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'GENERAL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_genders (scheme_id, gender) VALUES (v_scheme_id, 'FEMALE') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_occupations (scheme_id, occupation) VALUES (v_scheme_id, 'STUDENT') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_religions (scheme_id, religion) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Aadhaar Card', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Income Certificate', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'School Certificate', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Bank Passbook', TRUE);

    -- Scheme #82: Maharashtra Swadhar Gruh Scheme
    INSERT INTO yojna_setu.schemes (
        code, name, ministry, category, short_description, benefits,
        application_mode, application_process, official_url,
        min_age, max_age, max_income, requires_disability, target_state, start_date, end_date, is_active
    ) VALUES (
        'MAHARASHTRA-SWADHAR-GRUH-SCHEME', 'Maharashtra Swadhar Gruh Scheme', 'Maharashtra Government', 'STATE_GOVERNMENT', 'Free hostel and financial aid for SC students in Maharashtra', 'Rs 51000 per year for boarding lodging and education for SC students in Maharashtra',
        'ONLINE', 'Apply through district social welfare office', 'https://sjsa.maharashtra.gov.in',
        15, 30, 250000, FALSE, 'Maharashtra', '2016-01-01', NULL, TRUE
    ) ON CONFLICT (code) DO UPDATE SET
        name = EXCLUDED.name, short_description = EXCLUDED.short_description, benefits = EXCLUDED.benefits,
        official_url = EXCLUDED.official_url, max_income = EXCLUDED.max_income, target_state = EXCLUDED.target_state,
        updated_at = CURRENT_TIMESTAMP
    RETURNING id INTO v_scheme_id;

    DELETE FROM yojna_setu.scheme_castes WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_genders WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_occupations WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_religions WHERE scheme_id = v_scheme_id;
    DELETE FROM yojna_setu.scheme_documents WHERE scheme_id = v_scheme_id;
    INSERT INTO yojna_setu.scheme_castes (scheme_id, caste) VALUES (v_scheme_id, 'SC') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_genders (scheme_id, gender) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_occupations (scheme_id, occupation) VALUES (v_scheme_id, 'STUDENT') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_religions (scheme_id, religion) VALUES (v_scheme_id, 'ALL') ON CONFLICT DO NOTHING;
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Aadhaar Card', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Caste Certificate', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Income Certificate', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Admission Letter', TRUE);
    INSERT INTO yojna_setu.scheme_documents (scheme_id, document_name, is_mandatory) VALUES (v_scheme_id, 'Bank Passbook', TRUE);

END $$;
