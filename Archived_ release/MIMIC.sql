WITH
basic AS (
    WITH
    --Pneumocystosis ICD-10
    includedDiagnose1 AS (
        SELECT DISTINCT hadm_id
        FROM mimiciv_hosp.diagnoses_icd
        WHERE icd_code IN ('B59')
    ),
    --Pneumocystosis ICD-9
    includedDiagnose2 AS (
        SELECT DISTINCT hadm_id
        FROM mimiciv_hosp.diagnoses_icd
        WHERE icd_code IN ('136.3')
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
        AND (
            icu.hadm_id IN (SELECT hadm_id FROM includedDiagnose1)
            OR icu.hadm_id IN (SELECT hadm_id FROM includedDiagnose2)
        )
)
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
    height.height
FROM basic AS subject
LEFT JOIN mimiciv_derived.age AS age ON subject.hadm_id = age.hadm_id
LEFT JOIN mimiciv_derived.icustay_detail AS icu ON subject.stay_id = icu.stay_id
LEFT JOIN mimiciv_derived.first_day_weight AS weight ON subject.stay_id = weight.stay_id
LEFT JOIN mimiciv_derived.first_day_height AS height ON subject.stay_id = height.stay_id
ORDER BY subject.subject_id;

WITH
basic AS (
    WITH
    includedDiagnose1 AS (
        SELECT DISTINCT hadm_id
        FROM mimiciv_hosp.diagnoses_icd
        WHERE icd_code IN ('B59')
    ),
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
        icu.icu_outtime AS icu_outtime,
        pat.dod AS patient_dod
    FROM mimiciv_derived.icustay_detail AS icu
    JOIN mimiciv_derived.age AS age ON age.hadm_id = icu.hadm_id
    LEFT JOIN mimiciv_hosp.patients pat ON pat.subject_id = icu.subject_id
    WHERE
        TRUE
        AND age.age BETWEEN 18 AND 120
        AND icu.first_icu_stay = true
        AND (
            icu.hadm_id IN (SELECT hadm_id FROM includedDiagnose1)
            OR icu.hadm_id IN (SELECT hadm_id FROM includedDiagnose2)
        )
),
disease_raw AS (
SELECT
    hadm_id,
    MAX(CASE WHEN dia.icd_code IN ('4019','I10','4011','I161','4010') THEN 1 ELSE 0 END) AS HTN,
    MAX(CASE WHEN dia.icd_code IN ('5715','5712','K7469','K7460','K7031','K7030','5716','K743') THEN 1 ELSE 0 END) AS LC ,
    MAX(CASE WHEN dia.icd_code IN ('B1920','K7581','B182','5711','B181','B1910','K7010','5733','57142','K7011','K754','V0261','K759','V0262') THEN 1 ELSE 0 END) AS HEP,
    MAX(CASE WHEN dia.icd_code IN ('V1254','Z8673','431','43820','43811','4359','V171','43883','99702','G459') THEN 1 ELSE 0 END) AS CVA,
    MAX(CASE WHEN dia.icd_code IN ('40390','5859','I129','N189','N183','5853','I130','I120','5854','N184','5852','40310','N182','5855','N185','E1122') THEN 1 ELSE 0 END) AS CKD,
    MAX(CASE WHEN dia.icd_code IN ('V103','V1046','Z85828','V1083','Z853','1985','Z8546','1977','V1005','1970','1983','C787','C7951','V160','V1011','V1052','V1051','185','Z85038','1976','Z800','V163','19889','Z85118','1629','C786','C7931','Z803','C61','Z8551') THEN 1 ELSE 0 END) AS CA,
    MAX(CASE WHEN dia.icd_code IN ('E119','E1122','E1165','E1140','E1151','E11319','E1142','E1121','E11649','E11621','E1169','E1143','E1152','E118','E11610','E11622','E1110','E11628','E1139','E1136','25000','25060','25040','25050','25002','25080','25062','25042','25082','25052','25070','25012','25092','25072','25090') THEN 1 ELSE 0 END) AS T2DM,
    MAX(CASE WHEN dia.icd_code IN ('E1022','E10319','E1065','E1040','E1043','E10649','E1010','E1021','E109','E1042','E1051','E10621','25061','25001','25051','25041','25063','25013','25053','25043','25081') THEN 1 ELSE 0 END) AS T1DM,
    MAX(CASE WHEN dia.icd_code IN ('49121','49120','4919','J42','4918','J410','4910','J449','J441','J440') THEN 1 ELSE 0 END) AS CB,
    MAX(CASE WHEN dia.icd_code IN ('4280','42832','42822','I5032','42833','I5033','I5022','42823','I5023','I509','42830','42843','42831','I5030','42821','42842','I5021','I5020','42820','I5031','I5043','I5042','40491','40291','42841','4289','42840','I5084','I50810','I5082','I5041','I5040','4281','I50814','I50811','I50813','I50812','40201','40492','I5089','I5083') THEN 1 ELSE 0 END) AS HF,
    MAX(CASE WHEN dia.icd_code IN ('41000','41001','41002','41010','41011','41012','41020','41021','41022','41030','41031','41032','41040','41041','41042','41050','41051','41052','41080','41081','41082','41090','41091','41092','I21','I219','I230','I231','I232','I233','I234','I235','I236','I238','I210','I2101','I2102','I2109','I211','I2111','I2119','I2121','I2129','I213','I214','I21A1','I21A9','I222') THEN 1 ELSE 0 END) AS MI,
    MAX(CASE WHEN dia.icd_code IN ('J430','490','4910','4911','49120','49121','49122','4918','4919','4928','4940','4941','496','J40','J410','J411','J42','J431','J432','J438','J439','J44','J440','J441','J449','4920') THEN 1 ELSE 0 END) AS COPD,
    MAX(CASE WHEN dia.icd_code IN ('Z9482','99680','99681','99682','99683','99684','99685','99686','99687','99689','V420','V420','V421','V421','V426','V426','V427','V427','V4281','V4282','V4283','Z940','Z941','Z942','Z944','Z946','Z947','Z9481','Z9483','Z9484') THEN 1 ELSE 0 END) AS transplant,
    MAX(CASE WHEN dia.icd_code IN ('042','B20','V08','Z21') THEN 1 ELSE 0 END) AS HIV,
    MAX(CASE WHEN dia.icd_code IN ('0785','B250','B259') THEN 1 ELSE 0 END) AS CMV
FROM mimiciv_hosp.diagnoses_icd AS dia
GROUP BY hadm_id
),
disease AS (
SELECT
    hadm_id,
    COALESCE(HTN,0) AS Hypertension,
    COALESCE(CASE WHEN T2DM = 1 OR T1DM = 1 THEN 1 ELSE 0 END,0) AS Diabetes,
    COALESCE(CASE WHEN CVA = 1 OR HF = 1 OR MI = 1 THEN 1 ELSE 0 END,0) AS MACE,
    COALESCE(CASE WHEN LC = 1 OR HEP = 1 THEN 1 ELSE 0 END,0) AS Liver_disease,
    COALESCE(CKD,0) AS Renal_disease,
    COALESCE(CASE WHEN COPD = 1 OR CB = 1 THEN 1 ELSE 0 END,0) AS Chronic_pulmonary_disease,
    COALESCE(CA,0) AS Malignant_neoplasms,
    COALESCE(transplant,0) AS Organ_transplant,
    COALESCE(HIV,0) AS HIV_infection,
    COALESCE(CMV,0) AS CMV_infection
FROM disease_raw
),
patient_anthropometry AS (
    SELECT
        subject_id,
        hadm_id,
        weight,
        height,
        ROUND(weight / ((height/100.0)^2), 2) AS BMI
    FROM mimiciv_derived.heightweight
),
CBC_anchor AS (
    SELECT DISTINCT ON (lab.hadm_id)
        lab.hadm_id,
        lab.charttime,
        lab.storetime
    FROM basic
    JOIN mimiciv_hosp.labevents AS lab ON basic.hadm_id = lab.hadm_id
    WHERE lab.itemid = 51301 -- WBC
      AND lab.charttime > basic.icu_intime
      AND lab.charttime < basic.icu_outtime
    ORDER BY lab.hadm_id, lab.charttime
),
First_White_Blood_Cells AS (
    SELECT
        anc.hadm_id,
        lab.valuenum,
        lab.charttime AS White_Blood_Cells_charttime,
        lab.storetime AS White_Blood_Cells_storetime
    FROM CBC_anchor AS anc
    JOIN mimiciv_hosp.labevents AS lab
      ON anc.hadm_id = lab.hadm_id
     AND anc.charttime = lab.charttime
     AND anc.storetime = lab.storetime
    WHERE lab.itemid = 51301
),
First_Lymphocytes AS (
    SELECT
        anc.hadm_id,
        lab.valuenum,
        lab.charttime AS Lymphocytes_charttime,
        lab.storetime AS Lymphocytes_storetime
    FROM CBC_anchor AS anc
    JOIN mimiciv_hosp.labevents AS lab
      ON anc.hadm_id = lab.hadm_id
     AND anc.charttime = lab.charttime
     AND anc.storetime = lab.storetime
    WHERE lab.itemid = 51244
),
First_Neutrophils AS (
    SELECT
        anc.hadm_id,
        lab.valuenum,
        lab.charttime AS Neutrophils_charttime,
        lab.storetime AS Neutrophils_storetime
    FROM CBC_anchor AS anc
    JOIN mimiciv_hosp.labevents AS lab
      ON anc.hadm_id = lab.hadm_id
     AND anc.charttime = lab.charttime
     AND anc.storetime = lab.storetime
    WHERE lab.itemid = 51256
),
First_Monocytes AS (
    SELECT
        anc.hadm_id,
        lab.valuenum,
        lab.charttime AS Monocytes_charttime,
        lab.storetime AS Monocytes_storetime
    FROM CBC_anchor AS anc
    JOIN mimiciv_hosp.labevents AS lab
      ON anc.hadm_id = lab.hadm_id
     AND anc.charttime = lab.charttime
     AND anc.storetime = lab.storetime
    WHERE lab.itemid = 51242
),
First_Hemoglobin AS (
    SELECT DISTINCT ON (lab.hadm_id)
        lab.hadm_id,
        lab.valuenum,
        lab.charttime AS Hemoglobin_charttime,
        lab.storetime AS Hemoglobin_storetime
    FROM basic
    JOIN mimiciv_hosp.labevents AS lab ON basic.hadm_id = lab.hadm_id
    WHERE lab.itemid = 51222
      AND lab.charttime > basic.icu_intime
      AND lab.charttime < basic.icu_outtime
    ORDER BY lab.hadm_id, lab.charttime
),
First_Platelet_Count AS (
    SELECT DISTINCT ON (lab.hadm_id)
        lab.hadm_id,
        lab.valuenum,
        lab.charttime AS Platelet_Count_charttime,
        lab.storetime AS Platelet_Count_storetime
    FROM basic
    JOIN mimiciv_hosp.labevents AS lab ON basic.hadm_id = lab.hadm_id
    WHERE lab.itemid = 51265
      AND lab.charttime > basic.icu_intime
      AND lab.charttime < basic.icu_outtime
    ORDER BY lab.hadm_id, lab.charttime
),
First_Red_Blood_Cells AS (
    SELECT DISTINCT ON (lab.hadm_id)
        lab.hadm_id,
        lab.valuenum,
        lab.charttime AS Red_Blood_Cells_charttime,
        lab.storetime AS Red_Blood_Cells_storetime
    FROM basic
    JOIN mimiciv_hosp.labevents AS lab ON basic.hadm_id = lab.hadm_id
    WHERE lab.itemid = 51279
      AND lab.charttime > basic.icu_intime
      AND lab.charttime < basic.icu_outtime
    ORDER BY lab.hadm_id, lab.charttime
),
First_Albumin AS (
    SELECT DISTINCT ON (lab.hadm_id)
        lab.hadm_id,
        lab.valuenum,
        lab.charttime AS Albumin_charttime,
        lab.storetime AS Albumin_storetime
    FROM basic
    JOIN mimiciv_hosp.labevents AS lab ON basic.hadm_id = lab.hadm_id
    WHERE lab.itemid = 50862
      AND lab.charttime > basic.icu_intime
      AND lab.charttime < basic.icu_outtime
    ORDER BY lab.hadm_id, lab.charttime
),
First_Absolute_CD4_Count AS (
    SELECT DISTINCT ON (lab.hadm_id)
        lab.hadm_id,
        lab.valuenum,
        lab.charttime AS Absolute_CD4_Count_charttime,
        lab.storetime AS Absolute_CD4_Count_storetime
    FROM basic
    JOIN mimiciv_hosp.labevents AS lab ON basic.hadm_id = lab.hadm_id
    WHERE lab.itemid = 51131
      AND lab.charttime > basic.icu_intime
      AND lab.charttime < basic.icu_outtime
    ORDER BY lab.hadm_id, lab.charttime
),
First_Creatinine AS (
    SELECT DISTINCT ON (lab.hadm_id)
        lab.hadm_id,
        lab.valuenum,
        lab.charttime AS Creatinine_charttime,
        lab.storetime AS Creatinine_storetime
    FROM basic
    JOIN mimiciv_hosp.labevents AS lab ON basic.hadm_id = lab.hadm_id
    WHERE lab.itemid = 50912
      AND lab.charttime > basic.icu_intime
      AND lab.charttime < basic.icu_outtime
    ORDER BY lab.hadm_id, lab.charttime
),
First_Lactate_Dehydrogenase_LD AS (
    SELECT DISTINCT ON (lab.hadm_id)
        lab.hadm_id,
        lab.valuenum,
        lab.charttime AS Lactate_Dehydrogenase_LD_charttime,
        lab.storetime AS Lactate_Dehydrogenase_LD_storetime
    FROM basic
    JOIN mimiciv_hosp.labevents AS lab ON basic.hadm_id = lab.hadm_id
    WHERE lab.itemid = 50954
      AND lab.charttime > basic.icu_intime
      AND lab.charttime < basic.icu_outtime
    ORDER BY lab.hadm_id, lab.charttime
),
lab_all AS (
    SELECT
        subject.subject_id,
        subject.stay_id,
        subject.hadm_id,
        subject.admittime,
        subject.dischtime,
        subject.icu_intime,
        subject.icu_outtime,
        subject.patient_dod,
        anthrop.BMI,
        ROUND(First_White_Blood_Cells.valuenum::numeric, 2) AS first_white_blood_cells,
        First_White_Blood_Cells.White_Blood_Cells_charttime,
        First_White_Blood_Cells.White_Blood_Cells_storetime,
        ROUND(First_Lymphocytes.valuenum::numeric, 2) AS first_lymphocytes,
        First_Lymphocytes.Lymphocytes_charttime,
        First_Lymphocytes.Lymphocytes_storetime,
        ROUND(First_Neutrophils.valuenum::numeric, 2) AS first_neutrophils,
        First_Neutrophils.Neutrophils_charttime,
        First_Neutrophils.Neutrophils_storetime,
        ROUND(First_Monocytes.valuenum::numeric, 2) AS first_monocytes,
        First_Monocytes.Monocytes_charttime,
        First_Monocytes.Monocytes_storetime,
        ROUND(First_Hemoglobin.valuenum::numeric, 2) AS first_hemoglobin,
        First_Hemoglobin.Hemoglobin_charttime,
        First_Hemoglobin.Hemoglobin_storetime,
        ROUND(First_Platelet_Count.valuenum::numeric, 2) AS first_platelet_count,
        First_Platelet_Count.Platelet_Count_charttime,
        First_Platelet_Count.Platelet_Count_storetime,
        ROUND(First_Red_Blood_Cells.valuenum::numeric, 2) AS first_red_blood_cells,
        First_Red_Blood_Cells.Red_Blood_Cells_charttime,
        First_Red_Blood_Cells.Red_Blood_Cells_storetime,
        ROUND(First_Albumin.valuenum::numeric, 2) AS first_albumin,
        First_Albumin.Albumin_charttime,
        First_Albumin.Albumin_storetime,
        ROUND(First_Absolute_CD4_Count.valuenum::numeric, 2) AS first_absolute_cd4_count,
        First_Absolute_CD4_Count.Absolute_CD4_Count_charttime,
        First_Absolute_CD4_Count.Absolute_CD4_Count_storetime,
        ROUND(First_Creatinine.valuenum::numeric, 2) AS first_creatinine,
        First_Creatinine.Creatinine_charttime,
        First_Creatinine.Creatinine_storetime,
        ROUND(First_Lactate_Dehydrogenase_LD.valuenum::numeric, 2) AS first_lactate_dehydrogenase_ld,
        First_Lactate_Dehydrogenase_LD.Lactate_Dehydrogenase_LD_charttime,
        First_Lactate_Dehydrogenase_LD.Lactate_Dehydrogenase_LD_storetime,
        CASE WHEN First_Lymphocytes.valuenum > 0 THEN ROUND(First_Neutrophils.valuenum / First_Lymphocytes.valuenum,3) ELSE NULL END AS NLR
    FROM basic AS subject
    LEFT JOIN patient_anthropometry anthrop ON subject.subject_id = anthrop.subject_id AND subject.hadm_id = anthrop.hadm_id
    LEFT JOIN First_White_Blood_Cells ON subject.hadm_id = First_White_Blood_Cells.hadm_id
    LEFT JOIN First_Lymphocytes ON subject.hadm_id = First_Lymphocytes.hadm_id
    LEFT JOIN First_Neutrophils ON subject.hadm_id = First_Neutrophils.hadm_id
    LEFT JOIN First_Monocytes ON subject.hadm_id = First_Monocytes.hadm_id
    LEFT JOIN First_Hemoglobin ON subject.hadm_id = First_Hemoglobin.hadm_id
    LEFT JOIN First_Platelet_Count ON subject.hadm_id = First_Platelet_Count.hadm_id
    LEFT JOIN First_Red_Blood_Cells ON subject.hadm_id = First_Red_Blood_Cells.hadm_id
    LEFT JOIN First_Albumin ON subject.hadm_id = First_Albumin.hadm_id
    LEFT JOIN First_Absolute_CD4_Count ON subject.hadm_id = First_Absolute_CD4_Count.hadm_id
    LEFT JOIN First_Creatinine ON subject.hadm_id = First_Creatinine.hadm_id
    LEFT JOIN First_Lactate_Dehydrogenase_LD ON subject.hadm_id = First_Lactate_Dehydrogenase_LD.hadm_id
),
outcome AS (
    SELECT
        lab_all.subject_id,
        lab_all.stay_id,
        lab_all.hadm_id,
        lab_all.admittime,
        lab_all.dischtime,
        lab_all.icu_intime,
        lab_all.icu_outtime,
        lab_all.Lymphocytes_charttime,
        lab_all.patient_dod,
        lab_all.BMI,
        lab_all.NLR,
        CASE WHEN lab_all.patient_dod IS NOT NULL THEN 1 ELSE 0 END AS is_dead,
        lab_all.patient_dod::timestamp AS dead_time,
        CASE
            WHEN lab_all.patient_dod IS NOT NULL
                AND (lab_all.patient_dod::timestamp BETWEEN lab_all.admittime AND lab_all.dischtime)
            THEN 1 ELSE 0
        END AS death_in_current_adm,
        CASE
            WHEN lab_all.patient_dod IS NOT NULL
                AND (lab_all.patient_dod::timestamp - lab_all.Lymphocytes_charttime) <= INTERVAL '28 days'
            THEN 1 ELSE 0
        END AS death_within_icu_28days,
        ROUND(
            EXTRACT(EPOCH FROM (
                CASE
                    WHEN lab_all.patient_dod IS NOT NULL
                        AND (lab_all.patient_dod::timestamp - lab_all.Lymphocytes_charttime) <= INTERVAL '28 days'
                    THEN lab_all.patient_dod::timestamp - lab_all.Lymphocytes_charttime
                    ELSE lab_all.Lymphocytes_charttime + INTERVAL '28 days' - lab_all.Lymphocytes_charttime
                END
            )) / 86400, 2
        ) AS icu_28days_survival_time,
        lab_all.first_white_blood_cells,
        lab_all.White_Blood_Cells_charttime,
        lab_all.White_Blood_Cells_storetime,
        lab_all.first_lymphocytes,
        lab_all.Lymphocytes_charttime,
        lab_all.Lymphocytes_storetime,
        lab_all.first_neutrophils,
        lab_all.Neutrophils_charttime,
        lab_all.Neutrophils_storetime,
        lab_all.first_monocytes,
        lab_all.Monocytes_charttime,
        lab_all.Monocytes_storetime,
        lab_all.first_hemoglobin,
        lab_all.Hemoglobin_charttime,
        lab_all.Hemoglobin_storetime,
        lab_all.first_platelet_count,
        lab_all.Platelet_Count_charttime,
        lab_all.Platelet_Count_storetime,
        lab_all.first_red_blood_cells,
        lab_all.Red_Blood_Cells_charttime,
        lab_all.Red_Blood_Cells_storetime,
        lab_all.first_albumin,
        lab_all.Albumin_charttime,
        lab_all.Albumin_storetime,
        lab_all.first_absolute_cd4_count,
        lab_all.Absolute_CD4_Count_charttime,
        lab_all.Absolute_CD4_Count_storetime,
        lab_all.first_creatinine,
        lab_all.Creatinine_charttime,
        lab_all.Creatinine_storetime,
        lab_all.first_lactate_dehydrogenase_ld,
        lab_all.Lactate_Dehydrogenase_LD_charttime,
        lab_all.Lactate_Dehydrogenase_LD_storetime
    FROM lab_all
)
SELECT
    outcome.*,
    d.Hypertension,
    d.Diabetes,
    d.MACE,
    d.Liver_disease,
    d.Renal_disease,
    d.Chronic_pulmonary_disease,
    d.Malignant_neoplasms,
    d.Organ_transplant,
    d.HIV_infection,
    d.CMV_infection
FROM outcome
LEFT JOIN disease d ON outcome.hadm_id = d.hadm_id
ORDER BY outcome.subject_id;

WITH
basic AS (
    WITH
    includedDiagnose1 AS (
        SELECT DISTINCT hadm_id
        FROM mimiciv_hosp.diagnoses_icd
        WHERE icd_code IN ('B59')
    ),
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
        AND (
            icu.hadm_id IN (SELECT hadm_id FROM includedDiagnose1)
            OR icu.hadm_id IN (SELECT hadm_id FROM includedDiagnose2)
        )
),
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
    ORDER BY LAB.HADM_ID,LAB.CHARTTIME),
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
    ORDER BY LAB.HADM_ID,LAB.CHARTTIME),
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
GC_val AS
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
    ),
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
VP_val AS
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
    ),
VENTILATION AS
    (SELECT SUBJECT.STAY_ID,
            ROUND(SUM(MIMICIV_DERIVED.DATETIME_DIFF(VENTILATION.ENDTIME,VENTILATION.STARTTIME,'HOUR')),2) AS VENTILATION_HOUR,
            MIN(VENTILATION.STARTTIME) AS VENTILATION_FIRST_TIME
    FROM basic AS SUBJECT,
            MIMICIV_DERIVED.VENTILATION AS VENTILATION,
            MIMICIV_DERIVED.ICUSTAY_DETAIL AS ICU
    WHERE SUBJECT.STAY_ID = VENTILATION.STAY_ID
            AND SUBJECT.STAY_ID = ICU.STAY_ID
            AND VENTILATION.STARTTIME >= ICU.ICU_INTIME
    GROUP BY SUBJECT.STAY_ID),
--CRRT
CRRT AS
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

SELECT
    DISTINCT(subject.subject_id),
    subject.stay_id,
    subject.hadm_id,
    subject.admittime,
    subject.dischtime,
    subject.icu_intime,
    subject.icu_outtime,
    ROUND(FIRST_pO2.VALUENUM::numeric,2) AS FIRST_pO2,
    FIRST_pO2.VALUEUOM AS FIRST_pO2_UOM,
    FIRST_pO2.pO2_charttime,
    FIRST_pO2.pO2_storetime,
    ROUND(FIRST_Required_O2.VALUENUM::numeric,2) AS FIRST_Required_O2,
    FIRST_Required_O2.VALUEUOM AS FIRST_Required_O2_UOM,
    FIRST_Required_O2.Required_O2_charttime,
    FIRST_Required_O2.Required_O2_storetime,
    GC.flag AS GC,
    GC_val.dose_val_rx AS GCtotalval,
    GC_val.dose_unit_rx AS GCunit,
    GC.GC_prescriptions_starttime,
    GC.GC_prescriptions_stoptime,
    VP.flag AS VP,
    VP_val.dose_val_rx AS VPtotalval,
    VP_val.dose_unit_rx AS VPunit,
    VP.VP_prescriptions_starttime,
    VP.VP_prescriptions_stoptime,
    VENTILATION.VENTILATION_HOUR,
    CASE WHEN VENTILATION.VENTILATION_HOUR IS NOT NULL THEN 1 ELSE 0 END AS VENTILATION,
    VENTILATION.VENTILATION_FIRST_TIME,
    --CRRT
    CASE WHEN CRRT.CRRT_DAY IS NOT NULL THEN 1 ELSE 0 END AS CRRT,
    CRRT.CRRT_DAY,
    CRRT.CRRT_FIRST_TIME,
    sofa.sofa,
    sapsii.sapsii
FROM basic AS subject
LEFT JOIN FIRST_pO2 ON subject.hadm_id = FIRST_pO2.hadm_id
LEFT JOIN FIRST_Required_O2 ON subject.hadm_id = FIRST_Required_O2.hadm_id
LEFT JOIN GC ON subject.hadm_id = GC.hadm_id
LEFT JOIN GC_val ON subject.hadm_id = GC_val.hadm_id
LEFT JOIN VP ON subject.hadm_id = VP.hadm_id
LEFT JOIN VP_val ON subject.hadm_id = VP_val.hadm_id
LEFT JOIN VENTILATION ON subject.stay_id = VENTILATION.stay_id
LEFT JOIN CRRT ON subject.stay_id = CRRT.stay_id
LEFT JOIN mimiciv_derived.first_day_sofa AS sofa ON subject.stay_id = sofa.stay_id
LEFT JOIN mimiciv_derived.sapsii AS sapsii ON subject.stay_id = sapsii.stay_id
ORDER BY subject.subject_id;
WITH
basic AS (
    WITH
    includedDiagnose1 AS (
        SELECT DISTINCT hadm_id
        FROM mimiciv_hosp.diagnoses_icd
        WHERE icd_code IN ('B59')
    ),
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
        AND (
            icu.hadm_id IN (SELECT hadm_id FROM includedDiagnose1)
            OR icu.hadm_id IN (SELECT hadm_id FROM includedDiagnose2)
        )
),
Caspofungin_Desensitization AS
(SELECT DISTINCT(prescriptions.hadm_id),
         1 AS flag,
         MAX(prescriptions.starttime) AS Caspofungin_Desensitization_prescriptions_starttime,
         MAX(prescriptions.stoptime) AS Caspofungin_Desensitization_prescriptions_stoptime
FROM mimiciv_hosp.prescriptions AS prescriptions,
     mimiciv_derived.icustay_detail AS icu,
     basic AS subject
WHERE prescriptions.hadm_id = subject.hadm_id
    AND subject.stay_id = icu.stay_id
    AND prescriptions.starttime >= icu.icu_intime
    AND prescriptions.starttime <= icu.icu_outtime
    AND prescriptions.gsn IN ('047689')
GROUP BY prescriptions.hadm_id
),
Caspofungin_Desensitization_val AS
(SELECT DISTINCT(prescriptions.hadm_id),
SUM(CAST(prescriptions.dose_val_rx AS numeric)) AS dose_val_rx,
        MAX(prescriptions.dose_unit_rx) AS dose_unit_rx
   FROM mimiciv_hosp.prescriptions AS prescriptions,
        mimiciv_derived.icustay_detail AS icu,
        basic AS subject
   WHERE prescriptions.hadm_id = subject.hadm_id
        AND subject.stay_id = icu.stay_id
        AND prescriptions.starttime >= icu.icu_intime
        AND prescriptions.starttime <= icu.icu_outtime
        AND prescriptions.gsn IN ('047689')
        AND prescriptions.dose_val_rx ~ '^[0-9]+(\.[0-9]+)?$'
   GROUP BY prescriptions.hadm_id
),
Atovaquone_Suspension AS
(SELECT DISTINCT(prescriptions.hadm_id),
         1 AS flag,
         MAX(prescriptions.starttime) AS Atovaquone_Suspension_prescriptions_starttime,
         MAX(prescriptions.stoptime) AS Atovaquone_Suspension_prescriptions_stoptime
FROM mimiciv_hosp.prescriptions AS prescriptions,
     mimiciv_derived.icustay_detail AS icu,
     basic AS subject
WHERE prescriptions.hadm_id = subject.hadm_id
    AND subject.stay_id = icu.stay_id
    AND prescriptions.starttime >= icu.icu_intime
    AND prescriptions.starttime <= icu.icu_outtime
    AND prescriptions.gsn IN ('023399')
GROUP BY prescriptions.hadm_id
),
Atovaquone_Suspension_val AS
(SELECT DISTINCT(prescriptions.hadm_id),
SUM(CAST(prescriptions.dose_val_rx AS numeric)) AS dose_val_rx,
        MAX(prescriptions.dose_unit_rx) AS dose_unit_rx
   FROM mimiciv_hosp.prescriptions AS prescriptions,
        mimiciv_derived.icustay_detail AS icu,
        basic AS subject
   WHERE prescriptions.hadm_id = subject.hadm_id
        AND subject.stay_id = icu.stay_id
        AND prescriptions.starttime >= icu.icu_intime
        AND prescriptions.starttime <= icu.icu_outtime
        AND prescriptions.gsn IN ('023399')
        AND prescriptions.dose_val_rx ~ '^[0-9]+(\.[0-9]+)?$'
   GROUP BY prescriptions.hadm_id
),
Primaquine_Phosphate AS
(SELECT DISTINCT(prescriptions.hadm_id),
         1 AS flag,
         MAX(prescriptions.starttime) AS Primaquine_Phosphate_prescriptions_starttime,
         MAX(prescriptions.stoptime) AS Primaquine_Phosphate_prescriptions_stoptime
FROM mimiciv_hosp.prescriptions AS prescriptions,
     mimiciv_derived.icustay_detail AS icu,
     basic AS subject
WHERE prescriptions.hadm_id = subject.hadm_id
    AND subject.stay_id = icu.stay_id
    AND prescriptions.starttime >= icu.icu_intime
    AND prescriptions.starttime <= icu.icu_outtime
    AND prescriptions.gsn IN ('009344','009339','013053','009346','015999','007727','013052','009577')
GROUP BY prescriptions.hadm_id
),
Primaquine_Phosphate_val AS
(SELECT DISTINCT(prescriptions.hadm_id),
SUM(CAST(prescriptions.dose_val_rx AS numeric)) AS dose_val_rx,
        MAX(prescriptions.dose_unit_rx) AS dose_unit_rx
   FROM mimiciv_hosp.prescriptions AS prescriptions,
        mimiciv_derived.icustay_detail AS icu,
        basic AS subject
   WHERE prescriptions.hadm_id = subject.hadm_id
        AND subject.stay_id = icu.stay_id
        AND prescriptions.starttime >= icu.icu_intime
        AND prescriptions.starttime <= icu.icu_outtime
        AND prescriptions.gsn IN ('009344','009339','013053','009346','015999','007727','013052','009577')
        AND prescriptions.dose_val_rx ~ '^[0-9]+(\.[0-9]+)?$'
   GROUP BY prescriptions.hadm_id
),
Pentamidine_Isethionate2 AS
(SELECT DISTINCT(prescriptions.hadm_id),
         1 AS flag,
         MAX(prescriptions.starttime) AS Pentamidine_Isethionate2_prescriptions_starttime,
         MAX(prescriptions.stoptime) AS Pentamidine_Isethionate2_prescriptions_stoptime
FROM mimiciv_hosp.prescriptions AS prescriptions,
     mimiciv_derived.icustay_detail AS icu,
     basic AS subject
WHERE prescriptions.hadm_id = subject.hadm_id
    AND subject.stay_id = icu.stay_id
    AND prescriptions.starttime >= icu.icu_intime
    AND prescriptions.starttime <= icu.icu_outtime
    AND prescriptions.gsn IN ('011791','009599')
GROUP BY prescriptions.hadm_id
),
Pentamidine_Isethionate2_val AS
(SELECT DISTINCT(prescriptions.hadm_id),
SUM(CAST(prescriptions.dose_val_rx AS numeric)) AS dose_val_rx,
        MAX(prescriptions.dose_unit_rx) AS dose_unit_rx
   FROM mimiciv_hosp.prescriptions AS prescriptions,
        mimiciv_derived.icustay_detail AS icu,
        basic AS subject
   WHERE prescriptions.hadm_id = subject.hadm_id
        AND subject.stay_id = icu.stay_id
        AND prescriptions.starttime >= icu.icu_intime
        AND prescriptions.starttime <= icu.icu_outtime
        AND prescriptions.gsn IN ('011791','009599')
        AND prescriptions.dose_val_rx ~ '^[0-9]+(\.[0-9]+)?$'
   GROUP BY prescriptions.hadm_id
),
Trimethoprim AS
(SELECT DISTINCT(prescriptions.hadm_id),
         1 AS flag,
         MAX(prescriptions.starttime) AS Trimethoprim_prescriptions_starttime,
         MAX(prescriptions.stoptime) AS Trimethoprim_prescriptions_stoptime
FROM mimiciv_hosp.prescriptions AS prescriptions,
     mimiciv_derived.icustay_detail AS icu,
     basic AS subject
WHERE prescriptions.hadm_id = subject.hadm_id
    AND subject.stay_id = icu.stay_id
    AND prescriptions.starttime >= icu.icu_intime
    AND prescriptions.starttime <= icu.icu_outtime
    AND prescriptions.gsn IN ('009497')
GROUP BY prescriptions.hadm_id
),
Trimethoprim_val AS
(SELECT DISTINCT(prescriptions.hadm_id),
SUM(CAST(prescriptions.dose_val_rx AS numeric)) AS dose_val_rx,
        MAX(prescriptions.dose_unit_rx) AS dose_unit_rx
   FROM mimiciv_hosp.prescriptions AS prescriptions,
        mimiciv_derived.icustay_detail AS icu,
        basic AS subject
   WHERE prescriptions.hadm_id = subject.hadm_id
        AND subject.stay_id = icu.stay_id
        AND prescriptions.starttime >= icu.icu_intime
        AND prescriptions.starttime <= icu.icu_outtime
        AND prescriptions.gsn IN ('009497')
        AND prescriptions.dose_val_rx ~ '^[0-9]+(\.[0-9]+)?$'
   GROUP BY prescriptions.hadm_id
),
SMZ_TMP AS
(SELECT DISTINCT(prescriptions.hadm_id),
            1 AS flag,
            MAX(prescriptions.starttime) AS SMZ_TMP_prescriptions_starttime,
            MAX(prescriptions.stoptime) AS SMZ_TMP_prescriptions_stoptime
    FROM mimiciv_hosp.prescriptions AS prescriptions,
            mimiciv_derived.icustay_detail AS icu,
            basic AS subject
    WHERE prescriptions.hadm_id = subject.hadm_id
            AND subject.stay_id = icu.stay_id
            AND prescriptions.starttime >= icu.icu_intime
            AND prescriptions.starttime <= icu.icu_outtime
            AND prescriptions.gsn IN ('009396','009393','009394','071217')
    GROUP BY prescriptions.hadm_id
),
SMZ_TMP_val AS
(SELECT DISTINCT(prescriptions.hadm_id),
     SUM(CAST(prescriptions.dose_val_rx AS NUMERIC)) AS dose_val_rx,
            MAX(prescriptions.dose_unit_rx) AS dose_unit_rx
    FROM mimiciv_hosp.prescriptions AS prescriptions,
            mimiciv_derived.icustay_detail AS icu, basic AS subject
    WHERE prescriptions.hadm_id = subject.hadm_id
            AND subject.stay_id = icu.stay_id
            AND prescriptions.starttime >= icu.icu_intime
            AND prescriptions.starttime <= icu.icu_outtime
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
    Caspofungin_Desensitization.flag AS Caspofungin_Desensitization,
    Caspofungin_Desensitization_val.dose_val_rx AS Caspofungin_Desensitizationtotalval,
    Caspofungin_Desensitization_val.dose_unit_rx AS Caspofungin_Desensitizationunit,
    Caspofungin_Desensitization.Caspofungin_Desensitization_prescriptions_starttime,
    Caspofungin_Desensitization.Caspofungin_Desensitization_prescriptions_stoptime,
    Atovaquone_Suspension.flag AS Atovaquone_Suspension,
    Atovaquone_Suspension_val.dose_val_rx AS Atovaquone_Suspensiontotalval,
    Atovaquone_Suspension_val.dose_unit_rx AS Atovaquone_Suspensionunit,
    Atovaquone_Suspension.Atovaquone_Suspension_prescriptions_starttime,
    Atovaquone_Suspension.Atovaquone_Suspension_prescriptions_stoptime,
    Primaquine_Phosphate.flag AS Primaquine_Phosphate,
    Primaquine_Phosphate_val.dose_val_rx AS Primaquine_Phosphatetotalval,
    Primaquine_Phosphate_val.dose_unit_rx AS Primaquine_Phosphateunit,
    Primaquine_Phosphate.Primaquine_Phosphate_prescriptions_starttime,
    Primaquine_Phosphate.Primaquine_Phosphate_prescriptions_stoptime,
    Pentamidine_Isethionate2.flag AS Pentamidine_Isethionate2,
    Pentamidine_Isethionate2_val.dose_val_rx AS Pentamidine_Isethionate2totalval,
    Pentamidine_Isethionate2_val.dose_unit_rx AS Pentamidine_Isethionate2unit,
    Pentamidine_Isethionate2.Pentamidine_Isethionate2_prescriptions_starttime,
    Pentamidine_Isethionate2.Pentamidine_Isethionate2_prescriptions_stoptime,
    Trimethoprim.flag AS Trimethoprim,
    Trimethoprim_val.dose_val_rx AS Trimethoprimtotalval,
    Trimethoprim_val.dose_unit_rx AS Trimethoprimunit,
    Trimethoprim.Trimethoprim_prescriptions_starttime,
    Trimethoprim.Trimethoprim_prescriptions_stoptime,
    SMZ_TMP.flag AS SMZ_TMP,
    SMZ_TMP_val.dose_val_rx AS SMZ_TMPtotalval,
    SMZ_TMP_val.dose_unit_rx AS SMZ_TMPunit,
    SMZ_TMP.SMZ_TMP_prescriptions_starttime,
    SMZ_TMP.SMZ_TMP_prescriptions_stoptime
FROM basic AS subject
LEFT JOIN Caspofungin_Desensitization ON subject.hadm_id = Caspofungin_Desensitization.hadm_id
LEFT JOIN Caspofungin_Desensitization_val ON subject.hadm_id = Caspofungin_Desensitization_val.hadm_id
LEFT JOIN Atovaquone_Suspension ON subject.hadm_id = Atovaquone_Suspension.hadm_id
LEFT JOIN Atovaquone_Suspension_val ON subject.hadm_id = Atovaquone_Suspension_val.hadm_id
LEFT JOIN Primaquine_Phosphate ON subject.hadm_id = Primaquine_Phosphate.hadm_id
LEFT JOIN Primaquine_Phosphate_val ON subject.hadm_id = Primaquine_Phosphate_val.hadm_id
LEFT JOIN Pentamidine_Isethionate2 ON subject.hadm_id = Pentamidine_Isethionate2.hadm_id
LEFT JOIN Pentamidine_Isethionate2_val ON subject.hadm_id = Pentamidine_Isethionate2_val.hadm_id
LEFT JOIN Trimethoprim ON subject.hadm_id = Trimethoprim.hadm_id
LEFT JOIN Trimethoprim_val ON subject.hadm_id = Trimethoprim_val.hadm_id
LEFT JOIN SMZ_TMP ON subject.hadm_id = SMZ_TMP.hadm_id
LEFT JOIN SMZ_TMP_val ON subject.hadm_id = SMZ_TMP_val.hadm_id
ORDER BY subject.subject_id;

