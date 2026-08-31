WITH 
basic AS (
    WITH
    --纳入的诊断
/*
传染病|胸部/肺部感染|肺炎
传染病|胸部/肺部感染|肺炎|机会感染
传染病|胸部/肺部感染|肺炎|机会感染|卡氏肺囊虫病
肺部|肺部感染|肺炎
肺|肺部感染|肺炎|机会性
肺|肺部感染|肺炎|机会性|肺孢子菌肺炎
infectious diseases|chest/pulmonary infections|pneumonia|opportunistic|PCP
pulmonary|pulmonary infections|pneumonia|opportunistic|PCP
*/
included_disease1 AS(
	SELECT DISTINCT ON(patientunitstayid) diagnosisid,patientunitstayid,dia.diagnosisstring,icd9code,codeid,original_icdcode 
	FROM eicu_crd.diagnosis AS dia,
			(SELECT codeid,icd_code,original_icdcode,diagnosisstring 
			FROM "dictionary".d_icd_diagnosis WHERE codeid in ('800912')
			) AS did
	WHERE True
		AND (CASE
			WHEN did.original_icdcode IS NULL THEN dia.diagnosisstring = did.diagnosisstring
			ELSE dia.icd9code LIKE CONCAT('%', did.original_icdcode, '%')
		END)
),
/*
传染病|胸部/肺部感染|肺炎
传染病|胸部/肺部感染|肺炎|机会感染
传染病|胸部/肺部感染|肺炎|机会感染|卡氏肺囊虫病
肺部|肺部感染|肺炎
肺|肺部感染|肺炎|机会性
肺|肺部感染|肺炎|机会性|肺孢子菌肺炎
infectious diseases|chest/pulmonary infections|pneumonia|opportunistic|PCP
pulmonary|pulmonary infections|pneumonia|opportunistic|PCP
*/
included_disease2 AS(
	SELECT DISTINCT ON(patientunitstayid) diagnosisid,patientunitstayid,dia.diagnosisstring,icd9code,codeid,original_icdcode 
	FROM eicu_crd.diagnosis AS dia,
			(SELECT codeid,icd_code,original_icdcode,diagnosisstring 
			FROM "dictionary".d_icd_diagnosis WHERE codeid in ('800911')
			) AS did
	WHERE True
		AND (CASE
			WHEN did.original_icdcode IS NULL THEN dia.diagnosisstring = did.diagnosisstring
			ELSE dia.icd9code LIKE CONCAT('%', did.original_icdcode, '%')
		END)
)
SELECT DISTINCT ON(pat.uniquepid) pat.patientunitstayid,pat.age,pat.gender,pat.uniquepid
FROM eicu_crd.patient AS pat
WHERE True
    AND pat.age BETWEEN '18' AND '99'
        --纳入诊断疾病
        AND (
            pat.patientunitstayid IN (SELECT patientunitstayid FROM included_disease1)
            OR pat.patientunitstayid IN (SELECT patientunitstayid FROM included_disease2)
        )
)
--SELECT * FROM basic;

SELECT patient.patientunitstayid,patient.age,patient.gender,patient.admissionheight height,patient.ethnicity AS race,patient.admissionweight AS weight,patient.unittype AS unittype,patient.hospitaladmittime24 AS hospitaladmittime24,patient.hospitaladmitoffset AS hospitaladmitoffset,patient.hospitaldischargetime24 AS hospitaldischargetime24,patient.hospitaldischargeoffset AS hospitaldischargeoffset,patient.unitadmittime24 AS unitadmittime24,patient.unitdischargetime24 AS unitdischargetime24,patient.unitdischargeoffset AS unitdischargeoffset,patient.hospitaldischargeyear AS hospitaldischargeyear
FROM eicu_crd.patient AS patient,basic
WHERE patient.patientunitstayid=basic.patientunitstayid;
WITH 
basic AS (
    WITH
    --纳入的诊断
/*
传染病|胸部/肺部感染|肺炎
传染病|胸部/肺部感染|肺炎|机会感染
传染病|胸部/肺部感染|肺炎|机会感染|卡氏肺囊虫病
肺部|肺部感染|肺炎
肺|肺部感染|肺炎|机会性
肺|肺部感染|肺炎|机会性|肺孢子菌肺炎
infectious diseases|chest/pulmonary infections|pneumonia|opportunistic|PCP
pulmonary|pulmonary infections|pneumonia|opportunistic|PCP
*/
included_disease1 AS(
	SELECT DISTINCT ON(patientunitstayid) diagnosisid,patientunitstayid,dia.diagnosisstring,icd9code,codeid,original_icdcode 
	FROM eicu_crd.diagnosis AS dia,
			(SELECT codeid,icd_code,original_icdcode,diagnosisstring 
			FROM "dictionary".d_icd_diagnosis WHERE codeid in ('800912')
			) AS did
	WHERE True
		AND (CASE
			WHEN did.original_icdcode IS NULL THEN dia.diagnosisstring = did.diagnosisstring
			ELSE dia.icd9code LIKE CONCAT('%', did.original_icdcode, '%')
		END)
),
/*
传染病|胸部/肺部感染|肺炎
传染病|胸部/肺部感染|肺炎|机会感染
传染病|胸部/肺部感染|肺炎|机会感染|卡氏肺囊虫病
肺部|肺部感染|肺炎
肺|肺部感染|肺炎|机会性
肺|肺部感染|肺炎|机会性|肺孢子菌肺炎
infectious diseases|chest/pulmonary infections|pneumonia|opportunistic|PCP
pulmonary|pulmonary infections|pneumonia|opportunistic|PCP
*/
included_disease2 AS(
	SELECT DISTINCT ON(patientunitstayid) diagnosisid,patientunitstayid,dia.diagnosisstring,icd9code,codeid,original_icdcode 
	FROM eicu_crd.diagnosis AS dia,
			(SELECT codeid,icd_code,original_icdcode,diagnosisstring 
			FROM "dictionary".d_icd_diagnosis WHERE codeid in ('800911')
			) AS did
	WHERE True
		AND (CASE
			WHEN did.original_icdcode IS NULL THEN dia.diagnosisstring = did.diagnosisstring
			ELSE dia.icd9code LIKE CONCAT('%', did.original_icdcode, '%')
		END)
)
SELECT DISTINCT ON(pat.uniquepid) pat.patientunitstayid,pat.age,pat.gender,pat.uniquepid
FROM eicu_crd.patient AS pat
WHERE True
    AND pat.age BETWEEN '18' AND '99'
        --纳入诊断疾病
        AND (
            pat.patientunitstayid IN (SELECT patientunitstayid FROM included_disease1)
            OR pat.patientunitstayid IN (SELECT patientunitstayid FROM included_disease2)
        )
)
--SELECT * FROM basic;

,
--WBC_x_1000 白细胞*1000
WBC_x_1000 AS(SELECT 
    lab.patientunitstayid,
    MAX(lab.labresult) AS first_WBC_x_1000,
    MAX(lab.labmeasurenamesystem) AS first_WBC_x_1000_uom,
    MIN(lab.labresultoffset) AS first_WBC_x_1000_min_labresultoffset
FROM 
    eicu_crd.lab 
WHERE 
    lab.labresultoffset > 0
    AND lab.labnameid IN (100157)
GROUP BY 
    lab.patientunitstayid
),
--RBC 红细胞计数
RBC AS(SELECT 
    lab.patientunitstayid,
    MAX(lab.labresult) AS first_RBC,
    MAX(lab.labmeasurenamesystem) AS first_RBC_uom,
    MIN(lab.labresultoffset) AS first_RBC_min_labresultoffset
FROM 
    eicu_crd.lab 
WHERE 
    lab.labresultoffset > 0
    AND lab.labnameid IN (100108)
GROUP BY 
    lab.patientunitstayid
),
--platelets_x_1000 血小板*1000
platelets_x_1000 AS(SELECT 
    lab.patientunitstayid,
    MAX(lab.labresult) AS first_platelets_x_1000,
    MAX(lab.labmeasurenamesystem) AS first_platelets_x_1000_uom,
    MIN(lab.labresultoffset) AS first_platelets_x_1000_min_labresultoffset
FROM 
    eicu_crd.lab 
WHERE 
    lab.labresultoffset > 0
    AND lab.labnameid IN (100094)
GROUP BY 
    lab.patientunitstayid
),
--Hgb 血红蛋白
Hgb AS(SELECT 
    lab.patientunitstayid,
    MAX(lab.labresult) AS first_Hgb,
    MAX(lab.labmeasurenamesystem) AS first_Hgb_uom,
    MIN(lab.labresultoffset) AS first_Hgb_min_labresultoffset
FROM 
    eicu_crd.lab 
WHERE 
    lab.labresultoffset > 0
    AND lab.labnameid IN (100061)
GROUP BY 
    lab.patientunitstayid
),
--lymphs -淋巴细胞
lymphs AS(SELECT 
    lab.patientunitstayid,
    MAX(lab.labresult) AS first_lymphs,
    MAX(lab.labmeasurenamesystem) AS first_lymphs_uom,
    MIN(lab.labresultoffset) AS first_lymphs_min_labresultoffset
FROM 
    eicu_crd.lab 
WHERE 
    lab.labresultoffset > 0
    AND lab.labnameid IN (100003)
GROUP BY 
    lab.patientunitstayid
),
--monos -单核细胞
monos AS(SELECT 
    lab.patientunitstayid,
    MAX(lab.labresult) AS first_monos,
    MAX(lab.labmeasurenamesystem) AS first_monos_uom,
    MIN(lab.labresultoffset) AS first_monos_min_labresultoffset
FROM 
    eicu_crd.lab 
WHERE 
    lab.labresultoffset > 0
    AND lab.labnameid IN (100004)
GROUP BY 
    lab.patientunitstayid
),
--CRP C反应蛋白
CRP AS(SELECT 
    lab.patientunitstayid,
    MAX(lab.labresult) AS first_CRP,
    MAX(lab.labmeasurenamesystem) AS first_CRP_uom,
    MIN(lab.labresultoffset) AS first_CRP_min_labresultoffset
FROM 
    eicu_crd.lab 
WHERE 
    lab.labresultoffset > 0
    AND lab.labnameid IN (100037)
GROUP BY 
    lab.patientunitstayid
),
--CRPhs 超敏C反应蛋白
CRPhs AS(SELECT 
    lab.patientunitstayid,
    MAX(lab.labresult) AS first_CRPhs,
    MAX(lab.labmeasurenamesystem) AS first_CRPhs_uom,
    MIN(lab.labresultoffset) AS first_CRPhs_min_labresultoffset
FROM 
    eicu_crd.lab 
WHERE 
    lab.labresultoffset > 0
    AND lab.labnameid IN (100038)
GROUP BY 
    lab.patientunitstayid
),
--basos -嗜碱性粒细胞
basos AS(SELECT 
    lab.patientunitstayid,
    MAX(lab.labresult) AS first_basos,
    MAX(lab.labmeasurenamesystem) AS first_basos_uom,
    MIN(lab.labresultoffset) AS first_basos_min_labresultoffset
FROM 
    eicu_crd.lab 
WHERE 
    lab.labresultoffset > 0
    AND lab.labnameid IN (100001)
GROUP BY 
    lab.patientunitstayid
),
--eos -嗜酸性粒细胞
eos AS(SELECT 
    lab.patientunitstayid,
    MAX(lab.labresult) AS first_eos,
    MAX(lab.labmeasurenamesystem) AS first_eos_uom,
    MIN(lab.labresultoffset) AS first_eos_min_labresultoffset
FROM 
    eicu_crd.lab 
WHERE 
    lab.labresultoffset > 0
    AND lab.labnameid IN (100002)
GROUP BY 
    lab.patientunitstayid
),
--polys -多形核白细胞
polys AS(SELECT 
    lab.patientunitstayid,
    MAX(lab.labresult) AS first_polys,
    MAX(lab.labmeasurenamesystem) AS first_polys_uom,
    MIN(lab.labresultoffset) AS first_polys_min_labresultoffset
FROM 
    eicu_crd.lab 
WHERE 
    lab.labresultoffset > 0
    AND lab.labnameid IN (100005)
GROUP BY 
    lab.patientunitstayid
),
--FiO2 吸入氧分压
FiO2 AS(SELECT 
    lab.patientunitstayid,
    MAX(lab.labresult) AS first_FiO2,
    MAX(lab.labmeasurenamesystem) AS first_FiO2_uom,
    MIN(lab.labresultoffset) AS first_FiO2_min_labresultoffset
FROM 
    eicu_crd.lab 
WHERE 
    lab.labresultoffset > 0
    AND lab.labnameid IN (100049)
GROUP BY 
    lab.patientunitstayid
),
--paO2 氧分压
paO2 AS(SELECT 
    lab.patientunitstayid,
    MAX(lab.labresult) AS first_paO2,
    MAX(lab.labmeasurenamesystem) AS first_paO2_uom,
    MIN(lab.labresultoffset) AS first_paO2_min_labresultoffset
FROM 
    eicu_crd.lab 
WHERE 
    lab.labresultoffset > 0
    AND lab.labnameid IN (100087)
GROUP BY 
    lab.patientunitstayid
),
--Peak_AirwayPressure 峰值气道压力
Peak_AirwayPressure AS(SELECT 
    lab.patientunitstayid,
    MAX(lab.labresult) AS first_Peak_AirwayPressure,
    MAX(lab.labmeasurenamesystem) AS first_Peak_AirwayPressure_uom,
    MIN(lab.labresultoffset) AS first_Peak_AirwayPressure_min_labresultoffset
FROM 
    eicu_crd.lab 
WHERE 
    lab.labresultoffset > 0
    AND lab.labnameid IN (100088)
GROUP BY 
    lab.patientunitstayid
),
--LDH 乳酸脱氢酶
LDH AS(SELECT 
    lab.patientunitstayid,
    MAX(lab.labresult) AS first_LDH,
    MAX(lab.labmeasurenamesystem) AS first_LDH_uom,
    MIN(lab.labresultoffset) AS first_LDH_min_labresultoffset
FROM 
    eicu_crd.lab 
WHERE 
    lab.labresultoffset > 0
    AND lab.labnameid IN (100067)
GROUP BY 
    lab.patientunitstayid
)
SELECT 
    basic.patientunitstayid,
    WBC_x_1000.first_WBC_x_1000,
WBC_x_1000.first_WBC_x_1000_uom,
WBC_x_1000.first_WBC_x_1000_min_labresultoffset,
RBC.first_RBC,
RBC.first_RBC_uom,
RBC.first_RBC_min_labresultoffset,
platelets_x_1000.first_platelets_x_1000,
platelets_x_1000.first_platelets_x_1000_uom,
platelets_x_1000.first_platelets_x_1000_min_labresultoffset,
Hgb.first_Hgb,
Hgb.first_Hgb_uom,
Hgb.first_Hgb_min_labresultoffset,
lymphs.first_lymphs,
lymphs.first_lymphs_uom,
lymphs.first_lymphs_min_labresultoffset,
monos.first_monos,
monos.first_monos_uom,
monos.first_monos_min_labresultoffset,
CRP.first_CRP,
CRP.first_CRP_uom,
CRP.first_CRP_min_labresultoffset,
CRPhs.first_CRPhs,
CRPhs.first_CRPhs_uom,
CRPhs.first_CRPhs_min_labresultoffset,
basos.first_basos,
basos.first_basos_uom,
basos.first_basos_min_labresultoffset,
eos.first_eos,
eos.first_eos_uom,
eos.first_eos_min_labresultoffset,
polys.first_polys,
polys.first_polys_uom,
polys.first_polys_min_labresultoffset,
FiO2.first_FiO2,
FiO2.first_FiO2_uom,
FiO2.first_FiO2_min_labresultoffset,
paO2.first_paO2,
paO2.first_paO2_uom,
paO2.first_paO2_min_labresultoffset,
Peak_AirwayPressure.first_Peak_AirwayPressure,
Peak_AirwayPressure.first_Peak_AirwayPressure_uom,
Peak_AirwayPressure.first_Peak_AirwayPressure_min_labresultoffset,
LDH.first_LDH,
LDH.first_LDH_uom,
LDH.first_LDH_min_labresultoffset
FROM basic
LEFT JOIN WBC_x_1000 ON basic.patientunitstayid=WBC_x_1000.patientunitstayid
LEFT JOIN RBC ON basic.patientunitstayid=RBC.patientunitstayid
LEFT JOIN platelets_x_1000 ON basic.patientunitstayid=platelets_x_1000.patientunitstayid
LEFT JOIN Hgb ON basic.patientunitstayid=Hgb.patientunitstayid
LEFT JOIN lymphs ON basic.patientunitstayid=lymphs.patientunitstayid
LEFT JOIN monos ON basic.patientunitstayid=monos.patientunitstayid
LEFT JOIN CRP ON basic.patientunitstayid=CRP.patientunitstayid
LEFT JOIN CRPhs ON basic.patientunitstayid=CRPhs.patientunitstayid
LEFT JOIN basos ON basic.patientunitstayid=basos.patientunitstayid
LEFT JOIN eos ON basic.patientunitstayid=eos.patientunitstayid
LEFT JOIN polys ON basic.patientunitstayid=polys.patientunitstayid
LEFT JOIN FiO2 ON basic.patientunitstayid=FiO2.patientunitstayid
LEFT JOIN paO2 ON basic.patientunitstayid=paO2.patientunitstayid
LEFT JOIN Peak_AirwayPressure ON basic.patientunitstayid=Peak_AirwayPressure.patientunitstayid
LEFT JOIN LDH ON basic.patientunitstayid=LDH.patientunitstayid;
WITH 
basic AS (
    WITH
    --纳入的诊断
/*
传染病|胸部/肺部感染|肺炎
传染病|胸部/肺部感染|肺炎|机会感染
传染病|胸部/肺部感染|肺炎|机会感染|卡氏肺囊虫病
肺部|肺部感染|肺炎
肺|肺部感染|肺炎|机会性
肺|肺部感染|肺炎|机会性|肺孢子菌肺炎
infectious diseases|chest/pulmonary infections|pneumonia|opportunistic|PCP
pulmonary|pulmonary infections|pneumonia|opportunistic|PCP
*/
included_disease1 AS(
	SELECT DISTINCT ON(patientunitstayid) diagnosisid,patientunitstayid,dia.diagnosisstring,icd9code,codeid,original_icdcode 
	FROM eicu_crd.diagnosis AS dia,
			(SELECT codeid,icd_code,original_icdcode,diagnosisstring 
			FROM "dictionary".d_icd_diagnosis WHERE codeid in ('800912')
			) AS did
	WHERE True
		AND (CASE
			WHEN did.original_icdcode IS NULL THEN dia.diagnosisstring = did.diagnosisstring
			ELSE dia.icd9code LIKE CONCAT('%', did.original_icdcode, '%')
		END)
),
/*
传染病|胸部/肺部感染|肺炎
传染病|胸部/肺部感染|肺炎|机会感染
传染病|胸部/肺部感染|肺炎|机会感染|卡氏肺囊虫病
肺部|肺部感染|肺炎
肺|肺部感染|肺炎|机会性
肺|肺部感染|肺炎|机会性|肺孢子菌肺炎
infectious diseases|chest/pulmonary infections|pneumonia|opportunistic|PCP
pulmonary|pulmonary infections|pneumonia|opportunistic|PCP
*/
included_disease2 AS(
	SELECT DISTINCT ON(patientunitstayid) diagnosisid,patientunitstayid,dia.diagnosisstring,icd9code,codeid,original_icdcode 
	FROM eicu_crd.diagnosis AS dia,
			(SELECT codeid,icd_code,original_icdcode,diagnosisstring 
			FROM "dictionary".d_icd_diagnosis WHERE codeid in ('800911')
			) AS did
	WHERE True
		AND (CASE
			WHEN did.original_icdcode IS NULL THEN dia.diagnosisstring = did.diagnosisstring
			ELSE dia.icd9code LIKE CONCAT('%', did.original_icdcode, '%')
		END)
)
SELECT DISTINCT ON(pat.uniquepid) pat.patientunitstayid,pat.age,pat.gender,pat.uniquepid
FROM eicu_crd.patient AS pat
WHERE True
    AND pat.age BETWEEN '18' AND '99'
        --纳入诊断疾病
        AND (
            pat.patientunitstayid IN (SELECT patientunitstayid FROM included_disease1)
            OR pat.patientunitstayid IN (SELECT patientunitstayid FROM included_disease2)
        )
)
--SELECT * FROM basic;

,
--creatinine 肌酐
creatinine AS(SELECT 
    lab.patientunitstayid,
    MAX(lab.labresult) AS first_creatinine,
    MAX(lab.labmeasurenamesystem) AS first_creatinine_uom,
    MIN(lab.labresultoffset) AS first_creatinine_min_labresultoffset
FROM 
    eicu_crd.lab 
WHERE 
    lab.labresultoffset > 0
    AND lab.labnameid IN (100036)
GROUP BY 
    lab.patientunitstayid
),
--albumin 白蛋白
albumin AS(SELECT 
    lab.patientunitstayid,
    MAX(lab.labresult) AS first_albumin,
    MAX(lab.labmeasurenamesystem) AS first_albumin_uom,
    MIN(lab.labresultoffset) AS first_albumin_min_labresultoffset
FROM 
    eicu_crd.lab 
WHERE 
    lab.labresultoffset > 0
    AND lab.labnameid IN (100009)
GROUP BY 
    lab.patientunitstayid
)
SELECT 
    basic.patientunitstayid,
    creatinine.first_creatinine,
creatinine.first_creatinine_uom,
creatinine.first_creatinine_min_labresultoffset,
albumin.first_albumin,
albumin.first_albumin_uom,
albumin.first_albumin_min_labresultoffset
FROM basic
LEFT JOIN creatinine ON basic.patientunitstayid=creatinine.patientunitstayid
LEFT JOIN albumin ON basic.patientunitstayid=albumin.patientunitstayid;
WITH 
basic AS (
    WITH
    --纳入的诊断
/*
传染病|胸部/肺部感染|肺炎
传染病|胸部/肺部感染|肺炎|机会感染
传染病|胸部/肺部感染|肺炎|机会感染|卡氏肺囊虫病
肺部|肺部感染|肺炎
肺|肺部感染|肺炎|机会性
肺|肺部感染|肺炎|机会性|肺孢子菌肺炎
infectious diseases|chest/pulmonary infections|pneumonia|opportunistic|PCP
pulmonary|pulmonary infections|pneumonia|opportunistic|PCP
*/
included_disease1 AS(
    SELECT DISTINCT ON(patientunitstayid) diagnosisid,patientunitstayid,dia.diagnosisstring,icd9code,codeid,original_icdcode 
    FROM eicu_crd.diagnosis AS dia,
            (SELECT codeid,icd_code,original_icdcode,diagnosisstring 
            FROM "dictionary".d_icd_diagnosis WHERE codeid in ('800912')
            ) AS did
    WHERE True
        AND (CASE
            WHEN did.original_icdcode IS NULL THEN dia.diagnosisstring = did.diagnosisstring
            ELSE dia.icd9code LIKE CONCAT('%', did.original_icdcode, '%')
        END)
),
/*
传染病|胸部/肺部感染|肺炎
传染病|胸部/肺部感染|肺炎|机会感染
传染病|胸部/肺部感染|肺炎|机会感染|卡氏肺囊虫病
肺部|肺部感染|肺炎
肺|肺部感染|肺炎|机会性
肺|肺部感染|肺炎|机会性|肺孢子菌肺炎
infectious diseases|chest/pulmonary infections|pneumonia|opportunistic|PCP
pulmonary|pulmonary infections|pneumonia|opportunistic|PCP
*/
included_disease2 AS(
    SELECT DISTINCT ON(patientunitstayid) diagnosisid,patientunitstayid,dia.diagnosisstring,icd9code,codeid,original_icdcode 
    FROM eicu_crd.diagnosis AS dia,
            (SELECT codeid,icd_code,original_icdcode,diagnosisstring 
            FROM "dictionary".d_icd_diagnosis WHERE codeid in ('800911')
            ) AS did
    WHERE True
        AND (CASE
            WHEN did.original_icdcode IS NULL THEN dia.diagnosisstring = did.diagnosisstring
            ELSE dia.icd9code LIKE CONCAT('%', did.original_icdcode, '%')
        END)
)
SELECT DISTINCT ON(pat.uniquepid) pat.patientunitstayid,pat.age,pat.gender,pat.uniquepid
FROM eicu_crd.patient AS pat
WHERE True
    AND pat.age BETWEEN '18' AND '99'
        --纳入诊断疾病
        AND (
            pat.patientunitstayid IN (SELECT patientunitstayid FROM included_disease1)
            OR pat.patientunitstayid IN (SELECT patientunitstayid FROM included_disease2)
        )
)
--SELECT * FROM basic;

,
--cd_4 淋巴细胞计数4
cd_4 AS(SELECT 
    lab.patientunitstayid,
    MAX(lab.labresult) AS first_cd_4,
    MAX(lab.labmeasurenamesystem) AS first_cd_4_uom,
    MIN(lab.labresultoffset) AS first_cd_4_min_labresultoffset
FROM 
    eicu_crd.lab 
WHERE 
    lab.labresultoffset > 0
    AND lab.labnameid IN (100029)
GROUP BY 
    lab.patientunitstayid
)
SELECT 
    basic.patientunitstayid,
    cd_4.first_cd_4,
cd_4.first_cd_4_uom,
cd_4.first_cd_4_min_labresultoffset
FROM basic
LEFT JOIN cd_4 ON basic.patientunitstayid=cd_4.patientunitstayid;
WITH 
basic AS (
    WITH
    --纳入的诊断
/*
传染病|胸部/肺部感染|肺炎
传染病|胸部/肺部感染|肺炎|机会感染
传染病|胸部/肺部感染|肺炎|机会感染|卡氏肺囊虫病
肺部|肺部感染|肺炎
肺|肺部感染|肺炎|机会性
肺|肺部感染|肺炎|机会性|肺孢子菌肺炎
infectious diseases|chest/pulmonary infections|pneumonia|opportunistic|PCP
pulmonary|pulmonary infections|pneumonia|opportunistic|PCP
*/
included_disease1 AS(
	SELECT DISTINCT ON(patientunitstayid) diagnosisid,patientunitstayid,dia.diagnosisstring,icd9code,codeid,original_icdcode 
	FROM eicu_crd.diagnosis AS dia,
			(SELECT codeid,icd_code,original_icdcode,diagnosisstring 
			FROM "dictionary".d_icd_diagnosis WHERE codeid in ('800912')
			) AS did
	WHERE True
		AND (CASE
			WHEN did.original_icdcode IS NULL THEN dia.diagnosisstring = did.diagnosisstring
			ELSE dia.icd9code LIKE CONCAT('%', did.original_icdcode, '%')
		END)
),
/*
传染病|胸部/肺部感染|肺炎
传染病|胸部/肺部感染|肺炎|机会感染
传染病|胸部/肺部感染|肺炎|机会感染|卡氏肺囊虫病
肺部|肺部感染|肺炎
肺|肺部感染|肺炎|机会性
肺|肺部感染|肺炎|机会性|肺孢子菌肺炎
infectious diseases|chest/pulmonary infections|pneumonia|opportunistic|PCP
pulmonary|pulmonary infections|pneumonia|opportunistic|PCP
*/
included_disease2 AS(
	SELECT DISTINCT ON(patientunitstayid) diagnosisid,patientunitstayid,dia.diagnosisstring,icd9code,codeid,original_icdcode 
	FROM eicu_crd.diagnosis AS dia,
			(SELECT codeid,icd_code,original_icdcode,diagnosisstring 
			FROM "dictionary".d_icd_diagnosis WHERE codeid in ('800911')
			) AS did
	WHERE True
		AND (CASE
			WHEN did.original_icdcode IS NULL THEN dia.diagnosisstring = did.diagnosisstring
			ELSE dia.icd9code LIKE CONCAT('%', did.original_icdcode, '%')
		END)
)
SELECT DISTINCT ON(pat.uniquepid) pat.patientunitstayid,pat.age,pat.gender,pat.uniquepid
FROM eicu_crd.patient AS pat
WHERE True
    AND pat.age BETWEEN '18' AND '99'
        --纳入诊断疾病
        AND (
            pat.patientunitstayid IN (SELECT patientunitstayid FROM included_disease1)
            OR pat.patientunitstayid IN (SELECT patientunitstayid FROM included_disease2)
        )
)
--SELECT * FROM basic;

SELECT 
    b.patientunitstayid,
    p.hospitaldischargestatus,
    ((p.hospitaldischargeoffset - p.hospitaladmitoffset) /( 24.0*60)) AS hosplosday,
    (i.icu_los_hours / 24.0) AS unitlosday,
    p.unitadmitsource,
    p.unitdischargelocation,
    p.unitdischargestatus,
    p.unitstaytype,
    i.unittype
FROM 
    basic b 
LEFT JOIN 
    eicu_crd.patient p ON b.patientunitstayid = p.patientunitstayid
LEFT JOIN 
eicu_crd.icustay_detail i ON p.patientunitstayid = i.patientunitstayid;

WITH 
basic AS (
    WITH
    --纳入的诊断
/*
传染病|胸部/肺部感染|肺炎
传染病|胸部/肺部感染|肺炎|机会感染
传染病|胸部/肺部感染|肺炎|机会感染|卡氏肺囊虫病
肺部|肺部感染|肺炎
肺|肺部感染|肺炎|机会性
肺|肺部感染|肺炎|机会性|肺孢子菌肺炎
infectious diseases|chest/pulmonary infections|pneumonia|opportunistic|PCP
pulmonary|pulmonary infections|pneumonia|opportunistic|PCP
*/
included_disease1 AS(
    SELECT DISTINCT ON(patientunitstayid) diagnosisid,patientunitstayid,dia.diagnosisstring,icd9code,codeid,original_icdcode 
    FROM eicu_crd.diagnosis AS dia,
            (SELECT codeid,icd_code,original_icdcode,diagnosisstring 
            FROM "dictionary".d_icd_diagnosis WHERE codeid in ('800912')
            ) AS did
    WHERE True
        AND (CASE
            WHEN did.original_icdcode IS NULL THEN dia.diagnosisstring = did.diagnosisstring
            ELSE dia.icd9code LIKE CONCAT('%', did.original_icdcode, '%')
        END)
),
/*
传染病|胸部/肺部感染|肺炎
传染病|胸部/肺部感染|肺炎|机会感染
传染病|胸部/肺部感染|肺炎|机会感染|卡氏肺囊虫病
肺部|肺部感染|肺炎
肺|肺部感染|肺炎|机会性
肺|肺部感染|肺炎|机会性|肺孢子菌肺炎
infectious diseases|chest/pulmonary infections|pneumonia|opportunistic|PCP
pulmonary|pulmonary infections|pneumonia|opportunistic|PCP
*/
included_disease2 AS(
    SELECT DISTINCT ON(patientunitstayid) diagnosisid,patientunitstayid,dia.diagnosisstring,icd9code,codeid,original_icdcode 
    FROM eicu_crd.diagnosis AS dia,
            (SELECT codeid,icd_code,original_icdcode,diagnosisstring 
            FROM "dictionary".d_icd_diagnosis WHERE codeid in ('800911')
            ) AS did
    WHERE True
        AND (CASE
            WHEN did.original_icdcode IS NULL THEN dia.diagnosisstring = did.diagnosisstring
            ELSE dia.icd9code LIKE CONCAT('%', did.original_icdcode, '%')
        END)
)
SELECT DISTINCT ON(pat.uniquepid) pat.patientunitstayid,pat.age,pat.gender,pat.uniquepid
FROM eicu_crd.patient AS pat
WHERE True
    AND pat.age BETWEEN '18' AND '99'
        --纳入诊断疾病
        AND (
            pat.patientunitstayid IN (SELECT patientunitstayid FROM included_disease1)
            OR pat.patientunitstayid IN (SELECT patientunitstayid FROM included_disease2)
        )
)
--SELECT * FROM basic;

,
--高血压htn
htn AS(
    SELECT DISTINCT ON(patientunitstayid) diagnosisid,patientunitstayid,dia.diagnosisstring,icd9code,codeid,original_icdcode,FLAG
    FROM eicu_crd.diagnosis AS dia,
            (SELECT codeid,icd_code,original_icdcode,diagnosisstring,1 AS FLAG FROM dictionary.d_icd_diagnosis WHERE codeid in ('800329','801748','800079','800080')) AS did
    WHERE True
            AND (CASE
                WHEN did.original_icdcode IS NULL THEN dia.diagnosisstring = did.diagnosisstring
                ELSE dia.icd9code LIKE CONCAT('%', did.original_icdcode, '%')
            END)
)
SELECT basic.patientunitstayid,
htn.FLAG AS htn
FROM basic 
LEFT JOIN htn ON basic.patientunitstayid=htn.patientunitstayid
ORDER BY  basic.patientunitstayid ASC
WITH 
basic AS (
    WITH
    --纳入的诊断
/*
传染病|胸部/肺部感染|肺炎
传染病|胸部/肺部感染|肺炎|机会感染
传染病|胸部/肺部感染|肺炎|机会感染|卡氏肺囊虫病
肺部|肺部感染|肺炎
肺|肺部感染|肺炎|机会性
肺|肺部感染|肺炎|机会性|肺孢子菌肺炎
infectious diseases|chest/pulmonary infections|pneumonia|opportunistic|PCP
pulmonary|pulmonary infections|pneumonia|opportunistic|PCP
*/
included_disease1 AS(
    SELECT DISTINCT ON(patientunitstayid) diagnosisid,patientunitstayid,dia.diagnosisstring,icd9code,codeid,original_icdcode 
    FROM eicu_crd.diagnosis AS dia,
            (SELECT codeid,icd_code,original_icdcode,diagnosisstring 
            FROM "dictionary".d_icd_diagnosis WHERE codeid in ('800912')
            ) AS did
    WHERE True
        AND (CASE
            WHEN did.original_icdcode IS NULL THEN dia.diagnosisstring = did.diagnosisstring
            ELSE dia.icd9code LIKE CONCAT('%', did.original_icdcode, '%')
        END)
),
/*
传染病|胸部/肺部感染|肺炎
传染病|胸部/肺部感染|肺炎|机会感染
传染病|胸部/肺部感染|肺炎|机会感染|卡氏肺囊虫病
肺部|肺部感染|肺炎
肺|肺部感染|肺炎|机会性
肺|肺部感染|肺炎|机会性|肺孢子菌肺炎
infectious diseases|chest/pulmonary infections|pneumonia|opportunistic|PCP
pulmonary|pulmonary infections|pneumonia|opportunistic|PCP
*/
included_disease2 AS(
    SELECT DISTINCT ON(patientunitstayid) diagnosisid,patientunitstayid,dia.diagnosisstring,icd9code,codeid,original_icdcode 
    FROM eicu_crd.diagnosis AS dia,
            (SELECT codeid,icd_code,original_icdcode,diagnosisstring 
            FROM "dictionary".d_icd_diagnosis WHERE codeid in ('800911')
            ) AS did
    WHERE True
        AND (CASE
            WHEN did.original_icdcode IS NULL THEN dia.diagnosisstring = did.diagnosisstring
            ELSE dia.icd9code LIKE CONCAT('%', did.original_icdcode, '%')
        END)
)
SELECT DISTINCT ON(pat.uniquepid) pat.patientunitstayid,pat.age,pat.gender,pat.uniquepid
FROM eicu_crd.patient AS pat
WHERE True
    AND pat.age BETWEEN '18' AND '99'
        --纳入诊断疾病
        AND (
            pat.patientunitstayid IN (SELECT patientunitstayid FROM included_disease1)
            OR pat.patientunitstayid IN (SELECT patientunitstayid FROM included_disease2)
        )
)
--SELECT * FROM basic;

,
--糖尿病Diabetes
Diabetes AS(
    SELECT DISTINCT ON(patientunitstayid) diagnosisid,patientunitstayid,dia.diagnosisstring,icd9code,codeid,original_icdcode,FLAG
    FROM eicu_crd.diagnosis AS dia,
            (SELECT codeid,icd_code,original_icdcode,diagnosisstring,1 AS FLAG FROM dictionary.d_icd_diagnosis WHERE codeid in ('800091','800429','801220','800162','800732','800264','801496','800427','801497','800733','801221','800163','800430')) AS did
    WHERE True
            AND (CASE
                WHEN did.original_icdcode IS NULL THEN dia.diagnosisstring = did.diagnosisstring
                ELSE dia.icd9code LIKE CONCAT('%', did.original_icdcode, '%')
            END)
)
SELECT basic.patientunitstayid,
Diabetes.FLAG AS Diabetes
FROM basic 
LEFT JOIN Diabetes ON basic.patientunitstayid=Diabetes.patientunitstayid
ORDER BY  basic.patientunitstayid ASC
WITH 
basic AS (
    WITH
    --纳入的诊断
/*
传染病|胸部/肺部感染|肺炎
传染病|胸部/肺部感染|肺炎|机会感染
传染病|胸部/肺部感染|肺炎|机会感染|卡氏肺囊虫病
肺部|肺部感染|肺炎
肺|肺部感染|肺炎|机会性
肺|肺部感染|肺炎|机会性|肺孢子菌肺炎
infectious diseases|chest/pulmonary infections|pneumonia|opportunistic|PCP
pulmonary|pulmonary infections|pneumonia|opportunistic|PCP
*/
included_disease1 AS(
    SELECT DISTINCT ON(patientunitstayid) diagnosisid,patientunitstayid,dia.diagnosisstring,icd9code,codeid,original_icdcode 
    FROM eicu_crd.diagnosis AS dia,
            (SELECT codeid,icd_code,original_icdcode,diagnosisstring 
            FROM "dictionary".d_icd_diagnosis WHERE codeid in ('800912')
            ) AS did
    WHERE True
        AND (CASE
            WHEN did.original_icdcode IS NULL THEN dia.diagnosisstring = did.diagnosisstring
            ELSE dia.icd9code LIKE CONCAT('%', did.original_icdcode, '%')
        END)
),
/*
传染病|胸部/肺部感染|肺炎
传染病|胸部/肺部感染|肺炎|机会感染
传染病|胸部/肺部感染|肺炎|机会感染|卡氏肺囊虫病
肺部|肺部感染|肺炎
肺|肺部感染|肺炎|机会性
肺|肺部感染|肺炎|机会性|肺孢子菌肺炎
infectious diseases|chest/pulmonary infections|pneumonia|opportunistic|PCP
pulmonary|pulmonary infections|pneumonia|opportunistic|PCP
*/
included_disease2 AS(
    SELECT DISTINCT ON(patientunitstayid) diagnosisid,patientunitstayid,dia.diagnosisstring,icd9code,codeid,original_icdcode 
    FROM eicu_crd.diagnosis AS dia,
            (SELECT codeid,icd_code,original_icdcode,diagnosisstring 
            FROM "dictionary".d_icd_diagnosis WHERE codeid in ('800911')
            ) AS did
    WHERE True
        AND (CASE
            WHEN did.original_icdcode IS NULL THEN dia.diagnosisstring = did.diagnosisstring
            ELSE dia.icd9code LIKE CONCAT('%', did.original_icdcode, '%')
        END)
)
SELECT DISTINCT ON(pat.uniquepid) pat.patientunitstayid,pat.age,pat.gender,pat.uniquepid
FROM eicu_crd.patient AS pat
WHERE True
    AND pat.age BETWEEN '18' AND '99'
        --纳入诊断疾病
        AND (
            pat.patientunitstayid IN (SELECT patientunitstayid FROM included_disease1)
            OR pat.patientunitstayid IN (SELECT patientunitstayid FROM included_disease2)
        )
)
--SELECT * FROM basic;

,
--MACEMACE
MACE AS(
    SELECT DISTINCT ON(patientunitstayid) diagnosisid,patientunitstayid,dia.diagnosisstring,icd9code,codeid,original_icdcode,FLAG
    FROM eicu_crd.diagnosis AS dia,
            (SELECT codeid,icd_code,original_icdcode,diagnosisstring,1 AS FLAG FROM dictionary.d_icd_diagnosis WHERE codeid in ('800666','800684','800982','801947','800321','800663','801400','801155','800504','801193','800584','800680','800260','800323','800330','800393','800124','800836','800248','800635','800357','800524','800759','801355','800452','800492','801859','800681','800837','800261','800249','800322','801401','800505','800585','800358','800525','800125','800636','800667','800324','800331','800394','800760','801356','800453','800320')) AS did
    WHERE True
            AND (CASE
                WHEN did.original_icdcode IS NULL THEN dia.diagnosisstring = did.diagnosisstring
                ELSE dia.icd9code LIKE CONCAT('%', did.original_icdcode, '%')
            END)
)
SELECT basic.patientunitstayid,
MACE.FLAG AS MACE
FROM basic 
LEFT JOIN MACE ON basic.patientunitstayid=MACE.patientunitstayid
ORDER BY  basic.patientunitstayid ASC
WITH 
basic AS (

WITH 
basic AS (
    WITH
    --纳入的诊断
/*
传染病|胸部/肺部感染|肺炎
传染病|胸部/肺部感染|肺炎|机会感染
传染病|胸部/肺部感染|肺炎|机会感染|卡氏肺囊虫病
肺部|肺部感染|肺炎
肺|肺部感染|肺炎|机会性
肺|肺部感染|肺炎|机会性|肺孢子菌肺炎
infectious diseases|chest/pulmonary infections|pneumonia|opportunistic|PCP
pulmonary|pulmonary infections|pneumonia|opportunistic|PCP
*/
included_disease1 AS(
    SELECT DISTINCT ON(patientunitstayid) diagnosisid,patientunitstayid,dia.diagnosisstring,icd9code,codeid,original_icdcode 
    FROM eicu_crd.diagnosis AS dia,
            (SELECT codeid,icd_code,original_icdcode,diagnosisstring 
            FROM "dictionary".d_icd_diagnosis WHERE codeid in ('800912')
            ) AS did
    WHERE True
        AND (CASE
            WHEN did.original_icdcode IS NULL THEN dia.diagnosisstring = did.diagnosisstring
            ELSE dia.icd9code LIKE CONCAT('%', did.original_icdcode, '%')
        END)
),
/*
传染病|胸部/肺部感染|肺炎
传染病|胸部/肺部感染|肺炎|机会感染
传染病|胸部/肺部感染|肺炎|机会感染|卡氏肺囊虫病
肺部|肺部感染|肺炎
肺|肺部感染|肺炎|机会性
肺|肺部感染|肺炎|机会性|肺孢子菌肺炎
infectious diseases|chest/pulmonary infections|pneumonia|opportunistic|PCP
pulmonary|pulmonary infections|pneumonia|opportunistic|PCP
*/
included_disease2 AS(
    SELECT DISTINCT ON(patientunitstayid) diagnosisid,patientunitstayid,dia.diagnosisstring,icd9code,codeid,original_icdcode 
    FROM eicu_crd.diagnosis AS dia,
            (SELECT codeid,icd_code,original_icdcode,diagnosisstring 
            FROM "dictionary".d_icd_diagnosis WHERE codeid in ('800911')
            ) AS did
    WHERE True
        AND (CASE
            WHEN did.original_icdcode IS NULL THEN dia.diagnosisstring = did.diagnosisstring
            ELSE dia.icd9code LIKE CONCAT('%', did.original_icdcode, '%')
        END)
)
SELECT DISTINCT ON(pat.uniquepid) pat.patientunitstayid,pat.age,pat.gender,pat.uniquepid
FROM eicu_crd.patient AS pat
WHERE True
    AND pat.age BETWEEN '18' AND '99'
        --纳入诊断疾病
        AND (
            pat.patientunitstayid IN (SELECT patientunitstayid FROM included_disease1)
            OR pat.patientunitstayid IN (SELECT patientunitstayid FROM included_disease2)
        )
)
--SELECT * FROM basic;

,
--ganliver
liver AS(
    SELECT DISTINCT ON(patientunitstayid) diagnosisid,patientunitstayid,dia.diagnosisstring,icd9code,codeid,original_icdcode,FLAG
    FROM eicu_crd.diagnosis AS dia,
            (SELECT codeid,icd_code,original_icdcode,diagnosisstring,1 AS FLAG FROM dictionary.d_icd_diagnosis WHERE codeid in ('800675','800342','800506','801389','800652','800509','800602','801581','801967','800676','800343','800507','800752','801966','800510')) AS did
    WHERE True
            AND (CASE
                WHEN did.original_icdcode IS NULL THEN dia.diagnosisstring = did.diagnosisstring
                ELSE dia.icd9code LIKE CONCAT('%', did.original_icdcode, '%')
            END)
)
SELECT basic.patientunitstayid,
liver.FLAG AS liver
FROM basic 
LEFT JOIN liver ON basic.patientunitstayid=liver.patientunitstayid
ORDER BY  basic.patientunitstayid ASC

WITH 
basic AS (
    WITH
    --纳入的诊断
/*
传染病|胸部/肺部感染|肺炎
传染病|胸部/肺部感染|肺炎|机会感染
传染病|胸部/肺部感染|肺炎|机会感染|卡氏肺囊虫病
肺部|肺部感染|肺炎
肺|肺部感染|肺炎|机会性
肺|肺部感染|肺炎|机会性|肺孢子菌肺炎
infectious diseases|chest/pulmonary infections|pneumonia|opportunistic|PCP
pulmonary|pulmonary infections|pneumonia|opportunistic|PCP
*/
included_disease1 AS(
    SELECT DISTINCT ON(patientunitstayid) diagnosisid,patientunitstayid,dia.diagnosisstring,icd9code,codeid,original_icdcode 
    FROM eicu_crd.diagnosis AS dia,
            (SELECT codeid,icd_code,original_icdcode,diagnosisstring 
            FROM "dictionary".d_icd_diagnosis WHERE codeid in ('800912')
            ) AS did
    WHERE True
        AND (CASE
            WHEN did.original_icdcode IS NULL THEN dia.diagnosisstring = did.diagnosisstring
            ELSE dia.icd9code LIKE CONCAT('%', did.original_icdcode, '%')
        END)
),
/*
传染病|胸部/肺部感染|肺炎
传染病|胸部/肺部感染|肺炎|机会感染
传染病|胸部/肺部感染|肺炎|机会感染|卡氏肺囊虫病
肺部|肺部感染|肺炎
肺|肺部感染|肺炎|机会性
肺|肺部感染|肺炎|机会性|肺孢子菌肺炎
infectious diseases|chest/pulmonary infections|pneumonia|opportunistic|PCP
pulmonary|pulmonary infections|pneumonia|opportunistic|PCP
*/
included_disease2 AS(
    SELECT DISTINCT ON(patientunitstayid) diagnosisid,patientunitstayid,dia.diagnosisstring,icd9code,codeid,original_icdcode 
    FROM eicu_crd.diagnosis AS dia,
            (SELECT codeid,icd_code,original_icdcode,diagnosisstring 
            FROM "dictionary".d_icd_diagnosis WHERE codeid in ('800911')
            ) AS did
    WHERE True
        AND (CASE
            WHEN did.original_icdcode IS NULL THEN dia.diagnosisstring = did.diagnosisstring
            ELSE dia.icd9code LIKE CONCAT('%', did.original_icdcode, '%')
        END)
)
SELECT DISTINCT ON(pat.uniquepid) pat.patientunitstayid,pat.age,pat.gender,pat.uniquepid
FROM eicu_crd.patient AS pat
WHERE True
    AND pat.age BETWEEN '18' AND '99'
        --纳入诊断疾病
        AND (
            pat.patientunitstayid IN (SELECT patientunitstayid FROM included_disease1)
            OR pat.patientunitstayid IN (SELECT patientunitstayid FROM included_disease2)
        )
)
--SELECT * FROM basic;

,
--SHENRenal
Renal AS(
    SELECT DISTINCT ON(patientunitstayid) diagnosisid,patientunitstayid,dia.diagnosisstring,icd9code,codeid,original_icdcode,FLAG
    FROM eicu_crd.diagnosis AS dia,
            (SELECT codeid,icd_code,original_icdcode,diagnosisstring,1 AS FLAG FROM dictionary.d_icd_diagnosis WHERE codeid in ('801039','801033','800117','800312','800973','800270','801816','801040','801034','800118','800313','800974','800271')) AS did
    WHERE True
            AND (CASE
                WHEN did.original_icdcode IS NULL THEN dia.diagnosisstring = did.diagnosisstring
                ELSE dia.icd9code LIKE CONCAT('%', did.original_icdcode, '%')
            END)
)
SELECT basic.patientunitstayid,
Renal.FLAG AS Renal
FROM basic 
LEFT JOIN Renal ON basic.patientunitstayid=Renal.patientunitstayid
ORDER BY  basic.patientunitstayid ASC

WITH 
basic AS (
    WITH
    --纳入的诊断
/*
传染病|胸部/肺部感染|肺炎
传染病|胸部/肺部感染|肺炎|机会感染
传染病|胸部/肺部感染|肺炎|机会感染|卡氏肺囊虫病
肺部|肺部感染|肺炎
肺|肺部感染|肺炎|机会性
肺|肺部感染|肺炎|机会性|肺孢子菌肺炎
infectious diseases|chest/pulmonary infections|pneumonia|opportunistic|PCP
pulmonary|pulmonary infections|pneumonia|opportunistic|PCP
*/
included_disease1 AS(
    SELECT DISTINCT ON(patientunitstayid) diagnosisid,patientunitstayid,dia.diagnosisstring,icd9code,codeid,original_icdcode 
    FROM eicu_crd.diagnosis AS dia,
            (SELECT codeid,icd_code,original_icdcode,diagnosisstring 
            FROM "dictionary".d_icd_diagnosis WHERE codeid in ('800912')
            ) AS did
    WHERE True
        AND (CASE
            WHEN did.original_icdcode IS NULL THEN dia.diagnosisstring = did.diagnosisstring
            ELSE dia.icd9code LIKE CONCAT('%', did.original_icdcode, '%')
        END)
),
/*
传染病|胸部/肺部感染|肺炎
传染病|胸部/肺部感染|肺炎|机会感染
传染病|胸部/肺部感染|肺炎|机会感染|卡氏肺囊虫病
肺部|肺部感染|肺炎
肺|肺部感染|肺炎|机会性
肺|肺部感染|肺炎|机会性|肺孢子菌肺炎
infectious diseases|chest/pulmonary infections|pneumonia|opportunistic|PCP
pulmonary|pulmonary infections|pneumonia|opportunistic|PCP
*/
included_disease2 AS(
    SELECT DISTINCT ON(patientunitstayid) diagnosisid,patientunitstayid,dia.diagnosisstring,icd9code,codeid,original_icdcode 
    FROM eicu_crd.diagnosis AS dia,
            (SELECT codeid,icd_code,original_icdcode,diagnosisstring 
            FROM "dictionary".d_icd_diagnosis WHERE codeid in ('800911')
            ) AS did
    WHERE True
        AND (CASE
            WHEN did.original_icdcode IS NULL THEN dia.diagnosisstring = did.diagnosisstring
            ELSE dia.icd9code LIKE CONCAT('%', did.original_icdcode, '%')
        END)
)
SELECT DISTINCT ON(pat.uniquepid) pat.patientunitstayid,pat.age,pat.gender,pat.uniquepid
FROM eicu_crd.patient AS pat
WHERE True
    AND pat.age BETWEEN '18' AND '99'
        --纳入诊断疾病
        AND (
            pat.patientunitstayid IN (SELECT patientunitstayid FROM included_disease1)
            OR pat.patientunitstayid IN (SELECT patientunitstayid FROM included_disease2)
        )
)
--SELECT * FROM basic;

,
--FEI pulmonary
 pulmonary AS(
    SELECT DISTINCT ON(patientunitstayid) diagnosisid,patientunitstayid,dia.diagnosisstring,icd9code,codeid,original_icdcode,FLAG
    FROM eicu_crd.diagnosis AS dia,
            (SELECT codeid,icd_code,original_icdcode,diagnosisstring,1 AS FLAG FROM dictionary.d_icd_diagnosis WHERE codeid in ('800070','800108','801176','801177','800109','800071')) AS did
    WHERE True
            AND (CASE
                WHEN did.original_icdcode IS NULL THEN dia.diagnosisstring = did.diagnosisstring
                ELSE dia.icd9code LIKE CONCAT('%', did.original_icdcode, '%')
            END)
)
SELECT basic.patientunitstayid,
 pulmonary.FLAG AS  pulmonary
FROM basic 
LEFT JOIN  pulmonary ON basic.patientunitstayid= pulmonary.patientunitstayid
ORDER BY  basic.patientunitstayid ASC
WITH 
basic AS (
    WITH
    --纳入的诊断
/*
传染病|胸部/肺部感染|肺炎
传染病|胸部/肺部感染|肺炎|机会感染
传染病|胸部/肺部感染|肺炎|机会感染|卡氏肺囊虫病
肺部|肺部感染|肺炎
肺|肺部感染|肺炎|机会性
肺|肺部感染|肺炎|机会性|肺孢子菌肺炎
infectious diseases|chest/pulmonary infections|pneumonia|opportunistic|PCP
pulmonary|pulmonary infections|pneumonia|opportunistic|PCP
*/
included_disease1 AS(
    SELECT DISTINCT ON(patientunitstayid) diagnosisid,patientunitstayid,dia.diagnosisstring,icd9code,codeid,original_icdcode 
    FROM eicu_crd.diagnosis AS dia,
            (SELECT codeid,icd_code,original_icdcode,diagnosisstring 
            FROM "dictionary".d_icd_diagnosis WHERE codeid in ('800912')
            ) AS did
    WHERE True
        AND (CASE
            WHEN did.original_icdcode IS NULL THEN dia.diagnosisstring = did.diagnosisstring
            ELSE dia.icd9code LIKE CONCAT('%', did.original_icdcode, '%')
        END)
),
/*
传染病|胸部/肺部感染|肺炎
传染病|胸部/肺部感染|肺炎|机会感染
传染病|胸部/肺部感染|肺炎|机会感染|卡氏肺囊虫病
肺部|肺部感染|肺炎
肺|肺部感染|肺炎|机会性
肺|肺部感染|肺炎|机会性|肺孢子菌肺炎
infectious diseases|chest/pulmonary infections|pneumonia|opportunistic|PCP
pulmonary|pulmonary infections|pneumonia|opportunistic|PCP
*/
included_disease2 AS(
    SELECT DISTINCT ON(patientunitstayid) diagnosisid,patientunitstayid,dia.diagnosisstring,icd9code,codeid,original_icdcode 
    FROM eicu_crd.diagnosis AS dia,
            (SELECT codeid,icd_code,original_icdcode,diagnosisstring 
            FROM "dictionary".d_icd_diagnosis WHERE codeid in ('800911')
            ) AS did
    WHERE True
        AND (CASE
            WHEN did.original_icdcode IS NULL THEN dia.diagnosisstring = did.diagnosisstring
            ELSE dia.icd9code LIKE CONCAT('%', did.original_icdcode, '%')
        END)
)
SELECT DISTINCT ON(pat.uniquepid) pat.patientunitstayid,pat.age,pat.gender,pat.uniquepid
FROM eicu_crd.patient AS pat
WHERE True
    AND pat.age BETWEEN '18' AND '99'
        --纳入诊断疾病
        AND (
            pat.patientunitstayid IN (SELECT patientunitstayid FROM included_disease1)
            OR pat.patientunitstayid IN (SELECT patientunitstayid FROM included_disease2)
        )
)
--SELECT * FROM basic;

,
--AIMalignant
Malignant AS(
    SELECT DISTINCT ON(patientunitstayid) diagnosisid,patientunitstayid,dia.diagnosisstring,icd9code,codeid,original_icdcode,FLAG
    FROM eicu_crd.diagnosis AS dia,
            (SELECT codeid,icd_code,original_icdcode,diagnosisstring,1 AS FLAG FROM dictionary.d_icd_diagnosis WHERE codeid in ('801633','800158','800454','800578','801035','800545','801329','801099','800519','801684','801991','800695','800739','801593','801253','800520','801685','800132','801272','801304','801735','800515','802461','800778','800600','801186','800682','801969','800728','800735','801460','800787','802208','800694','801992','800696','800915','802336','801110','801406','802364','800740','801594','801036','801017','801123','801227','801228','802409','801379','801386','801302','801540','801723','801563','801582','801584','800088','801509','801643','801599','801100','801855','801091','800572','800336','801491','801598','801303','801734','801697','801620','800777','801185','801109','801405','801459','800693','800364','800741','801113','802150','800340','800766','800378','800576','801958','801197','801052','800688','801121','802313','800174','801320','800351','802107','801288','801611','801038','800583','800692','800579','801330','801934','802187','801037','800413','802108','800407','801456','800365','800742','801114','800542','802151','800341','801634','800767','800159','800379','800577','801959','801053','801198','800547','800689','801122','802314','800455','800240','801289','801612','801254','801273','801856','801092','800812','800573','800337','801621','801492','800239')) AS did
    WHERE True
            AND (CASE
                WHEN did.original_icdcode IS NULL THEN dia.diagnosisstring = did.diagnosisstring
                ELSE dia.icd9code LIKE CONCAT('%', did.original_icdcode, '%')
            END)
)
SELECT basic.patientunitstayid,
Malignant.FLAG AS Malignant
FROM basic 
LEFT JOIN Malignant ON basic.patientunitstayid=Malignant.patientunitstayid
ORDER BY  basic.patientunitstayid ASC
WITH 
basic AS (
    WITH
    --纳入的诊断
/*
传染病|胸部/肺部感染|肺炎
传染病|胸部/肺部感染|肺炎|机会感染
传染病|胸部/肺部感染|肺炎|机会感染|卡氏肺囊虫病
肺部|肺部感染|肺炎
肺|肺部感染|肺炎|机会性
肺|肺部感染|肺炎|机会性|肺孢子菌肺炎
infectious diseases|chest/pulmonary infections|pneumonia|opportunistic|PCP
pulmonary|pulmonary infections|pneumonia|opportunistic|PCP
*/
included_disease1 AS(
    SELECT DISTINCT ON(patientunitstayid) diagnosisid,patientunitstayid,dia.diagnosisstring,icd9code,codeid,original_icdcode 
    FROM eicu_crd.diagnosis AS dia,
            (SELECT codeid,icd_code,original_icdcode,diagnosisstring 
            FROM "dictionary".d_icd_diagnosis WHERE codeid in ('800912')
            ) AS did
    WHERE True
        AND (CASE
            WHEN did.original_icdcode IS NULL THEN dia.diagnosisstring = did.diagnosisstring
            ELSE dia.icd9code LIKE CONCAT('%', did.original_icdcode, '%')
        END)
),
/*
传染病|胸部/肺部感染|肺炎
传染病|胸部/肺部感染|肺炎|机会感染
传染病|胸部/肺部感染|肺炎|机会感染|卡氏肺囊虫病
肺部|肺部感染|肺炎
肺|肺部感染|肺炎|机会性
肺|肺部感染|肺炎|机会性|肺孢子菌肺炎
infectious diseases|chest/pulmonary infections|pneumonia|opportunistic|PCP
pulmonary|pulmonary infections|pneumonia|opportunistic|PCP
*/
included_disease2 AS(
    SELECT DISTINCT ON(patientunitstayid) diagnosisid,patientunitstayid,dia.diagnosisstring,icd9code,codeid,original_icdcode 
    FROM eicu_crd.diagnosis AS dia,
            (SELECT codeid,icd_code,original_icdcode,diagnosisstring 
            FROM "dictionary".d_icd_diagnosis WHERE codeid in ('800911')
            ) AS did
    WHERE True
        AND (CASE
            WHEN did.original_icdcode IS NULL THEN dia.diagnosisstring = did.diagnosisstring
            ELSE dia.icd9code LIKE CONCAT('%', did.original_icdcode, '%')
        END)
)
SELECT DISTINCT ON(pat.uniquepid) pat.patientunitstayid,pat.age,pat.gender,pat.uniquepid
FROM eicu_crd.patient AS pat
WHERE True
    AND pat.age BETWEEN '18' AND '99'
        --纳入诊断疾病
        AND (
            pat.patientunitstayid IN (SELECT patientunitstayid FROM included_disease1)
            OR pat.patientunitstayid IN (SELECT patientunitstayid FROM included_disease2)
        )
)
--SELECT * FROM basic;

,
--YIZHItransplant
transplant AS(
    SELECT DISTINCT ON(patientunitstayid) diagnosisid,patientunitstayid,dia.diagnosisstring,icd9code,codeid,original_icdcode,FLAG
    FROM eicu_crd.diagnosis AS dia,
            (SELECT codeid,icd_code,original_icdcode,diagnosisstring,1 AS FLAG FROM dictionary.d_icd_diagnosis WHERE codeid in ('801950','800570','800748','801894','801880','801251','800826','800957','801203','800956','801202')) AS did
    WHERE True
            AND (CASE
                WHEN did.original_icdcode IS NULL THEN dia.diagnosisstring = did.diagnosisstring
                ELSE dia.icd9code LIKE CONCAT('%', did.original_icdcode, '%')
            END)
)
SELECT basic.patientunitstayid,
transplant.FLAG AS transplant
FROM basic 
LEFT JOIN transplant ON basic.patientunitstayid=transplant.patientunitstayid
ORDER BY  basic.patientunitstayid ASC
WITH 
basic AS (
    WITH
    --纳入的诊断
/*
传染病|胸部/肺部感染|肺炎
传染病|胸部/肺部感染|肺炎|机会感染
传染病|胸部/肺部感染|肺炎|机会感染|卡氏肺囊虫病
肺部|肺部感染|肺炎
肺|肺部感染|肺炎|机会性
肺|肺部感染|肺炎|机会性|肺孢子菌肺炎
infectious diseases|chest/pulmonary infections|pneumonia|opportunistic|PCP
pulmonary|pulmonary infections|pneumonia|opportunistic|PCP
*/
included_disease1 AS(
    SELECT DISTINCT ON(patientunitstayid) diagnosisid,patientunitstayid,dia.diagnosisstring,icd9code,codeid,original_icdcode 
    FROM eicu_crd.diagnosis AS dia,
            (SELECT codeid,icd_code,original_icdcode,diagnosisstring 
            FROM "dictionary".d_icd_diagnosis WHERE codeid in ('800912')
            ) AS did
    WHERE True
        AND (CASE
            WHEN did.original_icdcode IS NULL THEN dia.diagnosisstring = did.diagnosisstring
            ELSE dia.icd9code LIKE CONCAT('%', did.original_icdcode, '%')
        END)
),
/*
传染病|胸部/肺部感染|肺炎
传染病|胸部/肺部感染|肺炎|机会感染
传染病|胸部/肺部感染|肺炎|机会感染|卡氏肺囊虫病
肺部|肺部感染|肺炎
肺|肺部感染|肺炎|机会性
肺|肺部感染|肺炎|机会性|肺孢子菌肺炎
infectious diseases|chest/pulmonary infections|pneumonia|opportunistic|PCP
pulmonary|pulmonary infections|pneumonia|opportunistic|PCP
*/
included_disease2 AS(
    SELECT DISTINCT ON(patientunitstayid) diagnosisid,patientunitstayid,dia.diagnosisstring,icd9code,codeid,original_icdcode 
    FROM eicu_crd.diagnosis AS dia,
            (SELECT codeid,icd_code,original_icdcode,diagnosisstring 
            FROM "dictionary".d_icd_diagnosis WHERE codeid in ('800911')
            ) AS did
    WHERE True
        AND (CASE
            WHEN did.original_icdcode IS NULL THEN dia.diagnosisstring = did.diagnosisstring
            ELSE dia.icd9code LIKE CONCAT('%', did.original_icdcode, '%')
        END)
)
SELECT DISTINCT ON(pat.uniquepid) pat.patientunitstayid,pat.age,pat.gender,pat.uniquepid
FROM eicu_crd.patient AS pat
WHERE True
    AND pat.age BETWEEN '18' AND '99'
        --纳入诊断疾病
        AND (
            pat.patientunitstayid IN (SELECT patientunitstayid FROM included_disease1)
            OR pat.patientunitstayid IN (SELECT patientunitstayid FROM included_disease2)
        )
)
--SELECT * FROM basic;

,
--HIVHIV
HIV AS(
    SELECT DISTINCT ON(patientunitstayid) diagnosisid,patientunitstayid,dia.diagnosisstring,icd9code,codeid,original_icdcode,FLAG
    FROM eicu_crd.diagnosis AS dia,
            (SELECT codeid,icd_code,original_icdcode,diagnosisstring,1 AS FLAG FROM dictionary.d_icd_diagnosis WHERE codeid in ('801204','801205','800233','800234')) AS did
    WHERE True
            AND (CASE
                WHEN did.original_icdcode IS NULL THEN dia.diagnosisstring = did.diagnosisstring
                ELSE dia.icd9code LIKE CONCAT('%', did.original_icdcode, '%')
            END)
)
SELECT basic.patientunitstayid,
HIV.FLAG AS HIV
FROM basic 
LEFT JOIN HIV ON basic.patientunitstayid=HIV.patientunitstayid
ORDER BY  basic.patientunitstayid ASC
WITH 
basic AS (
    WITH
    --纳入的诊断
/*
传染病|胸部/肺部感染|肺炎
传染病|胸部/肺部感染|肺炎|机会感染
传染病|胸部/肺部感染|肺炎|机会感染|卡氏肺囊虫病
肺部|肺部感染|肺炎
肺|肺部感染|肺炎|机会性
肺|肺部感染|肺炎|机会性|肺孢子菌肺炎
infectious diseases|chest/pulmonary infections|pneumonia|opportunistic|PCP
pulmonary|pulmonary infections|pneumonia|opportunistic|PCP
*/
included_disease1 AS(
    SELECT DISTINCT ON(patientunitstayid) diagnosisid,patientunitstayid,dia.diagnosisstring,icd9code,codeid,original_icdcode 
    FROM eicu_crd.diagnosis AS dia,
            (SELECT codeid,icd_code,original_icdcode,diagnosisstring 
            FROM "dictionary".d_icd_diagnosis WHERE codeid in ('800912')
            ) AS did
    WHERE True
        AND (CASE
            WHEN did.original_icdcode IS NULL THEN dia.diagnosisstring = did.diagnosisstring
            ELSE dia.icd9code LIKE CONCAT('%', did.original_icdcode, '%')
        END)
),
/*
传染病|胸部/肺部感染|肺炎
传染病|胸部/肺部感染|肺炎|机会感染
传染病|胸部/肺部感染|肺炎|机会感染|卡氏肺囊虫病
肺部|肺部感染|肺炎
肺|肺部感染|肺炎|机会性
肺|肺部感染|肺炎|机会性|肺孢子菌肺炎
infectious diseases|chest/pulmonary infections|pneumonia|opportunistic|PCP
pulmonary|pulmonary infections|pneumonia|opportunistic|PCP
*/
included_disease2 AS(
    SELECT DISTINCT ON(patientunitstayid) diagnosisid,patientunitstayid,dia.diagnosisstring,icd9code,codeid,original_icdcode 
    FROM eicu_crd.diagnosis AS dia,
            (SELECT codeid,icd_code,original_icdcode,diagnosisstring 
            FROM "dictionary".d_icd_diagnosis WHERE codeid in ('800911')
            ) AS did
    WHERE True
        AND (CASE
            WHEN did.original_icdcode IS NULL THEN dia.diagnosisstring = did.diagnosisstring
            ELSE dia.icd9code LIKE CONCAT('%', did.original_icdcode, '%')
        END)
)
SELECT DISTINCT ON(pat.uniquepid) pat.patientunitstayid,pat.age,pat.gender,pat.uniquepid
FROM eicu_crd.patient AS pat
WHERE True
    AND pat.age BETWEEN '18' AND '99'
        --纳入诊断疾病
        AND (
            pat.patientunitstayid IN (SELECT patientunitstayid FROM included_disease1)
            OR pat.patientunitstayid IN (SELECT patientunitstayid FROM included_disease2)
        )
)
--SELECT * FROM basic;

,
--CMVCMV
CMV AS(
    SELECT DISTINCT ON(patientunitstayid) diagnosisid,patientunitstayid,dia.diagnosisstring,icd9code,codeid,original_icdcode,FLAG
    FROM eicu_crd.diagnosis AS dia,
            (SELECT codeid,icd_code,original_icdcode,diagnosisstring,1 AS FLAG FROM dictionary.d_icd_diagnosis WHERE codeid in ('801552','801551','801553','802064','802236')) AS did
    WHERE True
            AND (CASE
                WHEN did.original_icdcode IS NULL THEN dia.diagnosisstring = did.diagnosisstring
                ELSE dia.icd9code LIKE CONCAT('%', did.original_icdcode, '%')
            END)
)
SELECT basic.patientunitstayid,
CMV.FLAG AS CMV
FROM basic 
LEFT JOIN CMV ON basic.patientunitstayid=CMV.patientunitstayid
ORDER BY  basic.patientunitstayid ASC
WITH 
basic AS (
    WITH
    --纳入的诊断
/*
传染病|胸部/肺部感染|肺炎
传染病|胸部/肺部感染|肺炎|机会感染
传染病|胸部/肺部感染|肺炎|机会感染|卡氏肺囊虫病
肺部|肺部感染|肺炎
肺|肺部感染|肺炎|机会性
肺|肺部感染|肺炎|机会性|肺孢子菌肺炎
infectious diseases|chest/pulmonary infections|pneumonia|opportunistic|PCP
pulmonary|pulmonary infections|pneumonia|opportunistic|PCP
*/
included_disease1 AS(
    SELECT DISTINCT ON(patientunitstayid) diagnosisid,patientunitstayid,dia.diagnosisstring,icd9code,codeid,original_icdcode 
    FROM eicu_crd.diagnosis AS dia,
            (SELECT codeid,icd_code,original_icdcode,diagnosisstring 
            FROM "dictionary".d_icd_diagnosis WHERE codeid in ('800912')
            ) AS did
    WHERE True
        AND (CASE
            WHEN did.original_icdcode IS NULL THEN dia.diagnosisstring = did.diagnosisstring
            ELSE dia.icd9code LIKE CONCAT('%', did.original_icdcode, '%')
        END)
),
/*
传染病|胸部/肺部感染|肺炎
传染病|胸部/肺部感染|肺炎|机会感染
传染病|胸部/肺部感染|肺炎|机会感染|卡氏肺囊虫病
肺部|肺部感染|肺炎
肺|肺部感染|肺炎|机会性
肺|肺部感染|肺炎|机会性|肺孢子菌肺炎
infectious diseases|chest/pulmonary infections|pneumonia|opportunistic|PCP
pulmonary|pulmonary infections|pneumonia|opportunistic|PCP
*/
included_disease2 AS(
    SELECT DISTINCT ON(patientunitstayid) diagnosisid,patientunitstayid,dia.diagnosisstring,icd9code,codeid,original_icdcode 
    FROM eicu_crd.diagnosis AS dia,
            (SELECT codeid,icd_code,original_icdcode,diagnosisstring 
            FROM "dictionary".d_icd_diagnosis WHERE codeid in ('800911')
            ) AS did
    WHERE True
        AND (CASE
            WHEN did.original_icdcode IS NULL THEN dia.diagnosisstring = did.diagnosisstring
            ELSE dia.icd9code LIKE CONCAT('%', did.original_icdcode, '%')
        END)
)
SELECT DISTINCT ON(pat.uniquepid) pat.patientunitstayid,pat.age,pat.gender,pat.uniquepid
FROM eicu_crd.patient AS pat
WHERE True
    AND pat.age BETWEEN '18' AND '99'
        --纳入诊断疾病
        AND (
            pat.patientunitstayid IN (SELECT patientunitstayid FROM included_disease1)
            OR pat.patientunitstayid IN (SELECT patientunitstayid FROM included_disease2)
        )
)
--SELECT * FROM basic;

,
--Glu JISU
Glu AS
(SELECT DISTINCT ON(medication.patientunitstayid) patientunitstayid,1 AS FLAG,drugstartoffset,drugorderoffset
FROM eicu_crd.medication
WHERE TRUE

    AND drugnameid in ('300436','300437','300438','300439','300678','300679','300680','300681','300890','300891','300892','300893','300894','300895','300896','300897','300029','301188','301189','301190','301191','301192','301193','301194','301195')
)
SELECT basic.patientunitstayid,
Glu.flag AS Glu,
Glu.drugstartoffset AS Glu_drugstartoffset,
Glu.drugorderoffset AS Glu_drugorderoffset
FROM basic 
LEFT JOIN Glu ON basic.patientunitstayid=Glu.patientunitstayid
WITH 
basic AS (
    WITH
    --纳入的诊断
/*
传染病|胸部/肺部感染|肺炎
传染病|胸部/肺部感染|肺炎|机会感染
传染病|胸部/肺部感染|肺炎|机会感染|卡氏肺囊虫病
肺部|肺部感染|肺炎
肺|肺部感染|肺炎|机会性
肺|肺部感染|肺炎|机会性|肺孢子菌肺炎
infectious diseases|chest/pulmonary infections|pneumonia|opportunistic|PCP
pulmonary|pulmonary infections|pneumonia|opportunistic|PCP
*/
included_disease1 AS(
    SELECT DISTINCT ON(patientunitstayid) diagnosisid,patientunitstayid,dia.diagnosisstring,icd9code,codeid,original_icdcode 
    FROM eicu_crd.diagnosis AS dia,
            (SELECT codeid,icd_code,original_icdcode,diagnosisstring 
            FROM "dictionary".d_icd_diagnosis WHERE codeid in ('800912')
            ) AS did
    WHERE True
        AND (CASE
            WHEN did.original_icdcode IS NULL THEN dia.diagnosisstring = did.diagnosisstring
            ELSE dia.icd9code LIKE CONCAT('%', did.original_icdcode, '%')
        END)
),
/*
传染病|胸部/肺部感染|肺炎
传染病|胸部/肺部感染|肺炎|机会感染
传染病|胸部/肺部感染|肺炎|机会感染|卡氏肺囊虫病
肺部|肺部感染|肺炎
肺|肺部感染|肺炎|机会性
肺|肺部感染|肺炎|机会性|肺孢子菌肺炎
infectious diseases|chest/pulmonary infections|pneumonia|opportunistic|PCP
pulmonary|pulmonary infections|pneumonia|opportunistic|PCP
*/
included_disease2 AS(
    SELECT DISTINCT ON(patientunitstayid) diagnosisid,patientunitstayid,dia.diagnosisstring,icd9code,codeid,original_icdcode 
    FROM eicu_crd.diagnosis AS dia,
            (SELECT codeid,icd_code,original_icdcode,diagnosisstring 
            FROM "dictionary".d_icd_diagnosis WHERE codeid in ('800911')
            ) AS did
    WHERE True
        AND (CASE
            WHEN did.original_icdcode IS NULL THEN dia.diagnosisstring = did.diagnosisstring
            ELSE dia.icd9code LIKE CONCAT('%', did.original_icdcode, '%')
        END)
)
SELECT DISTINCT ON(pat.uniquepid) pat.patientunitstayid,pat.age,pat.gender,pat.uniquepid
FROM eicu_crd.patient AS pat
WHERE True
    AND pat.age BETWEEN '18' AND '99'
        --纳入诊断疾病
        AND (
            pat.patientunitstayid IN (SELECT patientunitstayid FROM included_disease1)
            OR pat.patientunitstayid IN (SELECT patientunitstayid FROM included_disease2)
        )
)
--SELECT * FROM basic;

,
--Vasopressor 血管活性药物（升压药）
Vasopressor AS
(SELECT DISTINCT ON(medication.patientunitstayid) patientunitstayid,1 AS FLAG,drugstartoffset,drugorderoffset
FROM eicu_crd.medication
WHERE TRUE

    AND drugnameid in ('300001','300130','300140','300166','300352','300509','300528','300529','300803','300804','300805','300806','300807','300808','300809','300810','300811','300812','300813','301018','301019','301020','301021','301022','301023','301024','301025','301103','301104','301105','301106','301107','301108','301198','301376')
    AND drugstartoffset >0
)
SELECT basic.patientunitstayid,
Vasopressor.flag AS Vasopressor,
Vasopressor.drugstartoffset AS Vasopressor_drugstartoffset,
Vasopressor.drugorderoffset AS Vasopressor_drugorderoffset
FROM basic 
LEFT JOIN Vasopressor ON basic.patientunitstayid=Vasopressor.patientunitstayid
WITH 
basic AS (
    WITH
    --纳入的诊断
/*
传染病|胸部/肺部感染|肺炎
传染病|胸部/肺部感染|肺炎|机会感染
传染病|胸部/肺部感染|肺炎|机会感染|卡氏肺囊虫病
肺部|肺部感染|肺炎
肺|肺部感染|肺炎|机会性
肺|肺部感染|肺炎|机会性|肺孢子菌肺炎
infectious diseases|chest/pulmonary infections|pneumonia|opportunistic|PCP
pulmonary|pulmonary infections|pneumonia|opportunistic|PCP
*/
included_disease1 AS(
    SELECT DISTINCT ON(patientunitstayid) diagnosisid,patientunitstayid,dia.diagnosisstring,icd9code,codeid,original_icdcode 
    FROM eicu_crd.diagnosis AS dia,
            (SELECT codeid,icd_code,original_icdcode,diagnosisstring 
            FROM "dictionary".d_icd_diagnosis WHERE codeid in ('800912')
            ) AS did
    WHERE True
        AND (CASE
            WHEN did.original_icdcode IS NULL THEN dia.diagnosisstring = did.diagnosisstring
            ELSE dia.icd9code LIKE CONCAT('%', did.original_icdcode, '%')
        END)
),
/*
传染病|胸部/肺部感染|肺炎
传染病|胸部/肺部感染|肺炎|机会感染
传染病|胸部/肺部感染|肺炎|机会感染|卡氏肺囊虫病
肺部|肺部感染|肺炎
肺|肺部感染|肺炎|机会性
肺|肺部感染|肺炎|机会性|肺孢子菌肺炎
infectious diseases|chest/pulmonary infections|pneumonia|opportunistic|PCP
pulmonary|pulmonary infections|pneumonia|opportunistic|PCP
*/
included_disease2 AS(
    SELECT DISTINCT ON(patientunitstayid) diagnosisid,patientunitstayid,dia.diagnosisstring,icd9code,codeid,original_icdcode 
    FROM eicu_crd.diagnosis AS dia,
            (SELECT codeid,icd_code,original_icdcode,diagnosisstring 
            FROM "dictionary".d_icd_diagnosis WHERE codeid in ('800911')
            ) AS did
    WHERE True
        AND (CASE
            WHEN did.original_icdcode IS NULL THEN dia.diagnosisstring = did.diagnosisstring
            ELSE dia.icd9code LIKE CONCAT('%', did.original_icdcode, '%')
        END)
)
SELECT DISTINCT ON(pat.uniquepid) pat.patientunitstayid,pat.age,pat.gender,pat.uniquepid
FROM eicu_crd.patient AS pat
WHERE True
    AND pat.age BETWEEN '18' AND '99'
        --纳入诊断疾病
        AND (
            pat.patientunitstayid IN (SELECT patientunitstayid FROM included_disease1)
            OR pat.patientunitstayid IN (SELECT patientunitstayid FROM included_disease2)
        )
)
--SELECT * FROM basic;

SELECT b.*, 
       resp.ventilation, 
       resp.ventilation_first_time
FROM basic b
LEFT JOIN (
    SELECT rc.patientunitstayid,
           rc.currenthistoryseqnum AS ventilation,
           rc.respcarestatusoffset AS ventilation_first_time
    FROM eicu_crd.respiratorycare rc
    WHERE rc.currenthistoryseqnum = 1
) AS resp ON resp.patientunitstayid = b.patientunitstayid;
WITH 
basic AS (
    WITH
    --纳入的诊断
/*
传染病|胸部/肺部感染|肺炎
传染病|胸部/肺部感染|肺炎|机会感染
传染病|胸部/肺部感染|肺炎|机会感染|卡氏肺囊虫病
肺部|肺部感染|肺炎
肺|肺部感染|肺炎|机会性
肺|肺部感染|肺炎|机会性|肺孢子菌肺炎
infectious diseases|chest/pulmonary infections|pneumonia|opportunistic|PCP
pulmonary|pulmonary infections|pneumonia|opportunistic|PCP
*/
included_disease1 AS(
    SELECT DISTINCT ON(patientunitstayid) diagnosisid,patientunitstayid,dia.diagnosisstring,icd9code,codeid,original_icdcode 
    FROM eicu_crd.diagnosis AS dia,
            (SELECT codeid,icd_code,original_icdcode,diagnosisstring 
            FROM "dictionary".d_icd_diagnosis WHERE codeid in ('800912')
            ) AS did
    WHERE True
        AND (CASE
            WHEN did.original_icdcode IS NULL THEN dia.diagnosisstring = did.diagnosisstring
            ELSE dia.icd9code LIKE CONCAT('%', did.original_icdcode, '%')
        END)
),
/*
传染病|胸部/肺部感染|肺炎
传染病|胸部/肺部感染|肺炎|机会感染
传染病|胸部/肺部感染|肺炎|机会感染|卡氏肺囊虫病
肺部|肺部感染|肺炎
肺|肺部感染|肺炎|机会性
肺|肺部感染|肺炎|机会性|肺孢子菌肺炎
infectious diseases|chest/pulmonary infections|pneumonia|opportunistic|PCP
pulmonary|pulmonary infections|pneumonia|opportunistic|PCP
*/
included_disease2 AS(
    SELECT DISTINCT ON(patientunitstayid) diagnosisid,patientunitstayid,dia.diagnosisstring,icd9code,codeid,original_icdcode 
    FROM eicu_crd.diagnosis AS dia,
            (SELECT codeid,icd_code,original_icdcode,diagnosisstring 
            FROM "dictionary".d_icd_diagnosis WHERE codeid in ('800911')
            ) AS did
    WHERE True
        AND (CASE
            WHEN did.original_icdcode IS NULL THEN dia.diagnosisstring = did.diagnosisstring
            ELSE dia.icd9code LIKE CONCAT('%', did.original_icdcode, '%')
        END)
)
SELECT DISTINCT ON(pat.uniquepid) pat.patientunitstayid,pat.age,pat.gender,pat.uniquepid
FROM eicu_crd.patient AS pat
WHERE True
    AND pat.age BETWEEN '18' AND '99'
        --纳入诊断疾病
        AND (
            pat.patientunitstayid IN (SELECT patientunitstayid FROM included_disease1)
            OR pat.patientunitstayid IN (SELECT patientunitstayid FROM included_disease2)
        )
)
--SELECT * FROM basic;

,
--renal_dialysis1 肾脏|手术/放射学|插入静脉导管进行血液透析|隧道插管术
renal_dialysis1 AS(
SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid,1 AS FLAG,treatmentoffset
FROM eicu_crd.treatment
WHERE TRUE
    AND treatmentstringid in (502162)
),
--renal_dialysis2 肾脏|手术/放射学|插入静脉导管进行血液透析|经皮穿刺插管
renal_dialysis2 AS(
SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid,1 AS FLAG,treatmentoffset
FROM eicu_crd.treatment
WHERE TRUE
    AND treatmentstringid in (502161)
),
--renal_dialysis3 肾脏|手术/放射学|插入静脉导管进行血液透析
renal_dialysis3 AS(
SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid,1 AS FLAG,treatmentoffset
FROM eicu_crd.treatment
WHERE TRUE
    AND treatmentstringid in (502160)
),
--renal_dialysis4 肾脏|手术/放射学|腹膜透析插管术
renal_dialysis4 AS(
SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid,1 AS FLAG,treatmentoffset
FROM eicu_crd.treatment
WHERE TRUE
    AND treatmentstringid in (502159)
),
--renal_dialysis5 肾脏|手术/放射学|肾透析动静脉短路术
renal_dialysis5 AS(
SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid,1 AS FLAG,treatmentoffset
FROM eicu_crd.treatment
WHERE TRUE
    AND treatmentstringid in (502157)
),
--renal_dialysis6 肾脏|电解质校正|治疗高磷血症|透析
renal_dialysis6 AS(
SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid,1 AS FLAG,treatmentoffset
FROM eicu_crd.treatment
WHERE TRUE
    AND treatmentstringid in (502042)
),
--renal_dialysis7 肾脏|透析|用于慢性肾功能衰竭的超滤（只除去液体）
renal_dialysis7 AS(
SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid,1 AS FLAG,treatmentoffset
FROM eicu_crd.treatment
WHERE TRUE
    AND treatmentstringid in (502009)
),
--renal_dialysis8 肾脏|透析|用于急性肾功能衰竭的超滤（只除去液体）
renal_dialysis8 AS(
SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid,1 AS FLAG,treatmentoffset
FROM eicu_crd.treatment
WHERE TRUE
    AND treatmentstringid in (502008)
),
--renal_dialysis9 肾脏|透析|急诊超滤（只除去液体）
renal_dialysis9 AS(
SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid,1 AS FLAG,treatmentoffset
FROM eicu_crd.treatment
WHERE TRUE
    AND treatmentstringid in (502007)
),
--renal_dialysis10 肾脏|透析|超滤（只除去液体）
renal_dialysis10 AS(
SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid,1 AS FLAG,treatmentoffset
FROM eicu_crd.treatment
WHERE TRUE
    AND treatmentstringid in (502006)
),
--renal_dialysis11 肾脏|透析|持续慢速血液透析(SLED)
renal_dialysis11 AS(
SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid,1 AS FLAG,treatmentoffset
FROM eicu_crd.treatment
WHERE TRUE
    AND treatmentstringid in (502005)
),
--renal_dialysis12 肾脏|透析|配合导管置入的腹膜透析
renal_dialysis12 AS(
SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid,1 AS FLAG,treatmentoffset
FROM eicu_crd.treatment
WHERE TRUE
    AND treatmentstringid in (502004)
),
--renal_dialysis13 肾脏|透析|用于慢性肾功能衰竭的腹膜透析
renal_dialysis13 AS(
SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid,1 AS FLAG,treatmentoffset
FROM eicu_crd.treatment
WHERE TRUE
    AND treatmentstringid in (502003)
),
--renal_dialysis14 肾脏|透析|用于急性肾功能衰竭的腹膜透析
renal_dialysis14 AS(
SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid,1 AS FLAG,treatmentoffset
FROM eicu_crd.treatment
WHERE TRUE
    AND treatmentstringid in (502002)
),
--renal_dialysis15 肾脏|透析|急诊腹膜透析
renal_dialysis15 AS(
SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid,1 AS FLAG,treatmentoffset
FROM eicu_crd.treatment
WHERE TRUE
    AND treatmentstringid in (502001)
),
--renal_dialysis16 肾脏|透析|腹膜透析
renal_dialysis16 AS(
SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid,1 AS FLAG,treatmentoffset
FROM eicu_crd.treatment
WHERE TRUE
    AND treatmentstringid in (502000)
),
--renal_dialysis17 肾脏|透析|穿隧道式导管插入静脉进行血液透析
renal_dialysis17 AS(
SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid,1 AS FLAG,treatmentoffset
FROM eicu_crd.treatment
WHERE TRUE
    AND treatmentstringid in (501999)
),
--renal_dialysis18 肾脏|透析|穿刺插入静脉导管进行血液透析
renal_dialysis18 AS(
SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid,1 AS FLAG,treatmentoffset
FROM eicu_crd.treatment
WHERE TRUE
    AND treatmentstringid in (501998)
),
--renal_dialysis19 肾脏|透析|插入静脉导管进行血液透析
renal_dialysis19 AS(
SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid,1 AS FLAG,treatmentoffset
FROM eicu_crd.treatment
WHERE TRUE
    AND treatmentstringid in (501997)
),
--renal_dialysis20 肾脏|透析|血液透析|用于慢性肾功能衰竭
renal_dialysis20 AS(
SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid,1 AS FLAG,treatmentoffset
FROM eicu_crd.treatment
WHERE TRUE
    AND treatmentstringid in (501996)
),
--renal_dialysis21 肾脏|透析|血液透析|用于急性肾功能衰竭
renal_dialysis21 AS(
SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid,1 AS FLAG,treatmentoffset
FROM eicu_crd.treatment
WHERE TRUE
    AND treatmentstringid in (501995)
),
--renal_dialysis22 肾脏|透析|血液透析|紧急
renal_dialysis22 AS(
SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid,1 AS FLAG,treatmentoffset
FROM eicu_crd.treatment
WHERE TRUE
    AND treatmentstringid in (501994)
),
--renal_dialysis23 肾脏|透析|血液透析
renal_dialysis23 AS(
SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid,1 AS FLAG,treatmentoffset
FROM eicu_crd.treatment
WHERE TRUE
    AND treatmentstringid in (501993)
),
--renal_dialysis24 肾脏|透析|CVVHD
renal_dialysis24 AS(
SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid,1 AS FLAG,treatmentoffset
FROM eicu_crd.treatment
WHERE TRUE
    AND treatmentstringid in (501992)
),
--renal_dialysis25 肾脏|透析|CVVH
renal_dialysis25 AS(
SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid,1 AS FLAG,treatmentoffset
FROM eicu_crd.treatment
WHERE TRUE
    AND treatmentstringid in (501991)
),
--renal_dialysis26 肾脏|透析|CAVHD
renal_dialysis26 AS(
SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid,1 AS FLAG,treatmentoffset
FROM eicu_crd.treatment
WHERE TRUE
    AND treatmentstringid in (501990)
),
--renal_dialysis27 肾脏|透析|动静脉分流术进行肾透析
renal_dialysis27 AS(
SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid,1 AS FLAG,treatmentoffset
FROM eicu_crd.treatment
WHERE TRUE
    AND treatmentstringid in (501989)
),
--dialysis 肾脏|电解质校正|治疗高钾血症|透析
dialysis AS(
SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid,1 AS FLAG,treatmentoffset
FROM eicu_crd.treatment
WHERE TRUE
    AND treatmentstringid in (502028)
)
SELECT basic.patientunitstayid,
renal_dialysis1.FLAG AS renal_dialysis1,
renal_dialysis1.treatmentoffset AS renal_dialysis1_treatmentoffset, 
renal_dialysis2.FLAG AS renal_dialysis2,
renal_dialysis2.treatmentoffset AS renal_dialysis2_treatmentoffset, 
renal_dialysis3.FLAG AS renal_dialysis3,
renal_dialysis3.treatmentoffset AS renal_dialysis3_treatmentoffset, 
renal_dialysis4.FLAG AS renal_dialysis4,
renal_dialysis4.treatmentoffset AS renal_dialysis4_treatmentoffset, 
renal_dialysis5.FLAG AS renal_dialysis5,
renal_dialysis5.treatmentoffset AS renal_dialysis5_treatmentoffset, 
renal_dialysis6.FLAG AS renal_dialysis6,
renal_dialysis6.treatmentoffset AS renal_dialysis6_treatmentoffset, 
renal_dialysis7.FLAG AS renal_dialysis7,
renal_dialysis7.treatmentoffset AS renal_dialysis7_treatmentoffset, 
renal_dialysis8.FLAG AS renal_dialysis8,
renal_dialysis8.treatmentoffset AS renal_dialysis8_treatmentoffset, 
renal_dialysis9.FLAG AS renal_dialysis9,
renal_dialysis9.treatmentoffset AS renal_dialysis9_treatmentoffset, 
renal_dialysis10.FLAG AS renal_dialysis10,
renal_dialysis10.treatmentoffset AS renal_dialysis10_treatmentoffset, 
renal_dialysis11.FLAG AS renal_dialysis11,
renal_dialysis11.treatmentoffset AS renal_dialysis11_treatmentoffset, 
renal_dialysis12.FLAG AS renal_dialysis12,
renal_dialysis12.treatmentoffset AS renal_dialysis12_treatmentoffset, 
renal_dialysis13.FLAG AS renal_dialysis13,
renal_dialysis13.treatmentoffset AS renal_dialysis13_treatmentoffset, 
renal_dialysis14.FLAG AS renal_dialysis14,
renal_dialysis14.treatmentoffset AS renal_dialysis14_treatmentoffset, 
renal_dialysis15.FLAG AS renal_dialysis15,
renal_dialysis15.treatmentoffset AS renal_dialysis15_treatmentoffset, 
renal_dialysis16.FLAG AS renal_dialysis16,
renal_dialysis16.treatmentoffset AS renal_dialysis16_treatmentoffset, 
renal_dialysis17.FLAG AS renal_dialysis17,
renal_dialysis17.treatmentoffset AS renal_dialysis17_treatmentoffset, 
renal_dialysis18.FLAG AS renal_dialysis18,
renal_dialysis18.treatmentoffset AS renal_dialysis18_treatmentoffset, 
renal_dialysis19.FLAG AS renal_dialysis19,
renal_dialysis19.treatmentoffset AS renal_dialysis19_treatmentoffset, 
renal_dialysis20.FLAG AS renal_dialysis20,
renal_dialysis20.treatmentoffset AS renal_dialysis20_treatmentoffset, 
renal_dialysis21.FLAG AS renal_dialysis21,
renal_dialysis21.treatmentoffset AS renal_dialysis21_treatmentoffset, 
renal_dialysis22.FLAG AS renal_dialysis22,
renal_dialysis22.treatmentoffset AS renal_dialysis22_treatmentoffset, 
renal_dialysis23.FLAG AS renal_dialysis23,
renal_dialysis23.treatmentoffset AS renal_dialysis23_treatmentoffset, 
renal_dialysis24.FLAG AS renal_dialysis24,
renal_dialysis24.treatmentoffset AS renal_dialysis24_treatmentoffset, 
renal_dialysis25.FLAG AS renal_dialysis25,
renal_dialysis25.treatmentoffset AS renal_dialysis25_treatmentoffset, 
renal_dialysis26.FLAG AS renal_dialysis26,
renal_dialysis26.treatmentoffset AS renal_dialysis26_treatmentoffset, 
renal_dialysis27.FLAG AS renal_dialysis27,
renal_dialysis27.treatmentoffset AS renal_dialysis27_treatmentoffset, 
dialysis.FLAG AS dialysis,
dialysis.treatmentoffset AS dialysis_treatmentoffset
FROM basic 
LEFT JOIN renal_dialysis1 ON basic.patientunitstayid=renal_dialysis1.patientunitstayid
LEFT JOIN renal_dialysis2 ON basic.patientunitstayid=renal_dialysis2.patientunitstayid
LEFT JOIN renal_dialysis3 ON basic.patientunitstayid=renal_dialysis3.patientunitstayid
LEFT JOIN renal_dialysis4 ON basic.patientunitstayid=renal_dialysis4.patientunitstayid
LEFT JOIN renal_dialysis5 ON basic.patientunitstayid=renal_dialysis5.patientunitstayid
LEFT JOIN renal_dialysis6 ON basic.patientunitstayid=renal_dialysis6.patientunitstayid
LEFT JOIN renal_dialysis7 ON basic.patientunitstayid=renal_dialysis7.patientunitstayid
LEFT JOIN renal_dialysis8 ON basic.patientunitstayid=renal_dialysis8.patientunitstayid
LEFT JOIN renal_dialysis9 ON basic.patientunitstayid=renal_dialysis9.patientunitstayid
LEFT JOIN renal_dialysis10 ON basic.patientunitstayid=renal_dialysis10.patientunitstayid
LEFT JOIN renal_dialysis11 ON basic.patientunitstayid=renal_dialysis11.patientunitstayid
LEFT JOIN renal_dialysis12 ON basic.patientunitstayid=renal_dialysis12.patientunitstayid
LEFT JOIN renal_dialysis13 ON basic.patientunitstayid=renal_dialysis13.patientunitstayid
LEFT JOIN renal_dialysis14 ON basic.patientunitstayid=renal_dialysis14.patientunitstayid
LEFT JOIN renal_dialysis15 ON basic.patientunitstayid=renal_dialysis15.patientunitstayid
LEFT JOIN renal_dialysis16 ON basic.patientunitstayid=renal_dialysis16.patientunitstayid
LEFT JOIN renal_dialysis17 ON basic.patientunitstayid=renal_dialysis17.patientunitstayid
LEFT JOIN renal_dialysis18 ON basic.patientunitstayid=renal_dialysis18.patientunitstayid
LEFT JOIN renal_dialysis19 ON basic.patientunitstayid=renal_dialysis19.patientunitstayid
LEFT JOIN renal_dialysis20 ON basic.patientunitstayid=renal_dialysis20.patientunitstayid
LEFT JOIN renal_dialysis21 ON basic.patientunitstayid=renal_dialysis21.patientunitstayid
LEFT JOIN renal_dialysis22 ON basic.patientunitstayid=renal_dialysis22.patientunitstayid
LEFT JOIN renal_dialysis23 ON basic.patientunitstayid=renal_dialysis23.patientunitstayid
LEFT JOIN renal_dialysis24 ON basic.patientunitstayid=renal_dialysis24.patientunitstayid
LEFT JOIN renal_dialysis25 ON basic.patientunitstayid=renal_dialysis25.patientunitstayid
LEFT JOIN renal_dialysis26 ON basic.patientunitstayid=renal_dialysis26.patientunitstayid
LEFT JOIN renal_dialysis27 ON basic.patientunitstayid=renal_dialysis27.patientunitstayid
LEFT JOIN dialysis ON basic.patientunitstayid=dialysis.patientunitstayid
WITH 
basic AS (
    WITH
    --纳入的诊断
/*
传染病|胸部/肺部感染|肺炎
传染病|胸部/肺部感染|肺炎|机会感染
传染病|胸部/肺部感染|肺炎|机会感染|卡氏肺囊虫病
肺部|肺部感染|肺炎
肺|肺部感染|肺炎|机会性
肺|肺部感染|肺炎|机会性|肺孢子菌肺炎
infectious diseases|chest/pulmonary infections|pneumonia|opportunistic|PCP
pulmonary|pulmonary infections|pneumonia|opportunistic|PCP
*/
included_disease1 AS(
    SELECT DISTINCT ON(patientunitstayid) diagnosisid,patientunitstayid,dia.diagnosisstring,icd9code,codeid,original_icdcode 
    FROM eicu_crd.diagnosis AS dia,
            (SELECT codeid,icd_code,original_icdcode,diagnosisstring 
            FROM "dictionary".d_icd_diagnosis WHERE codeid in ('800912')
            ) AS did
    WHERE True
        AND (CASE
            WHEN did.original_icdcode IS NULL THEN dia.diagnosisstring = did.diagnosisstring
            ELSE dia.icd9code LIKE CONCAT('%', did.original_icdcode, '%')
        END)
),
/*
传染病|胸部/肺部感染|肺炎
传染病|胸部/肺部感染|肺炎|机会感染
传染病|胸部/肺部感染|肺炎|机会感染|卡氏肺囊虫病
肺部|肺部感染|肺炎
肺|肺部感染|肺炎|机会性
肺|肺部感染|肺炎|机会性|肺孢子菌肺炎
infectious diseases|chest/pulmonary infections|pneumonia|opportunistic|PCP
pulmonary|pulmonary infections|pneumonia|opportunistic|PCP
*/
included_disease2 AS(
    SELECT DISTINCT ON(patientunitstayid) diagnosisid,patientunitstayid,dia.diagnosisstring,icd9code,codeid,original_icdcode 
    FROM eicu_crd.diagnosis AS dia,
            (SELECT codeid,icd_code,original_icdcode,diagnosisstring 
            FROM "dictionary".d_icd_diagnosis WHERE codeid in ('800911')
            ) AS did
    WHERE True
        AND (CASE
            WHEN did.original_icdcode IS NULL THEN dia.diagnosisstring = did.diagnosisstring
            ELSE dia.icd9code LIKE CONCAT('%', did.original_icdcode, '%')
        END)
)
SELECT DISTINCT ON(pat.uniquepid) pat.patientunitstayid,pat.age,pat.gender,pat.uniquepid
FROM eicu_crd.patient AS pat
WHERE True
    AND pat.age BETWEEN '18' AND '99'
        --纳入诊断疾病
        AND (
            pat.patientunitstayid IN (SELECT patientunitstayid FROM included_disease1)
            OR pat.patientunitstayid IN (SELECT patientunitstayid FROM included_disease2)
        )
)
--SELECT * FROM basic;

--sofa评分
SELECT sofa.* FROM basic,eicu_crd_derived.sofa
WHERE basic.patientunitstayid=sofa.patientunitstayid;
WITH 
basic AS (
    WITH
    --纳入的诊断
/*
传染病|胸部/肺部感染|肺炎
传染病|胸部/肺部感染|肺炎|机会感染
传染病|胸部/肺部感染|肺炎|机会感染|卡氏肺囊虫病
肺部|肺部感染|肺炎
肺|肺部感染|肺炎|机会性
肺|肺部感染|肺炎|机会性|肺孢子菌肺炎
infectious diseases|chest/pulmonary infections|pneumonia|opportunistic|PCP
pulmonary|pulmonary infections|pneumonia|opportunistic|PCP
*/
included_disease1 AS(
    SELECT DISTINCT ON(patientunitstayid) diagnosisid,patientunitstayid,dia.diagnosisstring,icd9code,codeid,original_icdcode 
    FROM eicu_crd.diagnosis AS dia,
            (SELECT codeid,icd_code,original_icdcode,diagnosisstring 
            FROM "dictionary".d_icd_diagnosis WHERE codeid in ('800912')
            ) AS did
    WHERE True
        AND (CASE
            WHEN did.original_icdcode IS NULL THEN dia.diagnosisstring = did.diagnosisstring
            ELSE dia.icd9code LIKE CONCAT('%', did.original_icdcode, '%')
        END)
),
/*
传染病|胸部/肺部感染|肺炎
传染病|胸部/肺部感染|肺炎|机会感染
传染病|胸部/肺部感染|肺炎|机会感染|卡氏肺囊虫病
肺部|肺部感染|肺炎
肺|肺部感染|肺炎|机会性
肺|肺部感染|肺炎|机会性|肺孢子菌肺炎
infectious diseases|chest/pulmonary infections|pneumonia|opportunistic|PCP
pulmonary|pulmonary infections|pneumonia|opportunistic|PCP
*/
included_disease2 AS(
    SELECT DISTINCT ON(patientunitstayid) diagnosisid,patientunitstayid,dia.diagnosisstring,icd9code,codeid,original_icdcode 
    FROM eicu_crd.diagnosis AS dia,
            (SELECT codeid,icd_code,original_icdcode,diagnosisstring 
            FROM "dictionary".d_icd_diagnosis WHERE codeid in ('800911')
            ) AS did
    WHERE True
        AND (CASE
            WHEN did.original_icdcode IS NULL THEN dia.diagnosisstring = did.diagnosisstring
            ELSE dia.icd9code LIKE CONCAT('%', did.original_icdcode, '%')
        END)
)
SELECT DISTINCT ON(pat.uniquepid) pat.patientunitstayid,pat.age,pat.gender,pat.uniquepid
FROM eicu_crd.patient AS pat
WHERE True
    AND pat.age BETWEEN '18' AND '99'
        --纳入诊断疾病
        AND (
            pat.patientunitstayid IN (SELECT patientunitstayid FROM included_disease1)
            OR pat.patientunitstayid IN (SELECT patientunitstayid FROM included_disease2)
        )
)
--SELECT * FROM basic;

SELECT sapsii.* FROM basic,eicu_crd_derived.sapsii
WHERE basic.patientunitstayid=sapsii.patientunitstayid;
WITH 
basic AS (
    WITH
    --纳入的诊断
/*
传染病|胸部/肺部感染|肺炎
传染病|胸部/肺部感染|肺炎|机会感染
传染病|胸部/肺部感染|肺炎|机会感染|卡氏肺囊虫病
肺部|肺部感染|肺炎
肺|肺部感染|肺炎|机会性
肺|肺部感染|肺炎|机会性|肺孢子菌肺炎
infectious diseases|chest/pulmonary infections|pneumonia|opportunistic|PCP
pulmonary|pulmonary infections|pneumonia|opportunistic|PCP
*/
included_disease1 AS(
    SELECT DISTINCT ON(patientunitstayid) diagnosisid,patientunitstayid,dia.diagnosisstring,icd9code,codeid,original_icdcode 
    FROM eicu_crd.diagnosis AS dia,
            (SELECT codeid,icd_code,original_icdcode,diagnosisstring 
            FROM "dictionary".d_icd_diagnosis WHERE codeid in ('800912')
            ) AS did
    WHERE True
        AND (CASE
            WHEN did.original_icdcode IS NULL THEN dia.diagnosisstring = did.diagnosisstring
            ELSE dia.icd9code LIKE CONCAT('%', did.original_icdcode, '%')
        END)
),
/*
传染病|胸部/肺部感染|肺炎
传染病|胸部/肺部感染|肺炎|机会感染
传染病|胸部/肺部感染|肺炎|机会感染|卡氏肺囊虫病
肺部|肺部感染|肺炎
肺|肺部感染|肺炎|机会性
肺|肺部感染|肺炎|机会性|肺孢子菌肺炎
infectious diseases|chest/pulmonary infections|pneumonia|opportunistic|PCP
pulmonary|pulmonary infections|pneumonia|opportunistic|PCP
*/
included_disease2 AS(
    SELECT DISTINCT ON(patientunitstayid) diagnosisid,patientunitstayid,dia.diagnosisstring,icd9code,codeid,original_icdcode 
    FROM eicu_crd.diagnosis AS dia,
            (SELECT codeid,icd_code,original_icdcode,diagnosisstring 
            FROM "dictionary".d_icd_diagnosis WHERE codeid in ('800911')
            ) AS did
    WHERE True
        AND (CASE
            WHEN did.original_icdcode IS NULL THEN dia.diagnosisstring = did.diagnosisstring
            ELSE dia.icd9code LIKE CONCAT('%', did.original_icdcode, '%')
        END)
)
SELECT DISTINCT ON(pat.uniquepid) pat.patientunitstayid,pat.age,pat.gender,pat.uniquepid
FROM eicu_crd.patient AS pat
WHERE True
    AND pat.age BETWEEN '18' AND '99'
        --纳入诊断疾病
        AND (
            pat.patientunitstayid IN (SELECT patientunitstayid FROM included_disease1)
            OR pat.patientunitstayid IN (SELECT patientunitstayid FROM included_disease2)
        )
)
--SELECT * FROM basic;

SELECT 
    b.patientunitstayid,
    id.apache_iv AS apache_score,
    CEIL(AVG(ps.gcs)) AS gcs,
    CEIL(AVG(ps.gcs_eyes)) AS gcs_eyes,
    CEIL(AVG(ps.gcs_motor)) AS gcs_motor,
    CEIL(AVG(ps.gcs_verbal)) AS gcs_verbal,
    CEIL(AVG(ps.delirium_score)) AS delirium_score,
    CEIL(AVG(ps.pain_score)) AS pain_score
FROM 
    basic b
LEFT JOIN 
    eicu_crd_derived.pivoted_score ps ON b.patientunitstayid = ps.patientunitstayid AND ps.entryoffset BETWEEN 0 AND 60 * 24
LEFT JOIN 
    eicu_crd.icustay_detail id ON b.patientunitstayid = id.patientunitstayid
GROUP BY 
    b.patientunitstayid,
    id.apache_iv;
WITH 
basic AS (
    WITH
    --纳入的诊断
/*
传染病|胸部/肺部感染|肺炎
传染病|胸部/肺部感染|肺炎|机会感染
传染病|胸部/肺部感染|肺炎|机会感染|卡氏肺囊虫病
肺部|肺部感染|肺炎
肺|肺部感染|肺炎|机会性
肺|肺部感染|肺炎|机会性|肺孢子菌肺炎
infectious diseases|chest/pulmonary infections|pneumonia|opportunistic|PCP
pulmonary|pulmonary infections|pneumonia|opportunistic|PCP
*/
included_disease1 AS(
    SELECT DISTINCT ON(patientunitstayid) diagnosisid,patientunitstayid,dia.diagnosisstring,icd9code,codeid,original_icdcode 
    FROM eicu_crd.diagnosis AS dia,
            (SELECT codeid,icd_code,original_icdcode,diagnosisstring 
            FROM "dictionary".d_icd_diagnosis WHERE codeid in ('800912')
            ) AS did
    WHERE True
        AND (CASE
            WHEN did.original_icdcode IS NULL THEN dia.diagnosisstring = did.diagnosisstring
            ELSE dia.icd9code LIKE CONCAT('%', did.original_icdcode, '%')
        END)
),
/*
传染病|胸部/肺部感染|肺炎
传染病|胸部/肺部感染|肺炎|机会感染
传染病|胸部/肺部感染|肺炎|机会感染|卡氏肺囊虫病
肺部|肺部感染|肺炎
肺|肺部感染|肺炎|机会性
肺|肺部感染|肺炎|机会性|肺孢子菌肺炎
infectious diseases|chest/pulmonary infections|pneumonia|opportunistic|PCP
pulmonary|pulmonary infections|pneumonia|opportunistic|PCP
*/
included_disease2 AS(
    SELECT DISTINCT ON(patientunitstayid) diagnosisid,patientunitstayid,dia.diagnosisstring,icd9code,codeid,original_icdcode 
    FROM eicu_crd.diagnosis AS dia,
            (SELECT codeid,icd_code,original_icdcode,diagnosisstring 
            FROM "dictionary".d_icd_diagnosis WHERE codeid in ('800911')
            ) AS did
    WHERE True
        AND (CASE
            WHEN did.original_icdcode IS NULL THEN dia.diagnosisstring = did.diagnosisstring
            ELSE dia.icd9code LIKE CONCAT('%', did.original_icdcode, '%')
        END)
)
SELECT DISTINCT ON(pat.uniquepid) pat.patientunitstayid,pat.age,pat.gender,pat.uniquepid
FROM eicu_crd.patient AS pat
WHERE True
    AND pat.age BETWEEN '18' AND '99'
        --纳入诊断疾病
        AND (
            pat.patientunitstayid IN (SELECT patientunitstayid FROM included_disease1)
            OR pat.patientunitstayid IN (SELECT patientunitstayid FROM included_disease2)
        )
)
--SELECT * FROM basic;

,
--x1sulfonamide 外科|感染|治疗性抗菌素|磺胺类药物|TMP-SMX
x1sulfonamide AS(
SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid,1 AS FLAG,treatmentoffset
FROM eicu_crd.treatment
WHERE TRUE
    AND treatmentstringid in (502416)
),
--x3sulfonamide 肾脏|药物|全身性抗生素|磺胺类药物
x3sulfonamide AS(
SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid,1 AS FLAG,treatmentoffset
FROM eicu_crd.treatment
WHERE TRUE
    AND treatmentstringid in (502152)
),
--x4sulfonamide 肺部|药物|抗菌药|磺胺类|甲氧苄氏磺胺-三嘧啶
x4sulfonamide AS(
SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid,1 AS FLAG,treatmentoffset
FROM eicu_crd.treatment
WHERE TRUE
    AND treatmentstringid in (501724)
),
--x5sulfonamide 肺部|药物|抗菌药|磺胺类|磺胺甲噁唑
x5sulfonamide AS(
SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid,1 AS FLAG,treatmentoffset
FROM eicu_crd.treatment
WHERE TRUE
    AND treatmentstringid in (501723)
),
--x6sulfonamide 肺部|药物|抗菌药|磺胺类
x6sulfonamide AS(
SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid,1 AS FLAG,treatmentoffset
FROM eicu_crd.treatment
WHERE TRUE
    AND treatmentstringid in (501722)
),
--x7sulfonamide 传染病|药物|治疗性抗生素|磺胺药|复方新诺明
x7sulfonamide AS(
SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid,1 AS FLAG,treatmentoffset
FROM eicu_crd.treatment
WHERE TRUE
    AND treatmentstringid in (501326)
),
--x8sulfonamide 传染病|药物|治疗性抗生素|磺胺药|磺胺甲基异噁唑
x8sulfonamide AS(
SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid,1 AS FLAG,treatmentoffset
FROM eicu_crd.treatment
WHERE TRUE
    AND treatmentstringid in (501325)
),
--x9sulfonamide 传染病|药物|治疗性抗生素|磺胺药|磺胺二嗪
x9sulfonamide AS(
SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid,1 AS FLAG,treatmentoffset
FROM eicu_crd.treatment
WHERE TRUE
    AND treatmentstringid in (501324)
),
--x10sulfonamide 传染病|药物|治疗性抗生素|磺胺药
x10sulfonamide AS(
SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid,1 AS FLAG,treatmentoffset
FROM eicu_crd.treatment
WHERE TRUE
    AND treatmentstringid in (501323)
),
--x11sulfonamide 传染病|药物|抗原虽治疗|弓形虎虫病治疗|磺胺嘧啶
x11sulfonamide AS(
SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid,1 AS FLAG,treatmentoffset
FROM eicu_crd.treatment
WHERE TRUE
    AND treatmentstringid in (501183)
),
--x12sulfonamide 胃肠道|药物|抗生素|磺胺药
x12sulfonamide AS(
SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid,1 AS FLAG,treatmentoffset
FROM eicu_crd.treatment
WHERE TRUE
    AND treatmentstringid in (500875)
),
--x13sulfonamide 心血管|其他疗法|抗菌药|磺胺剂|复方新诺明
x13sulfonamide AS(
SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid,1 AS FLAG,treatmentoffset
FROM eicu_crd.treatment
WHERE TRUE
    AND treatmentstringid in (500464)
),
--x14sulfonamide 心血管|其他疗法|抗菌药|磺胺剂|磺苄唑沙宗
x14sulfonamide AS(
SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid,1 AS FLAG,treatmentoffset
FROM eicu_crd.treatment
WHERE TRUE
    AND treatmentstringid in (500463)
),
--x15sulfonamide 心血管|其他疗法|抗菌药|磺胺剂|磺胺甲基异噁唑
x15sulfonamide AS(
SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid,1 AS FLAG,treatmentoffset
FROM eicu_crd.treatment
WHERE TRUE
    AND treatmentstringid in (500462)
),
--x2sulfonamide 心血管|其他疗法|抗菌药|磺胺剂
x2sulfonamide AS(
SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid,1 AS FLAG,treatmentoffset
FROM eicu_crd.treatment
WHERE TRUE
    AND treatmentstringid in (500461)
)
SELECT basic.patientunitstayid,
x1sulfonamide.FLAG AS x1sulfonamide,
x1sulfonamide.treatmentoffset AS x1sulfonamide_treatmentoffset, 
x3sulfonamide.FLAG AS x3sulfonamide,
x3sulfonamide.treatmentoffset AS x3sulfonamide_treatmentoffset, 
x4sulfonamide.FLAG AS x4sulfonamide,
x4sulfonamide.treatmentoffset AS x4sulfonamide_treatmentoffset, 
x5sulfonamide.FLAG AS x5sulfonamide,
x5sulfonamide.treatmentoffset AS x5sulfonamide_treatmentoffset, 
x6sulfonamide.FLAG AS x6sulfonamide,
x6sulfonamide.treatmentoffset AS x6sulfonamide_treatmentoffset, 
x7sulfonamide.FLAG AS x7sulfonamide,
x7sulfonamide.treatmentoffset AS x7sulfonamide_treatmentoffset, 
x8sulfonamide.FLAG AS x8sulfonamide,
x8sulfonamide.treatmentoffset AS x8sulfonamide_treatmentoffset, 
x9sulfonamide.FLAG AS x9sulfonamide,
x9sulfonamide.treatmentoffset AS x9sulfonamide_treatmentoffset, 
x10sulfonamide.FLAG AS x10sulfonamide,
x10sulfonamide.treatmentoffset AS x10sulfonamide_treatmentoffset, 
x11sulfonamide.FLAG AS x11sulfonamide,
x11sulfonamide.treatmentoffset AS x11sulfonamide_treatmentoffset, 
x12sulfonamide.FLAG AS x12sulfonamide,
x12sulfonamide.treatmentoffset AS x12sulfonamide_treatmentoffset, 
x13sulfonamide.FLAG AS x13sulfonamide,
x13sulfonamide.treatmentoffset AS x13sulfonamide_treatmentoffset, 
x14sulfonamide.FLAG AS x14sulfonamide,
x14sulfonamide.treatmentoffset AS x14sulfonamide_treatmentoffset, 
x15sulfonamide.FLAG AS x15sulfonamide,
x15sulfonamide.treatmentoffset AS x15sulfonamide_treatmentoffset, 
x2sulfonamide.FLAG AS x2sulfonamide,
x2sulfonamide.treatmentoffset AS x2sulfonamide_treatmentoffset
FROM basic 
LEFT JOIN x1sulfonamide ON basic.patientunitstayid=x1sulfonamide.patientunitstayid
LEFT JOIN x3sulfonamide ON basic.patientunitstayid=x3sulfonamide.patientunitstayid
LEFT JOIN x4sulfonamide ON basic.patientunitstayid=x4sulfonamide.patientunitstayid
LEFT JOIN x5sulfonamide ON basic.patientunitstayid=x5sulfonamide.patientunitstayid
LEFT JOIN x6sulfonamide ON basic.patientunitstayid=x6sulfonamide.patientunitstayid
LEFT JOIN x7sulfonamide ON basic.patientunitstayid=x7sulfonamide.patientunitstayid
LEFT JOIN x8sulfonamide ON basic.patientunitstayid=x8sulfonamide.patientunitstayid
LEFT JOIN x9sulfonamide ON basic.patientunitstayid=x9sulfonamide.patientunitstayid
LEFT JOIN x10sulfonamide ON basic.patientunitstayid=x10sulfonamide.patientunitstayid
LEFT JOIN x11sulfonamide ON basic.patientunitstayid=x11sulfonamide.patientunitstayid
LEFT JOIN x12sulfonamide ON basic.patientunitstayid=x12sulfonamide.patientunitstayid
LEFT JOIN x13sulfonamide ON basic.patientunitstayid=x13sulfonamide.patientunitstayid
LEFT JOIN x14sulfonamide ON basic.patientunitstayid=x14sulfonamide.patientunitstayid
LEFT JOIN x15sulfonamide ON basic.patientunitstayid=x15sulfonamide.patientunitstayid
LEFT JOIN x2sulfonamide ON basic.patientunitstayid=x2sulfonamide.patientunitstayid
WITH 
basic AS (
    WITH
    --纳入的诊断
/*
传染病|胸部/肺部感染|肺炎
传染病|胸部/肺部感染|肺炎|机会感染
传染病|胸部/肺部感染|肺炎|机会感染|卡氏肺囊虫病
肺部|肺部感染|肺炎
肺|肺部感染|肺炎|机会性
肺|肺部感染|肺炎|机会性|肺孢子菌肺炎
infectious diseases|chest/pulmonary infections|pneumonia|opportunistic|PCP
pulmonary|pulmonary infections|pneumonia|opportunistic|PCP
*/
included_disease1 AS(
    SELECT DISTINCT ON(patientunitstayid) diagnosisid,patientunitstayid,dia.diagnosisstring,icd9code,codeid,original_icdcode 
    FROM eicu_crd.diagnosis AS dia,
            (SELECT codeid,icd_code,original_icdcode,diagnosisstring 
            FROM "dictionary".d_icd_diagnosis WHERE codeid in ('800912')
            ) AS did
    WHERE True
        AND (CASE
            WHEN did.original_icdcode IS NULL THEN dia.diagnosisstring = did.diagnosisstring
            ELSE dia.icd9code LIKE CONCAT('%', did.original_icdcode, '%')
        END)
),
/*
传染病|胸部/肺部感染|肺炎
传染病|胸部/肺部感染|肺炎|机会感染
传染病|胸部/肺部感染|肺炎|机会感染|卡氏肺囊虫病
肺部|肺部感染|肺炎
肺|肺部感染|肺炎|机会性
肺|肺部感染|肺炎|机会性|肺孢子菌肺炎
infectious diseases|chest/pulmonary infections|pneumonia|opportunistic|PCP
pulmonary|pulmonary infections|pneumonia|opportunistic|PCP
*/
included_disease2 AS(
    SELECT DISTINCT ON(patientunitstayid) diagnosisid,patientunitstayid,dia.diagnosisstring,icd9code,codeid,original_icdcode 
    FROM eicu_crd.diagnosis AS dia,
            (SELECT codeid,icd_code,original_icdcode,diagnosisstring 
            FROM "dictionary".d_icd_diagnosis WHERE codeid in ('800911')
            ) AS did
    WHERE True
        AND (CASE
            WHEN did.original_icdcode IS NULL THEN dia.diagnosisstring = did.diagnosisstring
            ELSE dia.icd9code LIKE CONCAT('%', did.original_icdcode, '%')
        END)
)
SELECT DISTINCT ON(pat.uniquepid) pat.patientunitstayid,pat.age,pat.gender,pat.uniquepid
FROM eicu_crd.patient AS pat
WHERE True
    AND pat.age BETWEEN '18' AND '99'
        --纳入诊断疾病
        AND (
            pat.patientunitstayid IN (SELECT patientunitstayid FROM included_disease1)
            OR pat.patientunitstayid IN (SELECT patientunitstayid FROM included_disease2)
        )
)
--SELECT * FROM basic;

,
--caspofungin 手术|感染|抗真菌疗法|卡泊芬净
caspofungin AS(
SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid,1 AS FLAG,treatmentoffset
FROM eicu_crd.treatment
WHERE TRUE
    AND treatmentstringid in (502347)
),
--caspofungin2 肺部|药物|抗真菌治疗|卡泊芬净
caspofungin2 AS(
SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid,1 AS FLAG,treatmentoffset
FROM eicu_crd.treatment
WHERE TRUE
    AND treatmentstringid in (501750)
),
--caspofungin3 传染病|药物|抗真菌治疗|卡泊芬净
caspofungin3 AS(
SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid,1 AS FLAG,treatmentoffset
FROM eicu_crd.treatment
WHERE TRUE
    AND treatmentstringid in (501187)
),
--atovaquone 肺部|药物|肺孢子虫治疗|阿托伐醌
atovaquone AS(
SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid,1 AS FLAG,treatmentoffset
FROM eicu_crd.treatment
WHERE TRUE
    AND treatmentstringid in (501797)
),
--atovaquone2 感染性疾病|药物|肺囊虫疗法|阿托伐醌
atovaquone2 AS(
SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid,1 AS FLAG,treatmentoffset
FROM eicu_crd.treatment
WHERE TRUE
    AND treatmentstringid in (501241)
),
--atovaquone3 传染病|药物|抗原虽治疗|弓形虎虫病治疗|阿托伐醌
atovaquone3 AS(
SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid,1 AS FLAG,treatmentoffset
FROM eicu_crd.treatment
WHERE TRUE
    AND treatmentstringid in (501179)
),
--primaquine 肺部|药物|肺孢子虫治疗|伯氏奎宁
primaquine AS(
SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid,1 AS FLAG,treatmentoffset
FROM eicu_crd.treatment
WHERE TRUE
    AND treatmentstringid in (501802)
),
--primaquine2 感染性疾病|药物|肺囊虫疗法|伯氏原虫素
primaquine2 AS(
SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid,1 AS FLAG,treatmentoffset
FROM eicu_crd.treatment
WHERE TRUE
    AND treatmentstringid in (501246)
),
--pentamidine 肺部|药物|肺孢子虫治疗|喷他霉素
pentamidine AS(
SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid,1 AS FLAG,treatmentoffset
FROM eicu_crd.treatment
WHERE TRUE
    AND treatmentstringid in (501801)
),
--pentamidine2 感染性疾病|药物|肺囊虫疗法|喷他米星
pentamidine2 AS(
SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid,1 AS FLAG,treatmentoffset
FROM eicu_crd.treatment
WHERE TRUE
    AND treatmentstringid in (501245)
)
SELECT basic.patientunitstayid,
caspofungin.FLAG AS caspofungin,
caspofungin.treatmentoffset AS caspofungin_treatmentoffset, 
caspofungin2.FLAG AS caspofungin2,
caspofungin2.treatmentoffset AS caspofungin2_treatmentoffset, 
caspofungin3.FLAG AS caspofungin3,
caspofungin3.treatmentoffset AS caspofungin3_treatmentoffset, 
atovaquone.FLAG AS atovaquone,
atovaquone.treatmentoffset AS atovaquone_treatmentoffset, 
atovaquone2.FLAG AS atovaquone2,
atovaquone2.treatmentoffset AS atovaquone2_treatmentoffset, 
atovaquone3.FLAG AS atovaquone3,
atovaquone3.treatmentoffset AS atovaquone3_treatmentoffset, 
primaquine.FLAG AS primaquine,
primaquine.treatmentoffset AS primaquine_treatmentoffset, 
primaquine2.FLAG AS primaquine2,
primaquine2.treatmentoffset AS primaquine2_treatmentoffset, 
pentamidine.FLAG AS pentamidine,
pentamidine.treatmentoffset AS pentamidine_treatmentoffset, 
pentamidine2.FLAG AS pentamidine2,
pentamidine2.treatmentoffset AS pentamidine2_treatmentoffset
FROM basic 
LEFT JOIN caspofungin ON basic.patientunitstayid=caspofungin.patientunitstayid
LEFT JOIN caspofungin2 ON basic.patientunitstayid=caspofungin2.patientunitstayid
LEFT JOIN caspofungin3 ON basic.patientunitstayid=caspofungin3.patientunitstayid
LEFT JOIN atovaquone ON basic.patientunitstayid=atovaquone.patientunitstayid
LEFT JOIN atovaquone2 ON basic.patientunitstayid=atovaquone2.patientunitstayid
LEFT JOIN atovaquone3 ON basic.patientunitstayid=atovaquone3.patientunitstayid
LEFT JOIN primaquine ON basic.patientunitstayid=primaquine.patientunitstayid
LEFT JOIN primaquine2 ON basic.patientunitstayid=primaquine2.patientunitstayid
LEFT JOIN pentamidine ON basic.patientunitstayid=pentamidine.patientunitstayid
LEFT JOIN pentamidine2 ON basic.patientunitstayid=pentamidine2.patientunitstayid

