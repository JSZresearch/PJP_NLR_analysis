WITH 
basic AS (
    WITH
    --纳入的诊断
    --肺孢子虫病 Pneumocystosis 
    includedDiagnose1 AS (
        SELECT DISTINCT hadm_id 
        FROM mimiciv_hosp.diagnoses_icd
        WHERE icd_code IN ('B59')
    ),
    --肺囊肿病 Pneumocystosis 
    includedDiagnose2 AS (
        SELECT DISTINCT hadm_id 
        FROM mimiciv_hosp.diagnoses_icd
        WHERE icd_code IN ('1363')
    )
    SELECT 
        DISTINCT ON (icu.subject_id)
        icu.subject_id, 
        icu.stay_id, 
        icu.hadm_id,
        icu.admittime AS admittime,
        icu.dischtime AS dischtime,
        icu.icu_intime AS icu_intime,
        icu.icu_outtime AS icu_outtime
    FROM mimiciv_derived.icustay_detail AS icu
    JOIN mimiciv_derived.age AS age ON age.hadm_id = icu.hadm_id
    WHERE 
        TRUE
        AND age.age BETWEEN 18 AND 120
        AND icu.first_icu_stay = true
        --纳入诊断疾病
        AND (
            --肺孢子虫病 Pneumocystosis 
            icu.hadm_id IN (SELECT hadm_id FROM includedDiagnose1)
            --肺囊肿病 Pneumocystosis 
            OR icu.hadm_id IN (SELECT hadm_id FROM includedDiagnose2)
        )
)
--SELECT * FROM basic;

SELECT DISTINCT(subject.subject_id),
    subject.stay_id,
    subject.hadm_id,
    subject.admittime,
    subject.dischtime,
    subject.icu_intime,
    subject.icu_outtime,
    ROUND(age.age,0) AS age,
    icu.gender,
    icu.race,
    weight.weight,
    height.height,
    adm.insurance,
    adm.language,
    adm.marital_status
FROM basic AS subject
LEFT JOIN mimiciv_derived.age AS age ON subject.hadm_id = age.hadm_id
LEFT JOIN mimiciv_derived.icustay_detail AS icu ON subject.stay_id = icu.stay_id
LEFT JOIN mimiciv_derived.first_day_weight AS weight ON subject.stay_id = weight.stay_id
LEFT JOIN mimiciv_hosp.admissions AS adm ON subject.hadm_id = adm.hadm_id
LEFT JOIN mimiciv_derived.first_day_height AS height ON subject.stay_id = height.stay_id
ORDER BY subject.subject_id;
WITH 
basic AS (
    WITH
    --纳入的诊断
    --肺孢子虫病 Pneumocystosis 
    includedDiagnose1 AS (
        SELECT DISTINCT hadm_id 
        FROM mimiciv_hosp.diagnoses_icd
        WHERE icd_code IN ('B59')
    ),
    --肺囊肿病 Pneumocystosis 
    includedDiagnose2 AS (
        SELECT DISTINCT hadm_id 
        FROM mimiciv_hosp.diagnoses_icd
        WHERE icd_code IN ('1363')
    )
    SELECT 
        DISTINCT ON (icu.subject_id)
        icu.subject_id, 
        icu.stay_id, 
        icu.hadm_id,
        icu.admittime AS admittime,
        icu.dischtime AS dischtime,
        icu.icu_intime AS icu_intime,
        icu.icu_outtime AS icu_outtime
    FROM mimiciv_derived.icustay_detail AS icu
    JOIN mimiciv_derived.age AS age ON age.hadm_id = icu.hadm_id
    WHERE 
        TRUE
        AND age.age BETWEEN 18 AND 120
        AND icu.first_icu_stay = true
        --纳入诊断疾病
        AND (
            --肺孢子虫病 Pneumocystosis 
            icu.hadm_id IN (SELECT hadm_id FROM includedDiagnose1)
            --肺囊肿病 Pneumocystosis 
            OR icu.hadm_id IN (SELECT hadm_id FROM includedDiagnose2)
        )
)
--SELECT * FROM basic;

,
-- 血红蛋白 Hemoglobin 血常规
FIRST_Hemoglobin AS
    (SELECT DISTINCT ON (LAB.HADM_ID) LAB.HADM_ID,LAB.VALUENUM, LAB.VALUEUOM,
    LAB.charttime AS Hemoglobin_charttime,
    LAB.storetime AS Hemoglobin_storetime
    FROM basic AS SUBJECT,
    MIMICIV_DERIVED.ICUSTAY_DETAIL AS ICU,
    MIMICIV_HOSP.LABEVENTS AS LAB
    WHERE LAB.ITEMID = 51222
    AND LAB.CHARTTIME >= ICU.ICU_INTIME
    AND SUBJECT.STAY_ID = ICU.STAY_ID
    AND SUBJECT.HADM_ID = LAB.HADM_ID
    ORDER BY LAB.HADM_ID,LAB.CHARTTIME)
,
-- 血小板计数 Platelet Count 血常规
FIRST_Platelet_Count AS
    (SELECT DISTINCT ON (LAB.HADM_ID) LAB.HADM_ID,LAB.VALUENUM, LAB.VALUEUOM,
    LAB.charttime AS Platelet_Count_charttime,
    LAB.storetime AS Platelet_Count_storetime
    FROM basic AS SUBJECT,
    MIMICIV_DERIVED.ICUSTAY_DETAIL AS ICU,
    MIMICIV_HOSP.LABEVENTS AS LAB
    WHERE LAB.ITEMID = 51265
    AND LAB.CHARTTIME >= ICU.ICU_INTIME
    AND SUBJECT.STAY_ID = ICU.STAY_ID
    AND SUBJECT.HADM_ID = LAB.HADM_ID
    ORDER BY LAB.HADM_ID,LAB.CHARTTIME)
,
-- 红细胞 Red Blood Cells 血常规
FIRST_Red_Blood_Cells AS
    (SELECT DISTINCT ON (LAB.HADM_ID) LAB.HADM_ID,LAB.VALUENUM, LAB.VALUEUOM,
    LAB.charttime AS Red_Blood_Cells_charttime,
    LAB.storetime AS Red_Blood_Cells_storetime
    FROM basic AS SUBJECT,
    MIMICIV_DERIVED.ICUSTAY_DETAIL AS ICU,
    MIMICIV_HOSP.LABEVENTS AS LAB
    WHERE LAB.ITEMID = 51279
    AND LAB.CHARTTIME >= ICU.ICU_INTIME
    AND SUBJECT.STAY_ID = ICU.STAY_ID
    AND SUBJECT.HADM_ID = LAB.HADM_ID
    ORDER BY LAB.HADM_ID,LAB.CHARTTIME)
,
-- 白细胞 White Blood Cells 血常规
FIRST_White_Blood_Cells AS
    (SELECT DISTINCT ON (LAB.HADM_ID) LAB.HADM_ID,LAB.VALUENUM, LAB.VALUEUOM,
    LAB.charttime AS White_Blood_Cells_charttime,
    LAB.storetime AS White_Blood_Cells_storetime
    FROM basic AS SUBJECT,
    MIMICIV_DERIVED.ICUSTAY_DETAIL AS ICU,
    MIMICIV_HOSP.LABEVENTS AS LAB
    WHERE LAB.ITEMID = 51301
    AND LAB.CHARTTIME >= ICU.ICU_INTIME
    AND SUBJECT.STAY_ID = ICU.STAY_ID
    AND SUBJECT.HADM_ID = LAB.HADM_ID
    ORDER BY LAB.HADM_ID,LAB.CHARTTIME)

 SELECT 
    DISTINCT(SUBJECT.SUBJECT_ID),
    SUBJECT.STAY_ID,
    SUBJECT.HADM_ID,
    SUBJECT.admittime,
    SUBJECT.dischtime,
    SUBJECT.icu_intime,
    SUBJECT.icu_outtime,
    ROUND(FIRST_Hemoglobin.VALUENUM::numeric,2) AS FIRST_Hemoglobin,
    FIRST_Hemoglobin.VALUEUOM AS FIRST_Hemoglobin_UOM,
    FIRST_Hemoglobin.Hemoglobin_charttime,
    FIRST_Hemoglobin.Hemoglobin_storetime, 
    ROUND(FIRST_Platelet_Count.VALUENUM::numeric,2) AS FIRST_Platelet_Count,
    FIRST_Platelet_Count.VALUEUOM AS FIRST_Platelet_Count_UOM,
    FIRST_Platelet_Count.Platelet_Count_charttime,
    FIRST_Platelet_Count.Platelet_Count_storetime, 
    ROUND(FIRST_Red_Blood_Cells.VALUENUM::numeric,2) AS FIRST_Red_Blood_Cells,
    FIRST_Red_Blood_Cells.VALUEUOM AS FIRST_Red_Blood_Cells_UOM,
    FIRST_Red_Blood_Cells.Red_Blood_Cells_charttime,
    FIRST_Red_Blood_Cells.Red_Blood_Cells_storetime, 
    ROUND(FIRST_White_Blood_Cells.VALUENUM::numeric,2) AS FIRST_White_Blood_Cells,
    FIRST_White_Blood_Cells.VALUEUOM AS FIRST_White_Blood_Cells_UOM,
    FIRST_White_Blood_Cells.White_Blood_Cells_charttime,
    FIRST_White_Blood_Cells.White_Blood_Cells_storetime
    FROM basic AS SUBJECT
LEFT JOIN FIRST_Hemoglobin ON SUBJECT.HADM_ID = FIRST_Hemoglobin.HADM_ID
LEFT JOIN FIRST_Platelet_Count ON SUBJECT.HADM_ID = FIRST_Platelet_Count.HADM_ID
LEFT JOIN FIRST_Red_Blood_Cells ON SUBJECT.HADM_ID = FIRST_Red_Blood_Cells.HADM_ID
LEFT JOIN FIRST_White_Blood_Cells ON SUBJECT.HADM_ID = FIRST_White_Blood_Cells.HADM_ID
ORDER BY SUBJECT.SUBJECT_ID;
WITH 
basic AS (
    WITH
    --纳入的诊断
    --肺孢子虫病 Pneumocystosis 
    includedDiagnose1 AS (
        SELECT DISTINCT hadm_id 
        FROM mimiciv_hosp.diagnoses_icd
        WHERE icd_code IN ('B59')
    ),
    --肺囊肿病 Pneumocystosis 
    includedDiagnose2 AS (
        SELECT DISTINCT hadm_id 
        FROM mimiciv_hosp.diagnoses_icd
        WHERE icd_code IN ('1363')
    )
    SELECT 
        DISTINCT ON (icu.subject_id)
        icu.subject_id, 
        icu.stay_id, 
        icu.hadm_id,
        icu.admittime AS admittime,
        icu.dischtime AS dischtime,
        icu.icu_intime AS icu_intime,
        icu.icu_outtime AS icu_outtime
    FROM mimiciv_derived.icustay_detail AS icu
    JOIN mimiciv_derived.age AS age ON age.hadm_id = icu.hadm_id
    WHERE 
        TRUE
        AND age.age BETWEEN 18 AND 120
        AND icu.first_icu_stay = true
        --纳入诊断疾病
        AND (
            --肺孢子虫病 Pneumocystosis 
            icu.hadm_id IN (SELECT hadm_id FROM includedDiagnose1)
            --肺囊肿病 Pneumocystosis 
            OR icu.hadm_id IN (SELECT hadm_id FROM includedDiagnose2)
        )
)
--SELECT * FROM basic;

,
-- 淋巴细胞 Lymphocytes 
FIRST_Lymphocytes AS
    (SELECT DISTINCT ON (LAB.HADM_ID) LAB.HADM_ID,LAB.VALUENUM, LAB.VALUEUOM,
    LAB.charttime AS Lymphocytes_charttime,
    LAB.storetime AS Lymphocytes_storetime
    FROM basic AS SUBJECT,
    MIMICIV_DERIVED.ICUSTAY_DETAIL AS ICU,
    MIMICIV_HOSP.LABEVENTS AS LAB
    WHERE LAB.ITEMID = 51244
    AND LAB.CHARTTIME >= ICU.ICU_INTIME
    AND SUBJECT.STAY_ID = ICU.STAY_ID
    AND SUBJECT.HADM_ID = LAB.HADM_ID
    ORDER BY LAB.HADM_ID,LAB.CHARTTIME)
,
-- 中性粒细胞 Neutrophils 
FIRST_Neutrophils AS
    (SELECT DISTINCT ON (LAB.HADM_ID) LAB.HADM_ID,LAB.VALUENUM, LAB.VALUEUOM,
    LAB.charttime AS Neutrophils_charttime,
    LAB.storetime AS Neutrophils_storetime
    FROM basic AS SUBJECT,
    MIMICIV_DERIVED.ICUSTAY_DETAIL AS ICU,
    MIMICIV_HOSP.LABEVENTS AS LAB
    WHERE LAB.ITEMID = 51256
    AND LAB.CHARTTIME >= ICU.ICU_INTIME
    AND SUBJECT.STAY_ID = ICU.STAY_ID
    AND SUBJECT.HADM_ID = LAB.HADM_ID
    ORDER BY LAB.HADM_ID,LAB.CHARTTIME)
,
-- 白细胞 White Blood Cells 
FIRST_White_Blood_Cells AS
    (SELECT DISTINCT ON (LAB.HADM_ID) LAB.HADM_ID,LAB.VALUENUM, LAB.VALUEUOM,
    LAB.charttime AS White_Blood_Cells_charttime,
    LAB.storetime AS White_Blood_Cells_storetime
    FROM basic AS SUBJECT,
    MIMICIV_DERIVED.ICUSTAY_DETAIL AS ICU,
    MIMICIV_HOSP.LABEVENTS AS LAB
    WHERE LAB.ITEMID = 51301
    AND LAB.CHARTTIME >= ICU.ICU_INTIME
    AND SUBJECT.STAY_ID = ICU.STAY_ID
    AND SUBJECT.HADM_ID = LAB.HADM_ID
    ORDER BY LAB.HADM_ID,LAB.CHARTTIME)

 SELECT 
    DISTINCT(SUBJECT.SUBJECT_ID),
    SUBJECT.STAY_ID,
    SUBJECT.HADM_ID,
    SUBJECT.admittime,
    SUBJECT.dischtime,
    SUBJECT.icu_intime,
    SUBJECT.icu_outtime,
    ROUND(FIRST_Lymphocytes.VALUENUM::numeric,2) AS FIRST_Lymphocytes,
    FIRST_Lymphocytes.VALUEUOM AS FIRST_Lymphocytes_UOM,
    FIRST_Lymphocytes.Lymphocytes_charttime,
    FIRST_Lymphocytes.Lymphocytes_storetime, 
    ROUND(FIRST_Neutrophils.VALUENUM::numeric,2) AS FIRST_Neutrophils,
    FIRST_Neutrophils.VALUEUOM AS FIRST_Neutrophils_UOM,
    FIRST_Neutrophils.Neutrophils_charttime,
    FIRST_Neutrophils.Neutrophils_storetime, 
    ROUND(FIRST_White_Blood_Cells.VALUENUM::numeric,2) AS FIRST_White_Blood_Cells,
    FIRST_White_Blood_Cells.VALUEUOM AS FIRST_White_Blood_Cells_UOM,
    FIRST_White_Blood_Cells.White_Blood_Cells_charttime,
    FIRST_White_Blood_Cells.White_Blood_Cells_storetime
    FROM basic AS SUBJECT
LEFT JOIN FIRST_Lymphocytes ON SUBJECT.HADM_ID = FIRST_Lymphocytes.HADM_ID
LEFT JOIN FIRST_Neutrophils ON SUBJECT.HADM_ID = FIRST_Neutrophils.HADM_ID
LEFT JOIN FIRST_White_Blood_Cells ON SUBJECT.HADM_ID = FIRST_White_Blood_Cells.HADM_ID
ORDER BY SUBJECT.SUBJECT_ID;

WITH 
basic AS (
    WITH
    --纳入的诊断
    --肺孢子虫病 Pneumocystosis 
    includedDiagnose1 AS (
        SELECT DISTINCT hadm_id 
        FROM mimiciv_hosp.diagnoses_icd
        WHERE icd_code IN ('B59')
    ),
    --肺囊肿病 Pneumocystosis 
    includedDiagnose2 AS (
        SELECT DISTINCT hadm_id 
        FROM mimiciv_hosp.diagnoses_icd
        WHERE icd_code IN ('1363')
    )
    SELECT 
        DISTINCT ON (icu.subject_id)
        icu.subject_id, 
        icu.stay_id, 
        icu.hadm_id,
        icu.admittime AS admittime,
        icu.dischtime AS dischtime,
        icu.icu_intime AS icu_intime,
        icu.icu_outtime AS icu_outtime
    FROM mimiciv_derived.icustay_detail AS icu
    JOIN mimiciv_derived.age AS age ON age.hadm_id = icu.hadm_id
    WHERE 
        TRUE
        AND age.age BETWEEN 18 AND 120
        AND icu.first_icu_stay = true
        --纳入诊断疾病
        AND (
            --肺孢子虫病 Pneumocystosis 
            icu.hadm_id IN (SELECT hadm_id FROM includedDiagnose1)
            --肺囊肿病 Pneumocystosis 
            OR icu.hadm_id IN (SELECT hadm_id FROM includedDiagnose2)
        )
)
--SELECT * FROM basic;

,
-- 白蛋白 Albumin 血生化
FIRST_Albumin AS
    (SELECT DISTINCT ON (LAB.HADM_ID) LAB.HADM_ID,LAB.VALUENUM, LAB.VALUEUOM,
    LAB.charttime AS Albumin_charttime,
    LAB.storetime AS Albumin_storetime
    FROM basic AS SUBJECT,
    MIMICIV_DERIVED.ICUSTAY_DETAIL AS ICU,
    MIMICIV_HOSP.LABEVENTS AS LAB
    WHERE LAB.ITEMID = 50862
    AND LAB.CHARTTIME >= ICU.ICU_INTIME
    AND SUBJECT.STAY_ID = ICU.STAY_ID
    AND SUBJECT.HADM_ID = LAB.HADM_ID
    ORDER BY LAB.HADM_ID,LAB.CHARTTIME)
,
-- 氧分压 pO2 血气
FIRST_pO2 AS
    (SELECT DISTINCT ON (LAB.HADM_ID) LAB.HADM_ID,LAB.VALUENUM, LAB.VALUEUOM,
    LAB.charttime AS pO2_charttime,
    LAB.storetime AS pO2_storetime
    FROM basic AS SUBJECT,
    MIMICIV_DERIVED.ICUSTAY_DETAIL AS ICU,
    MIMICIV_HOSP.LABEVENTS AS LAB
    WHERE LAB.ITEMID = 50821
    AND LAB.CHARTTIME >= ICU.ICU_INTIME
    AND SUBJECT.STAY_ID = ICU.STAY_ID
    AND SUBJECT.HADM_ID = LAB.HADM_ID
    ORDER BY LAB.HADM_ID,LAB.CHARTTIME)
,
-- 肌酐 Creatinine 肝肾功能
FIRST_Creatinine AS
    (SELECT DISTINCT ON (LAB.HADM_ID) LAB.HADM_ID,LAB.VALUENUM, LAB.VALUEUOM,
    LAB.charttime AS Creatinine_charttime,
    LAB.storetime AS Creatinine_storetime
    FROM basic AS SUBJECT,
    MIMICIV_DERIVED.ICUSTAY_DETAIL AS ICU,
    MIMICIV_HOSP.LABEVENTS AS LAB
    WHERE LAB.ITEMID = 50912
    AND LAB.CHARTTIME >= ICU.ICU_INTIME
    AND SUBJECT.STAY_ID = ICU.STAY_ID
    AND SUBJECT.HADM_ID = LAB.HADM_ID
    ORDER BY LAB.HADM_ID,LAB.CHARTTIME)
,
-- 乳酸脱氢酶（LD） Lactate Dehydrogenase (LD) 
FIRST_Lactate_Dehydrogenase_LD AS
    (SELECT DISTINCT ON (LAB.HADM_ID) LAB.HADM_ID,LAB.VALUENUM, LAB.VALUEUOM,
    LAB.charttime AS Lactate_Dehydrogenase_LD_charttime,
    LAB.storetime AS Lactate_Dehydrogenase_LD_storetime
    FROM basic AS SUBJECT,
    MIMICIV_DERIVED.ICUSTAY_DETAIL AS ICU,
    MIMICIV_HOSP.LABEVENTS AS LAB
    WHERE LAB.ITEMID = 50954
    AND LAB.CHARTTIME >= ICU.ICU_INTIME
    AND SUBJECT.STAY_ID = ICU.STAY_ID
    AND SUBJECT.HADM_ID = LAB.HADM_ID
    ORDER BY LAB.HADM_ID,LAB.CHARTTIME)
,
-- 所需氧气 Required O2 
FIRST_Required_O2 AS
    (SELECT DISTINCT ON (LAB.HADM_ID) LAB.HADM_ID,LAB.VALUENUM, LAB.VALUEUOM,
    LAB.charttime AS Required_O2_charttime,
    LAB.storetime AS Required_O2_storetime
    FROM basic AS SUBJECT,
    MIMICIV_DERIVED.ICUSTAY_DETAIL AS ICU,
    MIMICIV_HOSP.LABEVENTS AS LAB
    WHERE LAB.ITEMID = 50823
    AND LAB.CHARTTIME >= ICU.ICU_INTIME
    AND SUBJECT.STAY_ID = ICU.STAY_ID
    AND SUBJECT.HADM_ID = LAB.HADM_ID
    ORDER BY LAB.HADM_ID,LAB.CHARTTIME)

 SELECT 
    DISTINCT(SUBJECT.SUBJECT_ID),
    SUBJECT.STAY_ID,
    SUBJECT.HADM_ID,
    SUBJECT.admittime,
    SUBJECT.dischtime,
    SUBJECT.icu_intime,
    SUBJECT.icu_outtime,
    ROUND(FIRST_Albumin.VALUENUM::numeric,2) AS FIRST_Albumin,
    FIRST_Albumin.VALUEUOM AS FIRST_Albumin_UOM,
    FIRST_Albumin.Albumin_charttime,
    FIRST_Albumin.Albumin_storetime, 
    ROUND(FIRST_pO2.VALUENUM::numeric,2) AS FIRST_pO2,
    FIRST_pO2.VALUEUOM AS FIRST_pO2_UOM,
    FIRST_pO2.pO2_charttime,
    FIRST_pO2.pO2_storetime, 
    ROUND(FIRST_Creatinine.VALUENUM::numeric,2) AS FIRST_Creatinine,
    FIRST_Creatinine.VALUEUOM AS FIRST_Creatinine_UOM,
    FIRST_Creatinine.Creatinine_charttime,
    FIRST_Creatinine.Creatinine_storetime, 
    ROUND(FIRST_Lactate_Dehydrogenase_LD.VALUENUM::numeric,2) AS FIRST_Lactate_Dehydrogenase_LD,
    FIRST_Lactate_Dehydrogenase_LD.VALUEUOM AS FIRST_Lactate_Dehydrogenase_LD_UOM,
    FIRST_Lactate_Dehydrogenase_LD.Lactate_Dehydrogenase_LD_charttime,
    FIRST_Lactate_Dehydrogenase_LD.Lactate_Dehydrogenase_LD_storetime, 
    ROUND(FIRST_Required_O2.VALUENUM::numeric,2) AS FIRST_Required_O2,
    FIRST_Required_O2.VALUEUOM AS FIRST_Required_O2_UOM,
    FIRST_Required_O2.Required_O2_charttime,
    FIRST_Required_O2.Required_O2_storetime
    FROM basic AS SUBJECT
LEFT JOIN FIRST_Albumin ON SUBJECT.HADM_ID = FIRST_Albumin.HADM_ID
LEFT JOIN FIRST_pO2 ON SUBJECT.HADM_ID = FIRST_pO2.HADM_ID
LEFT JOIN FIRST_Creatinine ON SUBJECT.HADM_ID = FIRST_Creatinine.HADM_ID
LEFT JOIN FIRST_Lactate_Dehydrogenase_LD ON SUBJECT.HADM_ID = FIRST_Lactate_Dehydrogenase_LD.HADM_ID
LEFT JOIN FIRST_Required_O2 ON SUBJECT.HADM_ID = FIRST_Required_O2.HADM_ID
ORDER BY SUBJECT.SUBJECT_ID;

WITH 
basic AS (
    WITH
    --纳入的诊断
    --肺孢子虫病 Pneumocystosis 
    includedDiagnose1 AS (
        SELECT DISTINCT hadm_id 
        FROM mimiciv_hosp.diagnoses_icd
        WHERE icd_code IN ('B59')
    ),
    --肺囊肿病 Pneumocystosis 
    includedDiagnose2 AS (
        SELECT DISTINCT hadm_id 
        FROM mimiciv_hosp.diagnoses_icd
        WHERE icd_code IN ('1363')
    )
    SELECT 
        DISTINCT ON (icu.subject_id)
        icu.subject_id, 
        icu.stay_id, 
        icu.hadm_id,
        icu.admittime AS admittime,
        icu.dischtime AS dischtime,
        icu.icu_intime AS icu_intime,
        icu.icu_outtime AS icu_outtime
    FROM mimiciv_derived.icustay_detail AS icu
    JOIN mimiciv_derived.age AS age ON age.hadm_id = icu.hadm_id
    WHERE 
        TRUE
        AND age.age BETWEEN 18 AND 120
        AND icu.first_icu_stay = true
        --纳入诊断疾病
        AND (
            --肺孢子虫病 Pneumocystosis 
            icu.hadm_id IN (SELECT hadm_id FROM includedDiagnose1)
            --肺囊肿病 Pneumocystosis 
            OR icu.hadm_id IN (SELECT hadm_id FROM includedDiagnose2)
        )
)
--SELECT * FROM basic;

,
YuHou_Final AS (
    SELECT 
        subject.subject_id,
        MAX(icu.admittime) AS admit_time,
        MAX(icu.dischtime) AS disch_time,
        MAX(icu.icu_intime) AS icu_intime,
        MAX(icu.icu_outtime) AS icu_outtime,
        MAX(admission.deathtime) AS dead_time,
        MAX(icu.dod) AS icu_dod,
                CASE WHEN MAX(admission.deathtime) IS NOT NULL OR MAX(icu.dod)IS NOT NULL THEN 1 ELSE NULL END AS is_dead,

                CASE 
                     WHEN MAX(admission.deathtime) IS NOT NULL 
                     AND MAX(admission.deathtime) NOT BETWEEN MAX(icu.icu_intime) AND MAX(icu.icu_outtime) THEN 1 
                     ELSE 0 
                END AS is_hosp_dead,
                CASE 
                    WHEN MAX(admission.deathtime) BETWEEN MAX(icu.icu_intime) AND MAX(icu.icu_outtime) THEN 1 
                    ELSE 0 
                END AS is_icu_dead
    FROM 
        basic AS subject
    LEFT JOIN mimiciv_derived.icustay_detail AS icu ON subject.subject_id = icu.subject_id
    LEFT JOIN mimiciv_hosp.admissions AS admission ON admission.subject_id = icu.subject_id 
    GROUP BY subject.subject_id
),

YuHou AS (
    SELECT 
        subject.subject_id,
        icu.stay_id,
        icu.hadm_id,
        icu.admittime AS admit_time,
        icu.dischtime AS disch_time,
        icu.icu_intime AS icu_intime,
        icu.icu_outtime AS icu_outtime,
        YuHou_Final.dead_time,
        YuHou_Final.icu_dod,
              YuHou_Final.is_dead,
        CASE
            WHEN adm.deathtime IS NOT NULL THEN 1
            ELSE 0
        END AS death_in_current_adm,

        YuHou_Final.is_hosp_dead,
        YuHou_Final.is_icu_dead,
        ROUND(EXTRACT(EPOCH FROM (icu.dischtime - icu.admittime)) / 86400, 2) AS hosp_day,
        ROUND(EXTRACT(EPOCH FROM (icu.icu_outtime - icu.icu_intime)) / 86400, 2) AS icu_day,
        ROUND(EXTRACT(EPOCH FROM (YuHou_Final.dead_time - icu.admittime)) / 86400, 2) AS hosp_survival_time,
        ROUND(EXTRACT(EPOCH FROM (YuHou_Final.dead_time - icu.icu_intime)) / 86400, 2) AS icu_survival_time,
        CASE
            WHEN YuHou_Final.dead_time IS NOT NULL AND
                 (YuHou_Final.dead_time - icu.admittime) <= INTERVAL '28 days'
            THEN 1
            ELSE 0
        END AS death_within_hosp_28days,
        CASE
            WHEN YuHou_Final.dead_time IS NOT NULL AND
                 (YuHou_Final.dead_time - icu.icu_intime) <= INTERVAL ' 28 days'
            THEN 1
            ELSE 0
        END AS death_within_icu_28days
    FROM 
        basic AS subject
    LEFT JOIN mimiciv_derived.icustay_detail AS icu 
        ON subject.subject_id = icu.subject_id
    LEFT JOIN mimiciv_hosp.admissions AS adm 
        ON icu.hadm_id = adm.hadm_id  
    LEFT JOIN YuHou_Final 
        ON YuHou_Final.subject_id = subject.subject_id
    GROUP BY
        subject.subject_id,
        icu.stay_id,
        icu.hadm_id,
        icu.admittime,
        icu.dischtime,
        icu.icu_intime,
        icu.icu_outtime,
        YuHou_Final.dead_time,
        YuHou_Final.icu_dod,
        YuHou_Final.is_dead,
        YuHou_Final.is_hosp_dead,
        YuHou_Final.is_icu_dead,
        adm.deathtime
)

SELECT * FROM YuHou ORDER BY subject_id,admit_time

WITH 
basic AS (
    WITH
    --纳入的诊断
    --肺孢子虫病 Pneumocystosis 
    includedDiagnose1 AS (
        SELECT DISTINCT hadm_id 
        FROM mimiciv_hosp.diagnoses_icd
        WHERE icd_code IN ('B59')
    ),
    --肺囊肿病 Pneumocystosis 
    includedDiagnose2 AS (
        SELECT DISTINCT hadm_id 
        FROM mimiciv_hosp.diagnoses_icd
        WHERE icd_code IN ('1363')
    )
    SELECT 
        DISTINCT ON (icu.subject_id)
        icu.subject_id, 
        icu.stay_id, 
        icu.hadm_id,
        icu.admittime AS admittime,
        icu.dischtime AS dischtime,
        icu.icu_intime AS icu_intime,
        icu.icu_outtime AS icu_outtime
    FROM mimiciv_derived.icustay_detail AS icu
    JOIN mimiciv_derived.age AS age ON age.hadm_id = icu.hadm_id
    WHERE 
        TRUE
        AND age.age BETWEEN 18 AND 120
        AND icu.first_icu_stay = true
        --纳入诊断疾病
        AND (
            --肺孢子虫病 Pneumocystosis 
            icu.hadm_id IN (SELECT hadm_id FROM includedDiagnose1)
            --肺囊肿病 Pneumocystosis 
            OR icu.hadm_id IN (SELECT hadm_id FROM includedDiagnose2)
        )
)
--SELECT * FROM basic;

,
disease AS (
SELECT
     DISTINCT subject.hadm_id,
     --高血压 HTN
     MAX(CASE WHEN dia.icd_code IN ('4019','I10','4011','I161','4010') THEN 1 ELSE 0 END) AS HTN,
     --肝硬化 LC 
     MAX(CASE WHEN dia.icd_code IN ('5715','5712','K7469','K7460','K7031','K7030','5716','K743') THEN 1 ELSE 0 END) AS LC ,
     --肝炎 HEP
     MAX(CASE WHEN dia.icd_code IN ('B1920','K7581','B182','5711','B181','B1910','K7010','5733','57142','K7011','K754','V0261','K759','V0262') THEN 1 ELSE 0 END) AS HEP,
     --中风 CVA
     MAX(CASE WHEN dia.icd_code IN ('V1254','Z8673','431','43820','43811','4359','V171','43883','99702','G459') THEN 1 ELSE 0 END) AS CVA,
     --慢性肾病 CKD
     MAX(CASE WHEN dia.icd_code IN ('40390','5859','I129','N189','N183','5853','I130','I120','5854','N184','5852','40310','N182','5855','N185','E1122') THEN 1 ELSE 0 END) AS CKD,
     --恶性肿瘤 CA
     MAX(CASE WHEN dia.icd_code IN ('V103','V1046','Z85828','V1083','Z853','1985','Z8546','1977','V1005','1970','1983','C787','C7951','V160','V1011','V1052','V1051','185','Z85038','1976','Z800','V163','19889','Z85118','1629','C786','C7931','Z803','C61','Z8551') THEN 1 ELSE 0 END) AS CA,
     --Ⅱ型糖尿病 T2DM
     MAX(CASE WHEN dia.icd_code IN ('E119','E1122','E1165','E1140','E1151','E11319','E1142','E1121','E11649','E11621','E1169','E1143','E1152','E118','E11610','E11622','E1110','E11628','E1139','E1136','25000','25060','25040','25050','25002','25080','25062','25042','25082','25052','25070','25012','25092','25072','25090') THEN 1 ELSE 0 END) AS T2DM,
     --Ⅰ型糖尿病 T1DM
     MAX(CASE WHEN dia.icd_code IN ('E1022','E10319','E1065','E1040','E1043','E10649','E1010','E1021','E109','E1042','E1051','E10621','25061','25001','25051','25041','25063','25013','25053','25043','25081') THEN 1 ELSE 0 END) AS T1DM,
     --慢性支气管炎 CB
     MAX(CASE WHEN dia.icd_code IN ('49121','49120','4919','J42','4918','J410','4910','J449','J441','J440') THEN 1 ELSE 0 END) AS CB,
     --心力衰竭 HF
     MAX(CASE WHEN dia.icd_code IN ('4280','42832','42822','I5032','42833','I5033','I5022','42823','I5023','I509','42830','42843','42831','I5030','42821','42842','I5021','I5020','42820','I5031','I5043','I5042','40491','40291','42841','4289','42840','I5084','I50810','I5041','I5082','I5040','4281','I50814','I50811','I50813','I50812','40201','40492','I5089','I5083') THEN 1 ELSE 0 END) AS HF,
     --心肌梗死 MI
     MAX(CASE WHEN dia.icd_code IN ('41000','41001','41002','41010','41011','41012','41020','41021','41022','41030','41031','41032','41040','41041','41042','41050','41051','41052','41080','41081','41082','41090','41091','41092','I21','I219','I230','I231','I232','I233','I234','I235','I236','I238','I210','I2101','I2102','I2109','I211','I2111','I2119','I2121','I2129','I213','I214','I21A1','I21A9','I222') THEN 1 ELSE 0 END) AS MI,
     --慢性阻塞性肺病 COPD
     MAX(CASE WHEN dia.icd_code IN ('J430','490','4910','4911','49120','49121','49122','4918','4919','4928','4940','4941','496','J40','J410','J411','J42','J431','J432','J438','J439','J44','J440','J441','J449','4920') THEN 1 ELSE 0 END) AS COPD
  FROM basic AS subject
  INNER JOIN mimiciv_hosp.diagnoses_icd AS dia
  ON subject.hadm_id = dia.hadm_id
  GROUP BY subject.hadm_id
)

SELECT DISTINCT
    basic.subject_id,
    basic.stay_id,
    basic.hadm_id,
    basic.admittime,
    basic.dischtime,
    basic.icu_intime,
    basic.icu_outtime,
    --高血压 HTN
    COALESCE(disease.HTN, 0) AS HTN,
    --肝硬化 LC 
    COALESCE(disease.LC , 0) AS LC ,
    --肝炎 HEP
    COALESCE(disease.HEP, 0) AS HEP,
    --中风 CVA
    COALESCE(disease.CVA, 0) AS CVA,
    --慢性肾病 CKD
    COALESCE(disease.CKD, 0) AS CKD,
    --恶性肿瘤 CA
    COALESCE(disease.CA, 0) AS CA,
    --Ⅱ型糖尿病 T2DM
    COALESCE(disease.T2DM, 0) AS T2DM,
    --Ⅰ型糖尿病 T1DM
    COALESCE(disease.T1DM, 0) AS T1DM,
    --慢性支气管炎 CB
    COALESCE(disease.CB, 0) AS CB,
    --心力衰竭 HF
    COALESCE(disease.HF, 0) AS HF,
    --心肌梗死 MI
    COALESCE(disease.MI, 0) AS MI,
    --慢性阻塞性肺病 COPD
    COALESCE(disease.COPD, 0) AS COPD
FROM basic
LEFT JOIN disease ON basic.hadm_id = disease.hadm_id
ORDER BY basic.subject_id;

WITH 
basic AS (
    WITH
    --纳入的诊断
    --肺孢子虫病 Pneumocystosis 
    includedDiagnose1 AS (
        SELECT DISTINCT hadm_id 
        FROM mimiciv_hosp.diagnoses_icd
        WHERE icd_code IN ('B59')
    ),
    --肺囊肿病 Pneumocystosis 
    includedDiagnose2 AS (
        SELECT DISTINCT hadm_id 
        FROM mimiciv_hosp.diagnoses_icd
        WHERE icd_code IN ('1363')
    )
    SELECT 
        DISTINCT ON (icu.subject_id)
        icu.subject_id, 
        icu.stay_id, 
        icu.hadm_id,
        icu.admittime AS admittime,
        icu.dischtime AS dischtime,
        icu.icu_intime AS icu_intime,
        icu.icu_outtime AS icu_outtime
    FROM mimiciv_derived.icustay_detail AS icu
    JOIN mimiciv_derived.age AS age ON age.hadm_id = icu.hadm_id
    WHERE 
        TRUE
        AND age.age BETWEEN 18 AND 120
        AND icu.first_icu_stay = true
        --纳入诊断疾病
        AND (
            --肺孢子虫病 Pneumocystosis 
            icu.hadm_id IN (SELECT hadm_id FROM includedDiagnose1)
            --肺囊肿病 Pneumocystosis 
            OR icu.hadm_id IN (SELECT hadm_id FROM includedDiagnose2)
        )
)
--SELECT * FROM basic;

,
disease AS (
SELECT
     DISTINCT subject.hadm_id,
     --YZIHI transplant
     MAX(CASE WHEN dia.icd_code IN ('Z9482','99680','99681','99682','99683','99684','99685','99686','99687','99689','V420','V420','V421','V421','V426','V426','V427','V427','V4281','V4282','V4283','Z940','Z941','Z942','Z944','Z946','Z947','Z9481','Z9483','Z9484') THEN 1 ELSE 0 END) AS transplant
  FROM basic AS subject
  INNER JOIN mimiciv_hosp.diagnoses_icd AS dia
  ON subject.hadm_id = dia.hadm_id
  GROUP BY subject.hadm_id
)

SELECT DISTINCT
    basic.subject_id,
    basic.stay_id,
    basic.hadm_id,
    basic.admittime,
    basic.dischtime,
    basic.icu_intime,
    basic.icu_outtime,
    --YZIHI transplant
    COALESCE(disease.transplant, 0) AS transplant
FROM basic
LEFT JOIN disease ON basic.hadm_id = disease.hadm_id
ORDER BY basic.subject_id;

WITH 
basic AS (
    WITH
    --纳入的诊断
    --肺孢子虫病 Pneumocystosis 
    includedDiagnose1 AS (
        SELECT DISTINCT hadm_id 
        FROM mimiciv_hosp.diagnoses_icd
        WHERE icd_code IN ('B59')
    ),
    --肺囊肿病 Pneumocystosis 
    includedDiagnose2 AS (
        SELECT DISTINCT hadm_id 
        FROM mimiciv_hosp.diagnoses_icd
        WHERE icd_code IN ('1363')
    )
    SELECT 
        DISTINCT ON (icu.subject_id)
        icu.subject_id, 
        icu.stay_id, 
        icu.hadm_id,
        icu.admittime AS admittime,
        icu.dischtime AS dischtime,
        icu.icu_intime AS icu_intime,
        icu.icu_outtime AS icu_outtime
    FROM mimiciv_derived.icustay_detail AS icu
    JOIN mimiciv_derived.age AS age ON age.hadm_id = icu.hadm_id
    WHERE 
        TRUE
        AND age.age BETWEEN 18 AND 120
        AND icu.first_icu_stay = true
        --纳入诊断疾病
        AND (
            --肺孢子虫病 Pneumocystosis 
            icu.hadm_id IN (SELECT hadm_id FROM includedDiagnose1)
            --肺囊肿病 Pneumocystosis 
            OR icu.hadm_id IN (SELECT hadm_id FROM includedDiagnose2)
        )
)
--SELECT * FROM basic;

,
disease AS (
SELECT
     DISTINCT subject.hadm_id,
     --HIV HIV
     MAX(CASE WHEN dia.icd_code IN ('042','B20','V08','Z21') THEN 1 ELSE 0 END) AS HIV
  FROM basic AS subject
  INNER JOIN mimiciv_hosp.diagnoses_icd AS dia
  ON subject.hadm_id = dia.hadm_id
  GROUP BY subject.hadm_id
)

SELECT DISTINCT
    basic.subject_id,
    basic.stay_id,
    basic.hadm_id,
    basic.admittime,
    basic.dischtime,
    basic.icu_intime,
    basic.icu_outtime,
    --HIV HIV
    COALESCE(disease.HIV, 0) AS HIV
FROM basic
LEFT JOIN disease ON basic.hadm_id = disease.hadm_id
ORDER BY basic.subject_id;

WITH 
basic AS (
    WITH
    --纳入的诊断
    --肺孢子虫病 Pneumocystosis 
    includedDiagnose1 AS (
        SELECT DISTINCT hadm_id 
        FROM mimiciv_hosp.diagnoses_icd
        WHERE icd_code IN ('B59')
    ),
    --肺囊肿病 Pneumocystosis 
    includedDiagnose2 AS (
        SELECT DISTINCT hadm_id 
        FROM mimiciv_hosp.diagnoses_icd
        WHERE icd_code IN ('1363')
    )
    SELECT 
        DISTINCT ON (icu.subject_id)
        icu.subject_id, 
        icu.stay_id, 
        icu.hadm_id,
        icu.admittime AS admittime,
        icu.dischtime AS dischtime,
        icu.icu_intime AS icu_intime,
        icu.icu_outtime AS icu_outtime
    FROM mimiciv_derived.icustay_detail AS icu
    JOIN mimiciv_derived.age AS age ON age.hadm_id = icu.hadm_id
    WHERE 
        TRUE
        AND age.age BETWEEN 18 AND 120
        AND icu.first_icu_stay = true
        --纳入诊断疾病
        AND (
            --肺孢子虫病 Pneumocystosis 
            icu.hadm_id IN (SELECT hadm_id FROM includedDiagnose1)
            --肺囊肿病 Pneumocystosis 
            OR icu.hadm_id IN (SELECT hadm_id FROM includedDiagnose2)
        )
)
--SELECT * FROM basic;

,
disease AS (
SELECT
     DISTINCT subject.hadm_id,
     --CMV CMV
     MAX(CASE WHEN dia.icd_code IN ('0785','B250','B259') THEN 1 ELSE 0 END) AS CMV
  FROM basic AS subject
  INNER JOIN mimiciv_hosp.diagnoses_icd AS dia
  ON subject.hadm_id = dia.hadm_id
  GROUP BY subject.hadm_id
)

SELECT DISTINCT
    basic.subject_id,
    basic.stay_id,
    basic.hadm_id,
    basic.admittime,
    basic.dischtime,
    basic.icu_intime,
    basic.icu_outtime,
    --CMV CMV
    COALESCE(disease.CMV, 0) AS CMV
FROM basic
LEFT JOIN disease ON basic.hadm_id = disease.hadm_id
ORDER BY basic.subject_id;

WITH 
basic AS (
    WITH
    --纳入的诊断
    --肺孢子虫病 Pneumocystosis 
    includedDiagnose1 AS (
        SELECT DISTINCT hadm_id 
        FROM mimiciv_hosp.diagnoses_icd
        WHERE icd_code IN ('B59')
    ),
    --肺囊肿病 Pneumocystosis 
    includedDiagnose2 AS (
        SELECT DISTINCT hadm_id 
        FROM mimiciv_hosp.diagnoses_icd
        WHERE icd_code IN ('1363')
    )
    SELECT 
        DISTINCT ON (icu.subject_id)
        icu.subject_id, 
        icu.stay_id, 
        icu.hadm_id,
        icu.admittime AS admittime,
        icu.dischtime AS dischtime,
        icu.icu_intime AS icu_intime,
        icu.icu_outtime AS icu_outtime
    FROM mimiciv_derived.icustay_detail AS icu
    JOIN mimiciv_derived.age AS age ON age.hadm_id = icu.hadm_id
    WHERE 
        TRUE
        AND age.age BETWEEN 18 AND 120
        AND icu.first_icu_stay = true
        --纳入诊断疾病
        AND (
            --肺孢子虫病 Pneumocystosis 
            icu.hadm_id IN (SELECT hadm_id FROM includedDiagnose1)
            --肺囊肿病 Pneumocystosis 
            OR icu.hadm_id IN (SELECT hadm_id FROM includedDiagnose2)
        )
)
--SELECT * FROM basic;

,
GC AS
(SELECT DISTINCT(prescriptions.hadm_id),
            1 AS flag,
            MAX(prescriptions.starttime) AS GC_prescriptions_starttime,
            MAX(prescriptions.stoptime) AS GC_prescriptions_stoptime
        FROM mimiciv_hosp.prescriptions AS prescriptions,
            mimiciv_derived.icustay_detail AS icu,
            basic AS subject
        WHERE prescriptions.hadm_id = subject.hadm_id 
            AND subject.stay_id = icu.stay_id
            AND prescriptions.starttime >= icu.icu_intime   
            AND prescriptions.gsn IN ('066110','006705','051558','006704','007544','023906','006696','006858','007545','007543','006724','006725','006753','007894','007892','006786','006784','006788','006776','006778','006789','006721','067556','047282','006745','060958','062053','006780','013701','006762','006758','006812','066112','026721','006749','006738','006742','006754','006748','006750')
    GROUP BY prescriptions.hadm_id
    ),
GC_val  AS
(SELECT DISTINCT(prescriptions.hadm_id),
     SUM(CAST(prescriptions.dose_val_rx AS NUMERIC)) AS dose_val_rx,
          MAX(prescriptions.dose_unit_rx) AS dose_unit_rx
        FROM mimiciv_hosp.prescriptions AS prescriptions,
        mimiciv_derived.icustay_detail AS icu, basic AS subject
        WHERE prescriptions.hadm_id = subject.hadm_id 
            AND subject.stay_id = icu.stay_id
            AND prescriptions.starttime >= icu.icu_intime 
            AND prescriptions.gsn IN ('066110','006705','051558','006704','007544','023906','006696','006858','007545','007543','006724','006725','006753','007894','007892','006786','006784','006788','006776','006778','006789','006721','067556','047282','006745','060958','062053','006780','013701','006762','006758','006812','066112','026721','006749','006738','006742','006754','006748','006750')
            AND prescriptions.dose_val_rx ~ '^[0-9]+(\.[0-9]+)?$'
    GROUP BY prescriptions.hadm_id
    )

   SELECT 
       DISTINCT(subject.subject_id), 
       subject.stay_id, 
       subject.hadm_id,
       subject.admittime,
       subject.dischtime,
       subject.icu_intime,
       subject.icu_outtime,
       GC.flag AS GC,GC_val.dose_val_rx AS GCtotalval, GC_val.dose_unit_rx AS GCunit,
       GC.GC_prescriptions_starttime,
       GC.GC_prescriptions_stoptime
FROM basic AS subject
--糖皮质激素 Glucocorticoids
LEFT JOIN GC ON subject.hadm_id = GC.hadm_id
LEFT JOIN GC_val ON subject.hadm_id = GC_val.hadm_id
ORDER BY subject.subject_id;

WITH 
basic AS (
    WITH
    --纳入的诊断
    --肺孢子虫病 Pneumocystosis 
    includedDiagnose1 AS (
        SELECT DISTINCT hadm_id 
        FROM mimiciv_hosp.diagnoses_icd
        WHERE icd_code IN ('B59')
    ),
    --肺囊肿病 Pneumocystosis 
    includedDiagnose2 AS (
        SELECT DISTINCT hadm_id 
        FROM mimiciv_hosp.diagnoses_icd
        WHERE icd_code IN ('1363')
    )
    SELECT 
        DISTINCT ON (icu.subject_id)
        icu.subject_id, 
        icu.stay_id, 
        icu.hadm_id,
        icu.admittime AS admittime,
        icu.dischtime AS dischtime,
        icu.icu_intime AS icu_intime,
        icu.icu_outtime AS icu_outtime
    FROM mimiciv_derived.icustay_detail AS icu
    JOIN mimiciv_derived.age AS age ON age.hadm_id = icu.hadm_id
    WHERE 
        TRUE
        AND age.age BETWEEN 18 AND 120
        AND icu.first_icu_stay = true
        --纳入诊断疾病
        AND (
            --肺孢子虫病 Pneumocystosis 
            icu.hadm_id IN (SELECT hadm_id FROM includedDiagnose1)
            --肺囊肿病 Pneumocystosis 
            OR icu.hadm_id IN (SELECT hadm_id FROM includedDiagnose2)
        )
)
--SELECT * FROM basic;

,
VP AS
(SELECT DISTINCT(prescriptions.hadm_id),
            1 AS flag,
            MAX(prescriptions.starttime) AS VP_prescriptions_starttime,
            MAX(prescriptions.stoptime) AS VP_prescriptions_stoptime
        FROM mimiciv_hosp.prescriptions AS prescriptions,
            mimiciv_derived.icustay_detail AS icu,
            basic AS subject
        WHERE prescriptions.hadm_id = subject.hadm_id 
            AND subject.stay_id = icu.stay_id
            AND prescriptions.starttime >= icu.icu_intime   
            AND prescriptions.gsn IN ('004977','004985','004975','064575','062006','004939','066419','066452','004937','004931','065336','028633','003388','003389','003390','003385','052187','004934','003387','052188','003386','008022','008062','005068','063864','063863','066206','005066','074949','007764','008061','048541','060981','073081','006612','000141','064535','021502','064538')
    GROUP BY prescriptions.hadm_id
    ),
VP_val  AS
(SELECT DISTINCT(prescriptions.hadm_id),
     SUM(CAST(prescriptions.dose_val_rx AS NUMERIC)) AS dose_val_rx,
          MAX(prescriptions.dose_unit_rx) AS dose_unit_rx
        FROM mimiciv_hosp.prescriptions AS prescriptions,
        mimiciv_derived.icustay_detail AS icu, basic AS subject
        WHERE prescriptions.hadm_id = subject.hadm_id 
            AND subject.stay_id = icu.stay_id
            AND prescriptions.starttime >= icu.icu_intime 
            AND prescriptions.gsn IN ('004977','004985','004975','064575','062006','004939','066419','066452','004937','004931','065336','028633','003388','003389','003390','003385','052187','004934','003387','052188','003386','008022','008062','005068','063864','063863','066206','005066','074949','007764','008061','048541','060981','073081','006612','000141','064535','021502','064538')
            AND prescriptions.dose_val_rx ~ '^[0-9]+(\.[0-9]+)?$'
    GROUP BY prescriptions.hadm_id
    )

   SELECT 
       DISTINCT(subject.subject_id), 
       subject.stay_id, 
       subject.hadm_id,
       subject.admittime,
       subject.dischtime,
       subject.icu_intime,
       subject.icu_outtime,
       VP.flag AS VP,VP_val.dose_val_rx AS VPtotalval, VP_val.dose_unit_rx AS VPunit,
       VP.VP_prescriptions_starttime,
       VP.VP_prescriptions_stoptime
FROM basic AS subject
--血管活性药物（升压药） Vasopressor
LEFT JOIN VP ON subject.hadm_id = VP.hadm_id
LEFT JOIN VP_val ON subject.hadm_id = VP_val.hadm_id
ORDER BY subject.subject_id;

WITH 
basic AS (
    WITH
    --纳入的诊断
    --肺孢子虫病 Pneumocystosis 
    includedDiagnose1 AS (
        SELECT DISTINCT hadm_id 
        FROM mimiciv_hosp.diagnoses_icd
        WHERE icd_code IN ('B59')
    ),
    --肺囊肿病 Pneumocystosis 
    includedDiagnose2 AS (
        SELECT DISTINCT hadm_id 
        FROM mimiciv_hosp.diagnoses_icd
        WHERE icd_code IN ('1363')
    )
    SELECT 
        DISTINCT ON (icu.subject_id)
        icu.subject_id, 
        icu.stay_id, 
        icu.hadm_id,
        icu.admittime AS admittime,
        icu.dischtime AS dischtime,
        icu.icu_intime AS icu_intime,
        icu.icu_outtime AS icu_outtime
    FROM mimiciv_derived.icustay_detail AS icu
    JOIN mimiciv_derived.age AS age ON age.hadm_id = icu.hadm_id
    WHERE 
        TRUE
        AND age.age BETWEEN 18 AND 120
        AND icu.first_icu_stay = true
        --纳入诊断疾病
        AND (
            --肺孢子虫病 Pneumocystosis 
            icu.hadm_id IN (SELECT hadm_id FROM includedDiagnose1)
            --肺囊肿病 Pneumocystosis 
            OR icu.hadm_id IN (SELECT hadm_id FROM includedDiagnose2)
        )
)
--SELECT * FROM basic;

 -- 是不是做过机械通气，做机械通气小时数，首次做机械通气时间
, VENTILATION AS
    (SELECT SUBJECT.STAY_ID,
            ROUND(SUM(MIMICIV_DERIVED.DATETIME_DIFF(VENTILATION.ENDTIME,VENTILATION.STARTTIME,'HOUR')),2) AS VENTILATION_HOUR,
            MIN(VENTILATION.STARTTIME) AS VENTILATION_FIRST_TIME
        FROM basic AS SUBJECT,
            MIMICIV_DERIVED.VENTILATION AS VENTILATION,
        MIMICIV_DERIVED.ICUSTAY_DETAIL AS ICU
        WHERE SUBJECT.STAY_ID = VENTILATION.STAY_ID
                 AND SUBJECT.STAY_ID = ICU.STAY_ID
         AND VENTILATION.STARTTIME >= ICU.ICU_INTIME
        
        GROUP BY SUBJECT.STAY_ID)
SELECT SUBJECT.SUBJECT_ID,
    SUBJECT.STAY_ID,
    SUBJECT.HADM_ID,
    SUBJECT.admittime,
    SUBJECT.dischtime,
    SUBJECT.icu_intime,
    SUBJECT.icu_outtime,
    VENTILATION.VENTILATION_HOUR,
    CASE WHEN VENTILATION.VENTILATION_HOUR IS NOT NULL THEN 1 ELSE NULL END AS VENTILATION,
    VENTILATION.VENTILATION_FIRST_TIME
FROM basic AS SUBJECT
LEFT JOIN VENTILATION ON SUBJECT.STAY_ID = VENTILATION.STAY_ID
ORDER BY SUBJECT.SUBJECT_ID;
WITH 
basic AS (
    WITH
    --纳入的诊断
    --肺孢子虫病 Pneumocystosis 
    includedDiagnose1 AS (
        SELECT DISTINCT hadm_id 
        FROM mimiciv_hosp.diagnoses_icd
        WHERE icd_code IN ('B59')
    ),
    --肺囊肿病 Pneumocystosis 
    includedDiagnose2 AS (
        SELECT DISTINCT hadm_id 
        FROM mimiciv_hosp.diagnoses_icd
        WHERE icd_code IN ('1363')
    )
    SELECT 
        DISTINCT ON (icu.subject_id)
        icu.subject_id, 
        icu.stay_id, 
        icu.hadm_id,
        icu.admittime AS admittime,
        icu.dischtime AS dischtime,
        icu.icu_intime AS icu_intime,
        icu.icu_outtime AS icu_outtime
    FROM mimiciv_derived.icustay_detail AS icu
    JOIN mimiciv_derived.age AS age ON age.hadm_id = icu.hadm_id
    WHERE 
        TRUE
        AND age.age BETWEEN 18 AND 120
        AND icu.first_icu_stay = true
        --纳入诊断疾病
        AND (
            --肺孢子虫病 Pneumocystosis 
            icu.hadm_id IN (SELECT hadm_id FROM includedDiagnose1)
            --肺囊肿病 Pneumocystosis 
            OR icu.hadm_id IN (SELECT hadm_id FROM includedDiagnose2)
        )
)
--SELECT * FROM basic;

-- 是不是做过CRRT，做CRRT天数，首次做CRRT时间
, CRRT AS
    (SELECT SUBJECT.STAY_ID,
            COUNT(DISTINCT DATE(CHARTTIME)) AS CRRT_DAY,
            MIN(CRRT.CHARTTIME) AS CRRT_FIRST_TIME
        FROM basic AS SUBJECT,
            MIMICIV_DERIVED.CRRT AS CRRT,
        MIMICIV_DERIVED.ICUSTAY_DETAIL AS ICU
        WHERE SUBJECT.STAY_ID = CRRT.STAY_ID
                 AND SUBJECT.STAY_ID = ICU.STAY_ID
         AND CRRT.CHARTTIME >= ICU.ICU_INTIME
        GROUP BY SUBJECT.STAY_ID)
SELECT SUBJECT.SUBJECT_ID,
    SUBJECT.STAY_ID,
    SUBJECT.HADM_ID,
    SUBJECT.admittime,
    SUBJECT.dischtime,
    SUBJECT.icu_intime,
    SUBJECT.icu_outtime,
    CASE WHEN CRRT.CRRT_DAY IS NOT NULL THEN 1 ELSE NULL END AS CRRT,
    CRRT.CRRT_DAY,
    CRRT.CRRT_FIRST_TIME
FROM basic AS SUBJECT
LEFT JOIN CRRT ON SUBJECT.STAY_ID = CRRT.STAY_ID
ORDER BY SUBJECT.SUBJECT_ID;
WITH 
basic AS (
    WITH
    --纳入的诊断
    --肺孢子虫病 Pneumocystosis 
    includedDiagnose1 AS (
        SELECT DISTINCT hadm_id 
        FROM mimiciv_hosp.diagnoses_icd
        WHERE icd_code IN ('B59')
    ),
    --肺囊肿病 Pneumocystosis 
    includedDiagnose2 AS (
        SELECT DISTINCT hadm_id 
        FROM mimiciv_hosp.diagnoses_icd
        WHERE icd_code IN ('1363')
    )
    SELECT 
        DISTINCT ON (icu.subject_id)
        icu.subject_id, 
        icu.stay_id, 
        icu.hadm_id,
        icu.admittime AS admittime,
        icu.dischtime AS dischtime,
        icu.icu_intime AS icu_intime,
        icu.icu_outtime AS icu_outtime
    FROM mimiciv_derived.icustay_detail AS icu
    JOIN mimiciv_derived.age AS age ON age.hadm_id = icu.hadm_id
    WHERE 
        TRUE
        AND age.age BETWEEN 18 AND 120
        AND icu.first_icu_stay = true
        --纳入诊断疾病
        AND (
            --肺孢子虫病 Pneumocystosis 
            icu.hadm_id IN (SELECT hadm_id FROM includedDiagnose1)
            --肺囊肿病 Pneumocystosis 
            OR icu.hadm_id IN (SELECT hadm_id FROM includedDiagnose2)
        )
)
--SELECT * FROM basic;

SELECT  
    DISTINCT(subject.subject_id), 
    subject.stay_id,
    subject.hadm_id,
    subject.admittime,
    subject.dischtime,
    subject.icu_intime,
    subject.icu_outtime,
    sofa.sofa, 
    sapsii.sapsii, 
    oasis.oasis

FROM basic AS subject
LEFT JOIN mimiciv_derived.first_day_sofa AS sofa ON subject.stay_id = sofa.stay_id
LEFT JOIN mimiciv_derived.sapsii AS sapsii ON subject.stay_id = sapsii.stay_id
LEFT JOIN mimiciv_derived.oasis AS oasis ON subject.stay_id = oasis.stay_id
ORDER BY subject.subject_id;
WITH 
basic AS (
    WITH
    --纳入的诊断
    --肺孢子虫病 Pneumocystosis 
    includedDiagnose1 AS (
        SELECT DISTINCT hadm_id 
        FROM mimiciv_hosp.diagnoses_icd
        WHERE icd_code IN ('B59')
    ),
    --肺囊肿病 Pneumocystosis 
    includedDiagnose2 AS (
        SELECT DISTINCT hadm_id 
        FROM mimiciv_hosp.diagnoses_icd
        WHERE icd_code IN ('1363')
    )
    SELECT 
        DISTINCT ON (icu.subject_id)
        icu.subject_id, 
        icu.stay_id, 
        icu.hadm_id,
        icu.admittime AS admittime,
        icu.dischtime AS dischtime,
        icu.icu_intime AS icu_intime,
        icu.icu_outtime AS icu_outtime
    FROM mimiciv_derived.icustay_detail AS icu
    JOIN mimiciv_derived.age AS age ON age.hadm_id = icu.hadm_id
    WHERE 
        TRUE
        AND age.age BETWEEN 18 AND 120
        AND icu.first_icu_stay = true
        --纳入诊断疾病
        AND (
            --肺孢子虫病 Pneumocystosis 
            icu.hadm_id IN (SELECT hadm_id FROM includedDiagnose1)
            --肺囊肿病 Pneumocystosis 
            OR icu.hadm_id IN (SELECT hadm_id FROM includedDiagnose2)
        )
)
--SELECT * FROM basic;

,
--卡那霉素去敏 Caspofungin Desensitization
Caspofungin_Desensitization AS
(SELECT DISTINCT(prescriptions.hadm_id),
         1 AS flag,
         MAX(prescriptions.starttime) AS Caspofungin_Desensitization_prescriptions_starttime,
         MAX(prescriptions.stoptime) AS Caspofungin_Desensitization_prescriptions_stoptime
FROM mimiciv_hosp.prescriptions AS prescriptions,
     basic AS subject
WHERE prescriptions.hadm_id = subject.hadm_id 
    AND prescriptions.gsn IN ('047689')
GROUP BY prescriptions.hadm_id
),
Caspofungin_Desensitization_val AS
(SELECT DISTINCT(prescriptions.hadm_id),
SUM(CAST(prescriptions.dose_val_rx AS numeric)) AS dose_val_rx,
        MAX(prescriptions.dose_unit_rx) AS dose_unit_rx
   FROM mimiciv_hosp.prescriptions AS prescriptions, basic AS subject
   WHERE prescriptions.hadm_id = subject.hadm_id 
        AND prescriptions.gsn IN ('047689')
        AND prescriptions.dose_val_rx ~ '^[0-9]+(\.[0-9]+)?$'
   GROUP BY prescriptions.hadm_id
   ),
--阿托伐醌悬浮液 Atovaquone Suspension
Atovaquone_Suspension AS
(SELECT DISTINCT(prescriptions.hadm_id),
         1 AS flag,
         MAX(prescriptions.starttime) AS Atovaquone_Suspension_prescriptions_starttime,
         MAX(prescriptions.stoptime) AS Atovaquone_Suspension_prescriptions_stoptime
FROM mimiciv_hosp.prescriptions AS prescriptions,
     basic AS subject
WHERE prescriptions.hadm_id = subject.hadm_id 
    AND prescriptions.gsn IN ('023399')
GROUP BY prescriptions.hadm_id
),
Atovaquone_Suspension_val AS
(SELECT DISTINCT(prescriptions.hadm_id),
SUM(CAST(prescriptions.dose_val_rx AS numeric)) AS dose_val_rx,
        MAX(prescriptions.dose_unit_rx) AS dose_unit_rx
   FROM mimiciv_hosp.prescriptions AS prescriptions, basic AS subject
   WHERE prescriptions.hadm_id = subject.hadm_id 
        AND prescriptions.gsn IN ('023399')
        AND prescriptions.dose_val_rx ~ '^[0-9]+(\.[0-9]+)?$'
   GROUP BY prescriptions.hadm_id
   ),
--Primaquine磷酸鹽 Primaquine Phosphate
Primaquine_Phosphate AS
(SELECT DISTINCT(prescriptions.hadm_id),
         1 AS flag,
         MAX(prescriptions.starttime) AS Primaquine_Phosphate_prescriptions_starttime,
         MAX(prescriptions.stoptime) AS Primaquine_Phosphate_prescriptions_stoptime
FROM mimiciv_hosp.prescriptions AS prescriptions,
     basic AS subject
WHERE prescriptions.hadm_id = subject.hadm_id 
    AND prescriptions.gsn IN ('009344','009339','013053','009346','015999','007727','013052','009577')
GROUP BY prescriptions.hadm_id
),
Primaquine_Phosphate_val AS
(SELECT DISTINCT(prescriptions.hadm_id),
SUM(CAST(prescriptions.dose_val_rx AS numeric)) AS dose_val_rx,
        MAX(prescriptions.dose_unit_rx) AS dose_unit_rx
   FROM mimiciv_hosp.prescriptions AS prescriptions, basic AS subject
   WHERE prescriptions.hadm_id = subject.hadm_id 
        AND prescriptions.gsn IN ('009344','009339','013053','009346','015999','007727','013052','009577')
        AND prescriptions.dose_val_rx ~ '^[0-9]+(\.[0-9]+)?$'
   GROUP BY prescriptions.hadm_id
   ),
--喷他米星异磷酸盐 Pentamidine Isethionate
Pentamidine_Isethionate2 AS
(SELECT DISTINCT(prescriptions.hadm_id),
         1 AS flag,
         MAX(prescriptions.starttime) AS Pentamidine_Isethionate2_prescriptions_starttime,
         MAX(prescriptions.stoptime) AS Pentamidine_Isethionate2_prescriptions_stoptime
FROM mimiciv_hosp.prescriptions AS prescriptions,
     basic AS subject
WHERE prescriptions.hadm_id = subject.hadm_id 
    AND prescriptions.gsn IN ('011791','009599')
GROUP BY prescriptions.hadm_id
),
Pentamidine_Isethionate2_val AS
(SELECT DISTINCT(prescriptions.hadm_id),
SUM(CAST(prescriptions.dose_val_rx AS numeric)) AS dose_val_rx,
        MAX(prescriptions.dose_unit_rx) AS dose_unit_rx
   FROM mimiciv_hosp.prescriptions AS prescriptions, basic AS subject
   WHERE prescriptions.hadm_id = subject.hadm_id 
        AND prescriptions.gsn IN ('011791','009599')
        AND prescriptions.dose_val_rx ~ '^[0-9]+(\.[0-9]+)?$'
   GROUP BY prescriptions.hadm_id
   ),
--复方三甲嘧啶 Trimethoprim
Trimethoprim AS
(SELECT DISTINCT(prescriptions.hadm_id),
         1 AS flag,
         MAX(prescriptions.starttime) AS Trimethoprim_prescriptions_starttime,
         MAX(prescriptions.stoptime) AS Trimethoprim_prescriptions_stoptime
FROM mimiciv_hosp.prescriptions AS prescriptions,
     basic AS subject
WHERE prescriptions.hadm_id = subject.hadm_id 
    AND prescriptions.gsn IN ('009497')
GROUP BY prescriptions.hadm_id
),
Trimethoprim_val AS
(SELECT DISTINCT(prescriptions.hadm_id),
SUM(CAST(prescriptions.dose_val_rx AS numeric)) AS dose_val_rx,
        MAX(prescriptions.dose_unit_rx) AS dose_unit_rx
   FROM mimiciv_hosp.prescriptions AS prescriptions, basic AS subject
   WHERE prescriptions.hadm_id = subject.hadm_id 
        AND prescriptions.gsn IN ('009497')
        AND prescriptions.dose_val_rx ~ '^[0-9]+(\.[0-9]+)?$'
   GROUP BY prescriptions.hadm_id
   )

   SELECT 
       DISTINCT(subject.subject_id), 
       subject.stay_id, 
       subject.hadm_id,
       subject.admittime,
       subject.dischtime,
       subject.icu_intime,
       subject.icu_outtime,
       Caspofungin_Desensitization.flag AS Caspofungin_Desensitization,Caspofungin_Desensitization_val.dose_val_rx AS Caspofungin_Desensitizationtotalval, Caspofungin_Desensitization_val.dose_unit_rx AS Caspofungin_Desensitizationunit,
       Caspofungin_Desensitization.Caspofungin_Desensitization_prescriptions_starttime,
       Caspofungin_Desensitization.Caspofungin_Desensitization_prescriptions_stoptime,
       Atovaquone_Suspension.flag AS Atovaquone_Suspension,Atovaquone_Suspension_val.dose_val_rx AS Atovaquone_Suspensiontotalval, Atovaquone_Suspension_val.dose_unit_rx AS Atovaquone_Suspensionunit,
       Atovaquone_Suspension.Atovaquone_Suspension_prescriptions_starttime,
       Atovaquone_Suspension.Atovaquone_Suspension_prescriptions_stoptime,
       Primaquine_Phosphate.flag AS Primaquine_Phosphate,Primaquine_Phosphate_val.dose_val_rx AS Primaquine_Phosphatetotalval, Primaquine_Phosphate_val.dose_unit_rx AS Primaquine_Phosphateunit,
       Primaquine_Phosphate.Primaquine_Phosphate_prescriptions_starttime,
       Primaquine_Phosphate.Primaquine_Phosphate_prescriptions_stoptime,
       Pentamidine_Isethionate2.flag AS Pentamidine_Isethionate2,Pentamidine_Isethionate2_val.dose_val_rx AS Pentamidine_Isethionate2totalval, Pentamidine_Isethionate2_val.dose_unit_rx AS Pentamidine_Isethionate2unit,
       Pentamidine_Isethionate2.Pentamidine_Isethionate2_prescriptions_starttime,
       Pentamidine_Isethionate2.Pentamidine_Isethionate2_prescriptions_stoptime,
       Trimethoprim.flag AS Trimethoprim,Trimethoprim_val.dose_val_rx AS Trimethoprimtotalval, Trimethoprim_val.dose_unit_rx AS Trimethoprimunit,
       Trimethoprim.Trimethoprim_prescriptions_starttime,
       Trimethoprim.Trimethoprim_prescriptions_stoptime
FROM basic AS subject
--卡那霉素去敏 Caspofungin Desensitization
LEFT JOIN Caspofungin_Desensitization ON subject.hadm_id = Caspofungin_Desensitization.hadm_id
LEFT JOIN Caspofungin_Desensitization_val ON subject.hadm_id = Caspofungin_Desensitization_val.hadm_id
--阿托伐醌悬浮液 Atovaquone Suspension
LEFT JOIN Atovaquone_Suspension ON subject.hadm_id = Atovaquone_Suspension.hadm_id
LEFT JOIN Atovaquone_Suspension_val ON subject.hadm_id = Atovaquone_Suspension_val.hadm_id
--Primaquine磷酸鹽 Primaquine Phosphate
LEFT JOIN Primaquine_Phosphate ON subject.hadm_id = Primaquine_Phosphate.hadm_id
LEFT JOIN Primaquine_Phosphate_val ON subject.hadm_id = Primaquine_Phosphate_val.hadm_id
--喷他米星异磷酸盐 Pentamidine Isethionate
LEFT JOIN Pentamidine_Isethionate2 ON subject.hadm_id = Pentamidine_Isethionate2.hadm_id
LEFT JOIN Pentamidine_Isethionate2_val ON subject.hadm_id = Pentamidine_Isethionate2_val.hadm_id
--复方三甲嘧啶 Trimethoprim
LEFT JOIN Trimethoprim ON subject.hadm_id = Trimethoprim.hadm_id
LEFT JOIN Trimethoprim_val ON subject.hadm_id = Trimethoprim_val.hadm_id
ORDER BY subject.subject_id;

WITH 
basic AS (
    WITH
    --纳入的诊断
    --肺孢子虫病 Pneumocystosis 
    includedDiagnose1 AS (
        SELECT DISTINCT hadm_id 
        FROM mimiciv_hosp.diagnoses_icd
        WHERE icd_code IN ('B59')
    ),
    --肺囊肿病 Pneumocystosis 
    includedDiagnose2 AS (
        SELECT DISTINCT hadm_id 
        FROM mimiciv_hosp.diagnoses_icd
        WHERE icd_code IN ('1363')
    )
    SELECT 
        DISTINCT ON (icu.subject_id)
        icu.subject_id, 
        icu.stay_id, 
        icu.hadm_id,
        icu.admittime AS admittime,
        icu.dischtime AS dischtime,
        icu.icu_intime AS icu_intime,
        icu.icu_outtime AS icu_outtime
    FROM mimiciv_derived.icustay_detail AS icu
    JOIN mimiciv_derived.age AS age ON age.hadm_id = icu.hadm_id
    WHERE 
        TRUE
        AND age.age BETWEEN 18 AND 120
        AND icu.first_icu_stay = true
        --纳入诊断疾病
        AND (
            --肺孢子虫病 Pneumocystosis 
            icu.hadm_id IN (SELECT hadm_id FROM includedDiagnose1)
            --肺囊肿病 Pneumocystosis 
            OR icu.hadm_id IN (SELECT hadm_id FROM includedDiagnose2)
        )
)
--SELECT * FROM basic;

,
Drug1 AS
(SELECT DISTINCT(prescriptions.hadm_id),
            1 AS flag,
            MAX(prescriptions.starttime) AS Drug1_prescriptions_starttime,
            MAX(prescriptions.stoptime) AS Drug1_prescriptions_stoptime
        FROM mimiciv_hosp.prescriptions AS prescriptions,
            mimiciv_derived.icustay_detail AS icu,
            basic AS subject
        WHERE prescriptions.hadm_id = subject.hadm_id 
            AND subject.stay_id = icu.stay_id
            AND prescriptions.starttime >= icu.icu_intime   
            AND prescriptions.gsn IN ('009396','009393','009394','071217')
    GROUP BY prescriptions.hadm_id
    ),
Drug1_val  AS
(SELECT DISTINCT(prescriptions.hadm_id),
     SUM(CAST(prescriptions.dose_val_rx AS NUMERIC)) AS dose_val_rx,
          MAX(prescriptions.dose_unit_rx) AS dose_unit_rx
        FROM mimiciv_hosp.prescriptions AS prescriptions,
        mimiciv_derived.icustay_detail AS icu, basic AS subject
        WHERE prescriptions.hadm_id = subject.hadm_id 
            AND subject.stay_id = icu.stay_id
            AND prescriptions.starttime >= icu.icu_intime 
            AND prescriptions.gsn IN ('009396','009393','009394','071217')
            AND prescriptions.dose_val_rx ~ '^[0-9]+(\.[0-9]+)?$'
    GROUP BY prescriptions.hadm_id
    )

   SELECT 
       DISTINCT(subject.subject_id), 
       subject.stay_id, 
       subject.hadm_id,
       subject.admittime,
       subject.dischtime,
       subject.icu_intime,
       subject.icu_outtime,
       Drug1.flag AS Drug1,Drug1_val.dose_val_rx AS Drug1totalval, Drug1_val.dose_unit_rx AS Drug1unit,
       Drug1.Drug1_prescriptions_starttime,
       Drug1.Drug1_prescriptions_stoptime
FROM basic AS subject
--SMZ-TMP‌ SMZ-TMP‌
LEFT JOIN Drug1 ON subject.hadm_id = Drug1.hadm_id
LEFT JOIN Drug1_val ON subject.hadm_id = Drug1_val.hadm_id
ORDER BY subject.subject_id;
WITH 
basic AS (
    WITH
    --纳入的诊断
    --肺孢子虫病 Pneumocystosis 
    includedDiagnose1 AS (
        SELECT DISTINCT hadm_id 
        FROM mimiciv_hosp.diagnoses_icd
        WHERE icd_code IN ('B59')
    ),
    --肺囊肿病 Pneumocystosis 
    includedDiagnose2 AS (
        SELECT DISTINCT hadm_id 
        FROM mimiciv_hosp.diagnoses_icd
        WHERE icd_code IN ('1363')
    )
    SELECT 
        DISTINCT ON (icu.subject_id)
        icu.subject_id, 
        icu.stay_id, 
        icu.hadm_id,
        icu.admittime AS admittime,
        icu.dischtime AS dischtime,
        icu.icu_intime AS icu_intime,
        icu.icu_outtime AS icu_outtime
    FROM mimiciv_derived.icustay_detail AS icu
    JOIN mimiciv_derived.age AS age ON age.hadm_id = icu.hadm_id
    WHERE 
        TRUE
        AND age.age BETWEEN 18 AND 120
        AND icu.first_icu_stay = true
        --纳入诊断疾病
        AND (
            --肺孢子虫病 Pneumocystosis 
            icu.hadm_id IN (SELECT hadm_id FROM includedDiagnose1)
            --肺囊肿病 Pneumocystosis 
            OR icu.hadm_id IN (SELECT hadm_id FROM includedDiagnose2)
        )
)
--SELECT * FROM basic;

,
-- CD4细胞绝对计数 Absolute CD4 Count 
FIRST_Absolute_CD4_Count AS
    (SELECT DISTINCT ON (LAB.HADM_ID) LAB.HADM_ID,LAB.VALUENUM, LAB.VALUEUOM,
    LAB.charttime AS Absolute_CD4_Count_charttime,
    LAB.storetime AS Absolute_CD4_Count_storetime
    FROM basic AS SUBJECT,
    MIMICIV_DERIVED.ICUSTAY_DETAIL AS ICU,
    MIMICIV_HOSP.LABEVENTS AS LAB
    WHERE LAB.ITEMID = 51131
    AND LAB.CHARTTIME >= ICU.ICU_INTIME
    AND SUBJECT.STAY_ID = ICU.STAY_ID
    AND SUBJECT.HADM_ID = LAB.HADM_ID
    ORDER BY LAB.HADM_ID,LAB.CHARTTIME)
,
-- CD4细胞百分比 CD4 Cells, Percent 
FIRST_CD4_Cells_Percent AS
    (SELECT DISTINCT ON (LAB.HADM_ID) LAB.HADM_ID,LAB.VALUENUM, LAB.VALUEUOM,
    LAB.charttime AS CD4_Cells_Percent_charttime,
    LAB.storetime AS CD4_Cells_Percent_storetime
    FROM basic AS SUBJECT,
    MIMICIV_DERIVED.ICUSTAY_DETAIL AS ICU,
    MIMICIV_HOSP.LABEVENTS AS LAB
    WHERE LAB.ITEMID = 51180
    AND LAB.CHARTTIME >= ICU.ICU_INTIME
    AND SUBJECT.STAY_ID = ICU.STAY_ID
    AND SUBJECT.HADM_ID = LAB.HADM_ID
    ORDER BY LAB.HADM_ID,LAB.CHARTTIME)

 SELECT 
    DISTINCT(SUBJECT.SUBJECT_ID),
    SUBJECT.STAY_ID,
    SUBJECT.HADM_ID,
    SUBJECT.admittime,
    SUBJECT.dischtime,
    SUBJECT.icu_intime,
    SUBJECT.icu_outtime,
    ROUND(FIRST_Absolute_CD4_Count.VALUENUM::numeric,2) AS FIRST_Absolute_CD4_Count,
    FIRST_Absolute_CD4_Count.VALUEUOM AS FIRST_Absolute_CD4_Count_UOM,
    FIRST_Absolute_CD4_Count.Absolute_CD4_Count_charttime,
    FIRST_Absolute_CD4_Count.Absolute_CD4_Count_storetime, 
    ROUND(FIRST_CD4_Cells_Percent.VALUENUM::numeric,2) AS FIRST_CD4_Cells_Percent,
    FIRST_CD4_Cells_Percent.VALUEUOM AS FIRST_CD4_Cells_Percent_UOM,
    FIRST_CD4_Cells_Percent.CD4_Cells_Percent_charttime,
    FIRST_CD4_Cells_Percent.CD4_Cells_Percent_storetime
    FROM basic AS SUBJECT
LEFT JOIN FIRST_Absolute_CD4_Count ON SUBJECT.HADM_ID = FIRST_Absolute_CD4_Count.HADM_ID
LEFT JOIN FIRST_CD4_Cells_Percent ON SUBJECT.HADM_ID = FIRST_CD4_Cells_Percent.HADM_ID
ORDER BY SUBJECT.SUBJECT_ID;




