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
demographics AS (
    SELECT DISTINCT
        subject.subject_id,
        subject.stay_id,
        subject.hadm_id,
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
),
lab_all AS (
    SELECT 
        SUBJECT.STAY_ID, 
        AVG(CASE WHEN LAB.ITEMID = 51133 THEN VALUENUM END) AS LAB_24HOUR_Absolute_Lymphocyte_Count,
        MAX(CASE WHEN LAB.ITEMID = 51133 THEN VALUEUOM END) AS LAB_24HOUR_Absolute_Lymphocyte_Count_UOM, 
        AVG(CASE WHEN LAB.ITEMID = 51265 THEN VALUENUM END) AS LAB_24HOUR_Platelet_Count,
        MAX(CASE WHEN LAB.ITEMID = 51265 THEN VALUEUOM END) AS LAB_24HOUR_Platelet_Count_UOM, 
        AVG(CASE WHEN LAB.ITEMID = 52075 THEN VALUENUM END) AS LAB_24HOUR_Absolute_Neutrophil_Count,
        MAX(CASE WHEN LAB.ITEMID = 52075 THEN VALUEUOM END) AS LAB_24HOUR_Absolute_Neutrophil_Count_UOM, 
        AVG(CASE WHEN LAB.ITEMID = 50912 THEN VALUENUM END) AS LAB_24HOUR_Creatinine,
        MAX(CASE WHEN LAB.ITEMID = 50912 THEN VALUEUOM END) AS LAB_24HOUR_Creatinine_UOM, 
        AVG(CASE WHEN LAB.ITEMID = 51301 THEN VALUENUM END) AS LAB_24HOUR_White_Blood_Cells,
        MAX(CASE WHEN LAB.ITEMID = 51301 THEN VALUEUOM END) AS LAB_24HOUR_White_Blood_Cells_UOM, 
        AVG(CASE WHEN LAB.ITEMID = 51279 THEN VALUENUM END) AS LAB_24HOUR_Red_Blood_Cells,
        MAX(CASE WHEN LAB.ITEMID = 51279 THEN VALUEUOM END) AS LAB_24HOUR_Red_Blood_Cells_UOM, 
        AVG(CASE WHEN LAB.ITEMID = 51222 THEN VALUENUM END) AS LAB_24HOUR_Hemoglobin,
        MAX(CASE WHEN LAB.ITEMID = 51222 THEN VALUEUOM END) AS LAB_24HOUR_Hemoglobin_UOM, 
        AVG(CASE WHEN LAB.ITEMID = 51254 THEN VALUENUM END) AS LAB_24HOUR_Monocytes,
        MAX(CASE WHEN LAB.ITEMID = 51254 THEN VALUEUOM END) AS LAB_24HOUR_Monocytes_UOM, 
        AVG(CASE WHEN LAB.ITEMID = 50954 THEN VALUENUM END) AS LAB_24HOUR_Lactate_Dehydrogenase_LD,
        MAX(CASE WHEN LAB.ITEMID = 50954 THEN VALUEUOM END) AS LAB_24HOUR_Lactate_Dehydrogenase_LD_UOM, 
        AVG(CASE WHEN LAB.ITEMID = 50816 THEN VALUENUM END) AS LAB_24HOUR_Oxygen,
        MAX(CASE WHEN LAB.ITEMID = 50816 THEN VALUEUOM END) AS LAB_24HOUR_Oxygen_UOM, 
        AVG(CASE WHEN LAB.ITEMID = 50821 THEN VALUENUM END) AS LAB_24HOUR_pO2,
        MAX(CASE WHEN LAB.ITEMID = 50821 THEN VALUEUOM END) AS LAB_24HOUR_pO2_UOM,
        AVG(CASE WHEN LAB.ITEMID = 51244 THEN VALUENUM END) AS LAB_24HOUR_Lymphocytes_PCT,
        MAX(CASE WHEN LAB.ITEMID = 51244 THEN VALUEUOM END) AS LAB_24HOUR_Lymphocytes_PCT_UOM, 
        AVG(CASE WHEN LAB.ITEMID = 51256 THEN VALUENUM END) AS LAB_24HOUR_Neutrophils_PCT,
        MAX(CASE WHEN LAB.ITEMID = 51256 THEN VALUEUOM END) AS LAB_24HOUR_Neutrophils_PCT_UOM
    FROM basic AS SUBJECT
    LEFT JOIN MIMICIV_DERIVED.ICUSTAY_DETAIL AS ICU ON SUBJECT.STAY_ID = ICU.STAY_ID
    LEFT JOIN MIMICIV_HOSP.LABEVENTS AS LAB ON SUBJECT.HADM_ID = LAB.HADM_ID
    WHERE LAB.ITEMID IN ('51133','51265','52075','50912','51301','51279','51222','51254','50954','50816','50821','51244','51256')
    AND LAB.CHARTTIME BETWEEN ICU.icu_intime - INTERVAL '6' HOUR AND ICU.icu_intime + INTERVAL '24' HOUR
    GROUP BY SUBJECT.STAY_ID
),
lab_cd4 AS (
    SELECT 
        SUBJECT.HADM_ID,
        AVG(CASE WHEN LAB.ITEMID = 51131 THEN VALUENUM END) AS FIRST_Absolute_CD4_Count,
        MAX(CASE WHEN LAB.ITEMID = 51131 THEN VALUEUOM END) AS FIRST_Absolute_CD4_Count_UOM,
        MIN(CASE WHEN LAB.ITEMID = 51131 THEN LAB.charttime END) AS Absolute_CD4_Count_charttime,
        MIN(CASE WHEN LAB.ITEMID = 51131 THEN LAB.storetime END) AS Absolute_CD4_Count_storetime,
        AVG(CASE WHEN LAB.ITEMID = 51180 THEN VALUENUM END) AS FIRST_CD4_Cells_Percent,
        MAX(CASE WHEN LAB.ITEMID = 51180 THEN VALUEUOM END) AS FIRST_CD4_Cells_Percent_UOM,
        MIN(CASE WHEN LAB.ITEMID = 51180 THEN LAB.charttime END) AS CD4_Cells_Percent_charttime,
        MIN(CASE WHEN LAB.ITEMID = 51180 THEN LAB.storetime END) AS CD4_Cells_Percent_storetime
    FROM basic AS SUBJECT
    LEFT JOIN MIMICIV_DERIVED.ICUSTAY_DETAIL AS ICU ON SUBJECT.STAY_ID = ICU.STAY_ID
    LEFT JOIN MIMICIV_HOSP.LABEVENTS AS LAB ON SUBJECT.HADM_ID = LAB.HADM_ID
    WHERE LAB.ITEMID IN ('51131','51180')
    AND LAB.CHARTTIME >= ICU.icu_intime
    GROUP BY SUBJECT.HADM_ID
),
ld_chartevent AS (
    SELECT DISTINCT ON (chart_events.stay_id)
        chart_events.stay_id,
        chart_events.value AS first_LDH_value,
        chart_events.valuenum AS first_LDH,
        chart_events.valueuom AS first_LDH_uom,
        chart_events.charttime AS LDH_chartevents_charttime,
        chart_events.storetime AS LDH_chartevents_storetime
    FROM basic AS subject,
    mimiciv_derived.icustay_detail AS icu,
    mimiciv_icu.chartevents AS chart_events
    WHERE chart_events.itemid = 220632
    AND chart_events.charttime >= icu.icu_intime
    AND subject.stay_id = icu.stay_id
    AND subject.stay_id = chart_events.stay_id
    ORDER BY chart_events.stay_id, chart_events.charttime
),
ventilation AS (
    SELECT 
        SUBJECT.STAY_ID,
        ROUND(SUM(MIMICIV_DERIVED.DATETIME_DIFF(VENTILATION.ENDTIME,VENTILATION.STARTTIME,'HOUR')),2) AS VENTILATION_HOUR,
        MIN(VENTILATION.STARTTIME) AS VENTILATION_FIRST_TIME,
        CASE WHEN SUM(MIMICIV_DERIVED.DATETIME_DIFF(VENTILATION.ENDTIME,VENTILATION.STARTTIME,'HOUR')) IS NOT NULL THEN 1 ELSE 0 END AS VENTILATION_FLAG
    FROM basic AS SUBJECT,
    MIMICIV_DERIVED.VENTILATION AS VENTILATION,
    MIMICIV_DERIVED.ICUSTAY_DETAIL AS ICU
    WHERE SUBJECT.STAY_ID = VENTILATION.STAY_ID
    AND SUBJECT.STAY_ID = ICU.STAY_ID
    AND VENTILATION.STARTTIME >= ICU.ICU_INTIME
    GROUP BY SUBJECT.STAY_ID
),
crrt AS (
    SELECT 
        SUBJECT.STAY_ID,
        COUNT(DISTINCT DATE(CRRT.CHARTTIME)) AS CRRT_DAY,
        MIN(CRRT.CHARTTIME) AS CRRT_FIRST_TIME,
        CASE WHEN COUNT(DISTINCT DATE(CRRT.CHARTTIME)) > 0 THEN 1 ELSE 0 END AS CRRT_FLAG
    FROM basic AS SUBJECT,
    MIMICIV_DERIVED.CRRT AS CRRT,
    MIMICIV_DERIVED.ICUSTAY_DETAIL AS ICU
    WHERE SUBJECT.STAY_ID = CRRT.STAY_ID
    AND SUBJECT.STAY_ID = ICU.STAY_ID
    AND CRRT.CHARTTIME >= ICU.ICU_INTIME
    GROUP BY SUBJECT.STAY_ID
),
comorbidity_main AS (
    SELECT DISTINCT subject.hadm_id,
        MAX(CASE WHEN dia.icd_code IN ('Z940') THEN 1 ELSE 0 END) AS kidneytransplant,
        MAX(CASE WHEN dia.icd_code IN ('V451','V4511') THEN 1 ELSE 0 END) AS kindeydialysis,
        MAX(CASE WHEN dia.icd_code IN ('042','B20','V08') THEN 1 ELSE 0 END) AS HIV,
        MAX(CASE WHEN dia.icd_code IN ('Z21') THEN 1 ELSE 0 END) AS HIVZ21,
        MAX(CASE WHEN dia.icd_code IN ('4019','I10','4011','I161','4010') THEN 1 ELSE 0 END) AS HTN,
        MAX(CASE WHEN dia.icd_code IN ('5849','N179','5845','N170') THEN 1 ELSE 0 END) AS AKI,
        MAX(CASE WHEN dia.icd_code IN ('V1254','Z8673','431','43820','43811','4359','V17','43883','99702','G459') THEN 1 ELSE 0 END) AS CVA,
        MAX(CASE WHEN dia.icd_code IN ('40390','5859','I129','N189','N183','5853','I130','I120','5854','N184','5852','40310','N182','5855','N185','E1122') THEN 1 ELSE 0 END) AS CKD,
        MAX(CASE WHEN dia.icd_code IN ('V103','V1046','Z85828','V1083','Z853','1985','C787','C7951','V160','V1011','V1052','V1051','185','Z85038','1976','Z800','V163','19889','Z85118','1629','C786','C7931','Z803','C61','Z8551') THEN 1 ELSE 0 END) AS CA,
        MAX(CASE WHEN dia.icd_code IN ('E119','E1122','E1165','E1140','E1151','E11319','E1142','E1121','E11649','E11621','E1169','E1143','E1152','E118','E11610','E11622','E1110','E11628','E1139','E1136','25000','25060','25040','25050','25002','25080','25062','25042','25052','25070','25012','25092','25072','25090') THEN 1 ELSE 0 END) AS T2DM,
        MAX(CASE WHEN dia.icd_code IN ('E1022','E10319','E1065','E1040','E1043','E10649','E1010','E1021','E109','E1042','E1051','E10621','25061','25001','25051','25041','25063','25013','25053','25043','25081') THEN 1 ELSE 0 END) AS T1DM,
        MAX(CASE WHEN dia.icd_code IN ('4280','42832','42822','I5032','42833','I5033','I5022','42823','I5023','I509','42830','42843','42831','I5030','42821','42842','I5021','I5020','42820','I5031','I5043','I5042','40491','40291','42841','42840','4289','I5084','I50810','I5041','I5082','I5040','4281','I50814','I50811','I50813','I50812','40201','40492','I5089','I5083') THEN 1 ELSE 0 END) AS HF,
        MAX(CASE WHEN dia.icd_code IN ('41000','41001','41002','41010','41011','41012','41020','41021','41022','41030','41031','41032','41040','41041','41042','41050','41051','41052','41080','41081','41082','41090','41091','41092','I21','I219','I230','I231','I232','I233','I234','I235','I236','I238','I210','I2101','I2102','I2109','I211','I2111','I2119','I2121','I2129','I213','I214','I21A1','I21A9','I222') THEN 1 ELSE 0 END) AS MI,
        MAX(CASE WHEN dia.icd_code IN ('J430','490','4910','4911','49120','49121','49122','4918','4919','4928','4940','4941','496','J40','J410','J411','J42','J431','J432','J438','J439','J44','J440','J441','J449','4920') THEN 1 ELSE 0 END) AS COPD
    FROM basic AS subject
    INNER JOIN mimiciv_hosp.diagnoses_icd AS dia
    ON subject.hadm_id = dia.hadm_id
    GROUP BY subject.hadm_id
),
comorbidity_cmv AS (
    SELECT DISTINCT subject.hadm_id,
        MAX(CASE WHEN dia.icd_code IN ('0785','B250','B251','B258','B259') THEN 1 ELSE 0 END) AS CMV
    FROM basic AS subject
    INNER JOIN mimiciv_hosp.diagnoses_icd AS dia
    ON subject.hadm_id = dia.hadm_id
    GROUP BY subject.hadm_id
),
comorbidity_transplant AS (
    SELECT DISTINCT subject.hadm_id,
        MAX(CASE WHEN dia.icd_code IN ('99680','99681','99682','99683','99684','99685','99686','99687','99689','T8600','T8601','T8609','T8610','T8611','T8612','T8613','T8619','T8621','T8622','T8641','T8642','T8643','T8649','T865','T86832','T86838','T86858','T86890','T86891','T86898','V420','V421','Z7682','Z940','Z941','Z942','Z944','Z946','Z9483','Z9484') THEN 1 ELSE 0 END) AS transplant
    FROM basic AS subject
    INNER JOIN mimiciv_hosp.diagnoses_icd AS dia
    ON subject.hadm_id = dia.hadm_id
    GROUP BY subject.hadm_id
),
med_general AS (
    SELECT DISTINCT prescriptions.hadm_id,
        MAX(CASE WHEN prescriptions.gsn IN ('009396','009393','009394','071217') THEN 1 ELSE 0 END) AS SulfamethTrimethoprim_Suspension,
        MAX(CASE WHEN prescriptions.gsn IN ('004977','004985','004975','064575','062006','004939','066419','066452','004937','004931','065336','028633','003388','003389','003390','003385','052187','004934','003387','052188','003386','008022','008062','005068','063864','063863','066206','005066','074949','007764','008061','048541','060981','073081','006612','000141','064535','021502','064538') THEN 1 ELSE 0 END) AS VP,
        MAX(CASE WHEN prescriptions.gsn IN ('008765','016500','008771','071489','021796','021797','041832','047347','032599','023724','041845','040376','011682','011681','040549','040550') THEN 1 ELSE 0 END) AS Immunos,
        MAX(CASE WHEN prescriptions.gsn IN ('066110','006705','051558','006704','007544','023906','006696','006858','007545','007543','006724','006725','006753','007894','007892','006786','006784','006788','006776','006778','006789','006721','067556','047282','006745','060958','062053','006780','013701','006762','006758','006812','066112','026721','006749','006738','006742','006754','006748','006750') THEN 1 ELSE 0 END) AS GC,
        MAX(CASE WHEN prescriptions.gsn IN ('047689') THEN 1 ELSE 0 END) AS Caspofungin_Desensitization,
        MAX(CASE WHEN prescriptions.gsn IN ('023399') THEN 1 ELSE 0 END) AS Atovaquone_Suspension,
        MAX(CASE WHEN prescriptions.gsn IN ('009344','009339','013053','009346','015999','007727','013052','009577') THEN 1 ELSE 0 END) AS Primaquine_Phosphate,
        MAX(CASE WHEN prescriptions.gsn IN ('011791','009599') THEN 1 ELSE 0 END) AS Pentamidine_Isethionate2,
        MAX(CASE WHEN prescriptions.gsn IN ('009497') THEN 1 ELSE 0 END) AS Trimethoprim
    FROM mimiciv_hosp.prescriptions AS prescriptions
    INNER JOIN basic AS subject ON prescriptions.hadm_id = subject.hadm_id
    GROUP BY prescriptions.hadm_id
),
med_dose AS (
    SELECT DISTINCT prescriptions.hadm_id,
        SUM(CASE WHEN prescriptions.gsn IN ('009396','009393','009394','071217') AND prescriptions.dose_val_rx ~ '^[0-9]+(\.[0-9]+)?$' THEN CAST(prescriptions.dose_val_rx AS numeric) END) AS SulfamethTrimethoprim_Suspension_totalval,
        MAX(CASE WHEN prescriptions.gsn IN ('009396','009393','009394','071217') THEN prescriptions.dose_unit_rx END) AS SulfamethTrimethoprim_unit,
        SUM(CASE WHEN prescriptions.gsn IN ('004977','004985','004975','064575','062006','004939','066419','066452','004937','004931','065336','028633','003388','003389','003390','003385','052187','004934','003387','052188','003386','008022','008062','005068','063864','063863','066206','005066','074949','007764','008061','048541','060981','073081','006612','000141','064535','021502','064538') AND prescriptions.dose_val_rx ~ '^[0-9]+(\.[0-9]+)?$' THEN CAST(prescriptions.dose_val_rx AS numeric) END) AS VP_totalval,
        MAX(CASE WHEN prescriptions.gsn IN ('004977','004985','004975','064575','062006','004939','066419','066452','004937','004931','065336','028633','003388','003389','003390','003385','052187','004934','003387','052188','003386','008022','008062','005068','063864','063863','066206','005066','074949','007764','008061','048541','060981','073081','006612','000141','064535','021502','064538') THEN prescriptions.dose_unit_rx END) AS VP_unit,
        SUM(CASE WHEN prescriptions.gsn IN ('008765','016500','008771','071489','021796','021797','041832','047347','032599','023724','041845','040376','011682','011681','040549','040550') AND prescriptions.dose_val_rx ~ '^[0-9]+(\.[0-9]+)?$' THEN CAST(prescriptions.dose_val_rx AS numeric) END) AS Immunos_totalval,
        MAX(CASE WHEN prescriptions.gsn IN ('008765','016500','008771','071489','021796','021797','041832','047347','032599','023724','041845','040376','011682','011681','040549','040550') THEN prescriptions.dose_unit_rx END) AS Immunos_unit,
        SUM(CASE WHEN prescriptions.gsn IN ('066110','006705','051558','006704','007544','023906','006696','006858','007545','007543','006724','006725','006753','007894','007892','006786','006784','006788','006776','006778','006789','006721','067556','047282','006745','060958','062053','006780','013701','006762','006758','006812','066112','026721','006749','006738','006742','006754','006748','006750') AND prescriptions.dose_val_rx ~ '^[0-9]+(\.[0-9]+)?$' THEN CAST(prescriptions.dose_val_rx AS numeric) END) AS GC_totalval,
        MAX(CASE WHEN prescriptions.gsn IN ('066110','006705','051558','006704','007544','023906','006696','006858','007545','007543','006724','006725','006753','007894','007892','006786','006784','006788','006776','006778','006789','006721','067556','047282','006745','060958','062053','006780','013701','006762','006758','006812','066112','026721','006749','006738','006742','006754','006748','006750') THEN prescriptions.dose_unit_rx END) AS GC_unit,
        SUM(CASE WHEN prescriptions.gsn IN ('047689') AND prescriptions.dose_val_rx ~ '^[0-9]+(\.[0-9]+)?$' THEN CAST(prescriptions.dose_val_rx AS numeric) END) AS Caspofungin_Desensitization_totalval,
        MAX(CASE WHEN prescriptions.gsn IN ('047689') THEN prescriptions.dose_unit_rx END) AS Caspofungin_Desensitization_unit,
        SUM(CASE WHEN prescriptions.gsn IN ('023399') AND prescriptions.dose_val_rx ~ '^[0-9]+(\.[0-9]+)?$' THEN CAST(prescriptions.dose_val_rx AS numeric) END) AS Atovaquone_Suspension_totalval,
        MAX(CASE WHEN prescriptions.gsn IN ('023399') THEN prescriptions.dose_unit_rx END) AS Atovaquone_Suspension_unit,
        SUM(CASE WHEN prescriptions.gsn IN ('009344','009339','013053','009346','015999','007727','013052','009577') AND prescriptions.dose_val_rx ~ '^[0-9]+(\.[0-9]+)?$' THEN CAST(prescriptions.dose_val_rx AS numeric) END) AS Primaquine_Phosphate_totalval,
        MAX(CASE WHEN prescriptions.gsn IN ('009344','009339','013053','009346','015999','007727','013052','009577') THEN prescriptions.dose_unit_rx END) AS Primaquine_Phosphate_unit,
        SUM(CASE WHEN prescriptions.gsn IN ('011791','009599') AND prescriptions.dose_val_rx ~ '^[0-9]+(\.[0-9]+)?$' THEN CAST(prescriptions.dose_val_rx AS numeric) END) AS Pentamidine_Isethionate2_totalval,
        MAX(CASE WHEN prescriptions.gsn IN ('011791','009599') THEN prescriptions.dose_unit_rx END) AS Pentamidine_Isethionate2_unit,
        SUM(CASE WHEN prescriptions.gsn IN ('009497') AND prescriptions.dose_val_rx ~ '^[0-9]+(\.[0-9]+)?$' THEN CAST(prescriptions.dose_val_rx AS numeric) END) AS Trimethoprim_totalval,
        MAX(CASE WHEN prescriptions.gsn IN ('009497') THEN prescriptions.dose_unit_rx END) AS Trimethoprim_unit
    FROM mimiciv_hosp.prescriptions AS prescriptions
    INNER JOIN basic AS subject ON prescriptions.hadm_id = subject.hadm_id
    GROUP BY prescriptions.hadm_id
)

SELECT DISTINCT
    basic.subject_id,
    basic.stay_id,
    basic.hadm_id,
    basic.admittime,
    basic.dischtime,
    basic.icu_intime,
    basic.icu_outtime,

    -- Demographics
    demographics.age,
    demographics.gender,
    demographics.race,
    demographics.weight,
    demographics.height,
    demographics.insurance,
    demographics.language,
    demographics.marital_status,

    -- Full 24h Labs
    ROUND(lab_all.LAB_24HOUR_Absolute_Lymphocyte_Count::numeric,2) AS LAB_24HOUR_Absolute_Lymphocyte_Count,
    lab_all.LAB_24HOUR_Absolute_Lymphocyte_Count_UOM,
    ROUND(lab_all.LAB_24HOUR_Platelet_Count::numeric,2) AS LAB_24HOUR_Platelet_Count,
    lab_all.LAB_24HOUR_Platelet_Count_UOM,
    ROUND(lab_all.LAB_24HOUR_Absolute_Neutrophil_Count::numeric,2) AS LAB_24HOUR_Absolute_Neutrophil_Count,
    lab_all.LAB_24HOUR_Absolute_Neutrophil_Count_UOM,
    ROUND(lab_all.LAB_24HOUR_Creatinine::numeric,2) AS LAB_24HOUR_Creatinine,
    lab_all.LAB_24HOUR_Creatinine_UOM,
    ROUND(lab_all.LAB_24HOUR_White_Blood_Cells::numeric,2) AS LAB_24HOUR_White_Blood_Cells,
    lab_all.LAB_24HOUR_White_Blood_Cells_UOM,
    ROUND(lab_all.LAB_24HOUR_Red_Blood_Cells::numeric,2) AS LAB_24HOUR_Red_Blood_Cells,
    lab_all.LAB_24HOUR_Red_Blood_Cells_UOM,
    ROUND(lab_all.LAB_24HOUR_Hemoglobin::numeric,2) AS LAB_24HOUR_Hemoglobin,
    lab_all.LAB_24HOUR_Hemoglobin_UOM,
    ROUND(lab_all.LAB_24HOUR_Monocytes::numeric,2) AS LAB_24HOUR_Monocytes,
    lab_all.LAB_24HOUR_Monocytes_UOM,
    ROUND(lab_all.LAB_24HOUR_Lactate_Dehydrogenase_LD::numeric,2) AS LAB_24HOUR_Lactate_Dehydrogenase_LD,
    lab_all.LAB_24HOUR_Lactate_Dehydrogenase_LD_UOM,
    ROUND(lab_all.LAB_24HOUR_Oxygen::numeric,2) AS LAB_24HOUR_Oxygen,
    lab_all.LAB_24HOUR_Oxygen_UOM,
    ROUND(lab_all.LAB_24HOUR_pO2::numeric,2) AS LAB_24HOUR_pO2,
    lab_all.LAB_24HOUR_pO2_UOM,
    ROUND(lab_all.LAB_24HOUR_Lymphocytes_PCT::numeric,2) AS LAB_24HOUR_Lymphocytes_PCT,
    lab_all.LAB_24HOUR_Lymphocytes_PCT_UOM,
    ROUND(lab_all.LAB_24HOUR_Neutrophils_PCT::numeric,2) AS LAB_24HOUR_Neutrophils_PCT,
    lab_all.LAB_24HOUR_Neutrophils_PCT_UOM,

    -- CD4 Labs
    ROUND(lab_cd4.FIRST_Absolute_CD4_Count::numeric,2) AS FIRST_Absolute_CD4_Count,
    lab_cd4.FIRST_Absolute_CD4_Count_UOM,
    lab_cd4.Absolute_CD4_Count_charttime,
    lab_cd4.Absolute_CD4_Count_storetime,
    ROUND(lab_cd4.FIRST_CD4_Cells_Percent::numeric,2) AS FIRST_CD4_Cells_Percent,
    lab_cd4.FIRST_CD4_Cells_Percent_UOM,
    lab_cd4.CD4_Cells_Percent_charttime,
    lab_cd4.CD4_Cells_Percent_storetime,

    -- Chartevents LDH
    ldh_chartevent.first_LDH_value,
    ROUND(ld_chartevent.first_LDH::numeric,2) AS first_LDH,
    ldh_chartevent.first_LDH_uom,
    ldh_chartevent.LDH_chartevents_charttime,
    ldh_chartevent.LDH_chartevents_storetime,

    -- Organ Support
    ventilation.VENTILATION_FLAG,
    ventilation.VENTILATION_HOUR,
    ventilation.VENTILATION_FIRST_TIME,
    crrt.CRRT_FLAG,
    crrt.CRRT_DAY,
    crrt.CRRT_FIRST_TIME,

    -- Comorbidities
    COALESCE(comorbidity_main.kidneytransplant,0) AS kidneytransplant,
    COALESCE(comorbidity_main.kindeydialysis,0) AS kindeydialysis,
    COALESCE(comorbidity_main.HIV,0) AS HIV,
    COALESCE(comorbidity_main.HIVZ21,0) AS HIVZ21,
    COALESCE(comorbidity_main.HTN,0) AS HTN,
    COALESCE(comorbidity_main.AKI,0) AS AKI,
    COALESCE(comorbidity_main.CVA,0) AS CVA,
    COALESCE(comorbidity_main.CKD,0) AS CKD,
    COALESCE(comorbidity_main.CA,0) AS CA,
    COALESCE(comorbidity_main.T2DM,0) AS T2DM,
    COALESCE(comorbidity_main.T1DM,0) AS T1DM,
    COALESCE(comorbidity_main.HF,0) AS HF,
    COALESCE(comorbidity_main.MI,0) AS MI,
    COALESCE(comorbidity_main.COPD,0) AS COPD,
    COALESCE(comorbidity_cmv.CMV,0) AS CMV,
    COALESCE(comorbidity_transplant.transplant,0) AS transplant,

    -- Medication Flags
    COALESCE(med_general.SulfamethTrimethoprim_Suspension,0) AS SulfamethTrimethoprim_Suspension,
    COALESCE(med_general.VP,0) AS VP,
    COALESCE(med_general.Immunos,0) AS Immunos,
    COALESCE(med_general.GC,0) AS GC,
    COALESCE(med_general.Caspofungin_Desensitization,0) AS Caspofungin_Desensitization,
    COALESCE(med_general.Atovaquone_Suspension,0) AS Atovaquone_Suspension,
    COALESCE(med_general.Primaquine_Phosphate,0) AS Primaquine_Phosphate,
    COALESCE(med_general.Pentamidine_Isethionate2,0) AS Pentamidine_Isethionate2,
    COALESCE(med_general.Trimethoprim,0) AS Trimethoprim,

    -- Medication Dosage
    med_dose.SulfamethTrimethoprim_Suspension_totalval,
    med_dose.SulfamethTrimethoprim_unit,
    med_dose.VP_totalval,
    med_dose.VP_unit,
    med_dose.Immunos_totalval,
    med_dose.Immunos_unit,
    med_dose.GC_totalval,
    med_dose.GC_unit,
    med_dose.Caspofungin_Desensitization_totalval,
    med_dose.Caspofungin_Desensitization_unit,
    med_dose.Atovaquone_Suspension_totalval,
    med_dose.Atovaquone_Suspension_unit,
    med_dose.Primaquine_Phosphate_totalval,
    med_dose.Primaquine_Phosphate_unit,
    med_dose.Pentamidine_Isethionate2_totalval,
    med_dose.Pentamidine_Isethionate2_unit,
    med_dose.Trimethoprim_totalval,
    med_dose.Trimethoprim_unit

FROM basic
LEFT JOIN demographics ON basic.subject_id = demographics.subject_id
LEFT JOIN lab_all ON basic.stay_id = lab_all.stay_id
LEFT JOIN lab_cd4 ON basic.hadm_id = lab_cd4.hadm_id
LEFT JOIN ldh_chartevent ON basic.stay_id = ldh_chartevent.stay_id
LEFT JOIN ventilation ON basic.stay_id = ventilation.stay_id
LEFT JOIN crrt ON basic.stay_id = crrt.stay_id
LEFT JOIN comorbidity_main ON basic.hadm_id = comorbidity_main.hadm_id
LEFT JOIN comorbidity_cmv ON basic.hadm_id = comorbidity_cmv.hadm_id
LEFT JOIN comorbidity_transplant ON basic.hadm_id = comorbidity_transplant.hadm_id
LEFT JOIN med_general ON basic.hadm_id = med_general.hadm_id
LEFT JOIN med_dose ON basic.hadm_id = med_dose.hadm_id

ORDER BY basic.subject_id;
