WITH
included_disease1 AS (
    SELECT DISTINCT ON(patientunitstayid) diagnosisid, patientunitstayid, dia.diagnosisstring, icd9code, codeid, original_icdcode
    FROM eicu_crd.diagnosis AS dia,
    (
        SELECT codeid, icd_code, original_icdcode, diagnosisstring
        FROM "dictionary".d_icd_diagnosis
        WHERE codeid in ('800912')
    ) AS did
    WHERE CASE
        WHEN did.original_icdcode IS NULL THEN dia.diagnosisstring = did.diagnosisstring
        ELSE dia.icd9code LIKE CONCAT('%', did.original_icdcode, '%')
    END
),
included_disease2 AS (
    SELECT DISTINCT ON(patientunitstayid) diagnosisid, patientunitstayid, dia.diagnosisstring, icd9code, codeid, original_icdcode
    FROM eicu_crd.diagnosis AS dia,
    (
        SELECT codeid, icd_code, original_icdcode, diagnosisstring
        FROM "dictionary".d_icd_diagnosis
        WHERE codeid in ('800911')
    ) AS did
    WHERE CASE
        WHEN did.original_icdcode IS NULL THEN dia.diagnosisstring = did.diagnosisstring
        ELSE dia.icd9code LIKE CONCAT('%', did.original_icdcode, '%')
    END
),
basic AS (
    SELECT DISTINCT ON(pat.uniquepid) pat.patientunitstayid, pat.age, pat.gender, pat.uniquepid
    FROM eicu_crd.patient AS pat
    WHERE True
        AND pat.age BETWEEN '18' AND '99'
        AND (
            pat.patientunitstayid IN (SELECT patientunitstayid FROM included_disease1)
            OR pat.patientunitstayid IN (SELECT patientunitstayid FROM included_disease2)
        )
),
-- 1. Demographics & base hospital info
demographics AS (
    SELECT
        patient.patientunitstayid,
        patient.age,
        patient.gender,
        patient.admissionheight AS height,
        patient.ethnicity AS race,
        patient.admissionweight AS weight,
        patient.unittype AS unittype,
        patient.hospitaladmittime24,
        patient.hospitaladmitoffset,
        patient.hospitaldischargetime24,
        patient.hospitaldischargeoffset,
        patient.unitadmittime24,
        patient.unitdischargetime24,
        patient.unitdischargeoffset,
        patient.hospitaldischargeyear,
        p.hospitaldischargestatus,
        ((p.hospitaldischargeoffset - p.hospitaladmitoffset) /( 24.0*60)) AS hosplosday,
        (i.icu_los_hours / 24.0) AS unitlosday,
        p.unitadmitsource,
        p.unitdischargelocation,
        p.unitdischargestatus,
        p.unitstaytype,
        i.unittype
    FROM eicu_crd.patient AS patient
    LEFT JOIN eicu_crd.patient p ON patient.patientunitstayid = p.patientunitstayid
    LEFT JOIN eicu_crd.icustay_detail i ON p.patientunitstayid = i.patientunitstayid
    WHERE patient.patientunitstayid IN (SELECT patientunitstayid FROM basic)
),
-- 2. 24h lab results (WBC/RBC/platelet/lymph/neutrophil/CRP/LDH/FiO2/pO2 etc)
lab_24h AS (
    SELECT
        lab.patientunitstayid,
        AVG(CASE WHEN lab.labnameid = 100157 THEN lab.labresult END) AS lab24Hours_WBC_x_1000,
        MAX(CASE WHEN lab.labnameid = 100157 THEN lab.labmeasurenamesystem END) AS lab24Hours_WBC_x_1000_uom,
        AVG(CASE WHEN lab.labnameid = 10010 THEN lab.labresult END) AS lab24Hours_RBC,
        MAX(CASE WHEN lab.labnameid = 100108 THEN lab.labmeasurenamesystem END) AS lab24Hours_RBC_uom,
        AVG(CASE WHEN lab.labnameid = 100094 THEN lab.labresult END) AS lab24Hours_platelets_x_1000,
        MAX(CASE WHEN lab.labnameid = 100094 THEN lab.labmeasurenamesystem END) AS lab24Hours_platelets_x_1000_uom,
        AVG(CASE WHEN lab.labnameid = 100061 THEN lab.labresult END) AS lab24Hours_Hgb,
        MAX(CASE WHEN lab.labnameid = 100061 THEN lab.labmeasurenamesystem END) AS lab24Hours_Hgb_uom,
        AVG(CASE WHEN lab.labnameid = 100003 THEN lab.labresult END) AS lab24Hours_lymphs,
        MAX(CASE WHEN lab.labnameid = 100003 THEN lab.labmeasurenamesystem END) AS lab24Hours_lymphs_uom,
        AVG(CASE WHEN lab.labnameid = 100004 THEN lab.labresult END) AS lab24Hours_monos,
        MAX(CASE WHEN lab.labnameid = 100004 THEN lab.labmeasurenamesystem END) AS lab24Hours_monos_uom,
        AVG(CASE WHEN lab.labnameid = 100037 THEN lab.labresult END) AS lab24Hours_CRP,
        MAX(CASE WHEN lab.labnameid = 100037 THEN lab.labmeasurenamesystem END) AS lab24Hours_CRP_uom,
        AVG(CASE WHEN lab.labnameid = 100038 THEN lab.labresult END) AS lab24Hours_CRPhs,
        MAX(CASE WHEN lab.labnameid = 100038 THEN lab.labmeasurenamesystem END) AS lab24Hours_CRPhs_uom,
        AVG(CASE WHEN lab.labnameid = 100001 THEN lab.labresult END) AS lab24Hours_basos,
        MAX(CASE WHEN lab.labnameid = 100001 THEN lab.labmeasurenamesystem END) AS lab24Hours_basos_uom,
        AVG(CASE WHEN lab.labnameid = 100002 THEN lab.labresult END) AS lab24Hours_eos,
        MAX(CASE WHEN lab.labnameid = 100002 THEN lab.labmeasurenamesystem END) AS lab24Hours_eos_uom,
        AVG(CASE WHEN lab.labnameid = 100005 THEN lab.labresult END) AS lab24Hours_polys,
        MAX(CASE WHEN lab.labnameid = 100005 THEN lab.labmeasurenamesystem END) AS lab24Hours_polys_uom,
        AVG(CASE WHEN lab.labnameid = 100049 THEN lab.labresult END) AS lab24Hours_FiO2,
        MAX(CASE WHEN lab.labnameid = 100049 THEN lab.labmeasurenamesystem END) AS lab24Hours_FiO2_uom,
        AVG(CASE WHEN lab.labnameid = 100087 THEN lab.labresult END) AS lab24Hours_paO2,
        MAX(CASE WHEN lab.labnameid = 100087 THEN lab.labmeasurenamesystem END) AS lab24Hours_paO2_uom,
        AVG(CASE WHEN lab.labnameid = 100088 THEN lab.labresult END) AS lab24Hours_Peak_AirwayPressure,
        MAX(CASE WHEN lab.labnameid = 100088 THEN lab.labmeasurenamesystem END) AS lab24Hours_Peak_AirwayPressure_uom,
        AVG(CASE WHEN lab.labnameid = 100067 THEN lab.labresult END) AS lab24Hours_LDH,
        MAX(CASE WHEN lab.labnameid = 100067 THEN lab.labmeasurenamesystem END) AS lab24Hours_LDH_uom
    FROM eicu_crd.lab lab
    WHERE lab.patientunitstayid IN (SELECT patientunitstayid FROM basic)
      AND lab.labnameid IN (100157,100108,100094,100061,100003,100004,100037,100038,100001,100002,100005,100049,100087,100088,100067)
      AND lab.labresultoffset BETWEEN 0 AND 24*60
    GROUP BY lab.patientunitstayid
),
-- Creatinine lab
lab_creatinine AS (
    SELECT
        lab.patientunitstayid,
        MAX(lab.labresult) AS first_creatinine,
        MAX(lab.labmeasurenamesystem) AS first_creatinine_uom,
        MIN(lab.labresultoffset) AS first_creatinine_min_labresultoffset
    FROM eicu_crd.lab lab
    WHERE lab.patientunitstayid IN (SELECT patientunitstayid FROM basic)
      AND lab.labnameid IN (100036)
    GROUP BY lab.patientunitstayid
),
-- CD4 lab
lab_cd4 AS (
    SELECT
        lab.patientunitstayid,
        MAX(lab.labresult) AS first_cd_4,
        MAX(lab.labmeasurenamesystem) AS first_cd_4_uom,
        MIN(lab.labresultoffset) AS first_cd_4_min_labresultoffset
    FROM eicu_crd.lab lab
    WHERE lab.patientunitstayid IN (SELECT patientunitstayid FROM basic)
      AND lab.labnameid IN (100029)
    GROUP BY lab.patientunitstayid
),
-- Sulfamethoxazole / TMP-SMX related drugs
drug_smx AS (
    SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid, 1 AS x1, MAX(treatmentoffset) AS x1_treatmentoffset FROM eicu_crd.treatment WHERE treatmentstringid in (502416) GROUP BY patientunitstayid, treatmentoffset
    UNION ALL SELECT DISTIN ON(treatment.patientunitstayid) patientunitstayid, 2 AS x2, MAX(treatmentoffset) AS x2_treatmentoffset FROM eicu_crd.treatment WHERE treatmentstringid in (502372) GROUP BY patientunitstayid, treatmentoffset
    UNION ALL SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid, 3 AS x3, MAX(treatmentoffset) AS x3_treatmentoffset FROM eicu_crd.treatment WHERE treatmentstringid in (502152) GROUP BY patientunitstayid
    UNION ALL SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid, 4 AS x4, MAX(treatmentoffset) AS x4_treatmentoffset FROM eicu_crd.treatment WHERE treatmentstringid in (501724) GROUP BY patientunitstayid
    UNION ALL SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid, 5 AS x5, MAX(treatmentoffset) AS x5_treatmentoffset FROM eicu_crd.treatment WHERE treatmentstringid in (501723) GROUP BY patientunitstayid
    UNION ALL SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid, 6 AS x6, MAX(treatmentoffset) AS x6_treatmentoffset FROM eicu_crd.treatment WHERE treatmentstringid in (501722) GROUP BY patientunitstayid
    UNION ALL SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid, 7 AS x7, MAX(treatmentoffset) AS x7_treatmentoffset FROM eicu_crd.treatment WHERE treatmentstringid in (501326) GROUP BY patientunitstayid
    UNION ALL SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid, 8 AS x8, MAX(treatmentoffset) AS x8_treatmentoffset FROM eicu_crd.treatment WHERE treatmentstringid in (501325) GROUP BY patientunitstayid
    UNION ALL SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid, 9 AS x9, MAX(treatmentoffset) AS x9_treatmentoffset FROM eicu_crd.treatment WHERE treatmentstringid in (501324) GROUP BY patientunitstayid
    UNION ALL SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid, 10 AS x10, MAX(treatmentoffset) AS x10_treatmentoffset FROM eicu_crd.treatment WHERE treatmentstringid in (501323) GROUP BY patientunitstayid
    UNION ALL SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid, 11 AS x11, MAX(treatmentoffset) AS x11_treatmentoffset FROM eicu_crd.treatment WHERE treatmentstringid in (501264) GROUP BY patientunitstayid
    UNION ALL SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid, 12 AS x12, MAX(treatmentoffset) AS x12_treatmentoffset FROM eicu_crd.treatment WHERE treatmentstringid in (501263) GROUP BY patientunitstayid
    UNION ALL SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid, 13 AS x13, MAX(treatmentoffset) AS x13_treatmentoffset FROM eicu_crd.treatment WHERE treatmentstringid in (501183) GROUP BY patientunitstayid
    UNION ALL SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid, 14 AS x14, MAX(treatmentoffset) AS x14_treatmentoffset FROM eicu_crd.treatment WHERE treatmentstringid in (500875) GROUP BY patientunitstayid
    UNION ALL SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid, 15 AS x15, MAX(treatmentoffset) AS x15_treatmentoffset FROM eicu_crd.treatment WHERE treatmentstringid in (500464) GROUP BY patientunitstayid
    UNION ALL SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid, 16 AS x16, MAX(treatmentoffset) AS x16_treatmentoffset FROM eicu_crd.treatment WHERE treatmentstringid in (500463) GROUP BY patientunitstayid
    UNION ALL SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid, 17 AS x17, MAX(treatmentoffset) AS x17_treatmentoffset FROM eicu_crd.treatment WHERE treatmentstringid in (500462) GROUP BY patientunitstayid
    UNION ALL SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid, 18 AS sulfonamide, MAX(treatmentoffset) AS sulfonamide_treatmentoffset FROM eicu_crd.treatment WHERE treatmentstringid in (500461) GROUP BY patientunitstayid
),
-- PCP specific antifungals
drug_pcp_anti AS (
    SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid, 'caspofungin' AS drug, 1 AS flag, MAX(treatmentoffset) AS toff FROM eicu_crd.treatment WHERE treatmentstringid IN (502347,501750,501187) GROUP BY patientunitstayid
    UNION ALL SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid, 'atovaquone' AS drug,1 AS flag, MAX(treatmentoffset) AS toff FROM eicu_crd.treatment WHERE treatmentstringid IN (501797,501241,501179) GROUP BY patientunitstayid
    UNION ALL SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid, 'primaquine' AS drug,1 AS flag, MAX(treatmentoffset) AS toff FROM eicu_crd.treatment WHERE treatmentstringid IN (501802,501246) GROUP BY patientunitstayid
    UNION ALL SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid, 'pentamidine' AS drug,1 AS flag, MAX(treatmentoffset) AS toff FROM eicu_crd.treatment WHERE treatmentstringid IN (501801,501245) GROUP BY patientunitstayid
),
-- Vasopressor medications
drug_vaso AS (
    SELECT DISTINCT ON(medication.patientunitstayid) patientunitstayid, 1 AS Vasopressor, drugstartoffset, drugorderoffset
    FROM eicu_crd.medication
    WHERE drugnameid in ('300001','300130','300140','300166','300352','300509','300528','300529','300803','300804','300805','300806','300807','300808','300809','300810','300811','300812','300813','301018','301019','301020','301021','301022','301023','301024','301025','301103','301104','301105','301106','301107','301108','301198','301376')
      AND drugstartoffset >0
),
-- Glucocorticoids
drug_gc AS (
    SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid, 'parenteral1' AS typ,1 AS flag, MAX(treatmentoffset) AS toff FROM eicu_crd.treatment WHERE treatmentstringid=501784 GROUP BY patientunitstayid
    UNION ALL SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid, 'oral1' AS typ,1 AS flag, MAX(treatmentoffset) AS toff FROM eicu_crd.treatment WHERE treatmentstringid=501783 GROUP BY patientunitstayid
    UNION ALL SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid, 'inhaled' AS typ,1 AS flag, MAX(treatmentoffset) AS toff FROM eicu_crd.treatment WHERE treatmentstringid=501782 GROUP BY patientunitstayid
    UNION ALL SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid, 'glucocorticoid_administration' AS typ,1 AS flag, MAX(treatmentoffset) AS toff FROM eicu_crd.treatment WHERE treatmentstringid=501781 GROUP BY patientunitstayid
    UNION ALL SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid, 'stress_doses' AS typ,1 AS flag, MAX(treatmentoffset) AS toff FROM eicu_crd.treatment WHERE treatmentstringid=501268 GROUP BY patientunitstayid
    UNION ALL SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid, 'parenteral2' AS typ,1 AS flag, MAX(treatmentoffset) AS toff FROM eicu_crd.treatment WHERE treatmentstringid=501267 GROUP BY patientunitstayid
    UNION ALL SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid, 'oral2' AS typ,1 AS flag, MAX(treatmentoffset) AS toff FROM eicu_crd.treatment WHERE treatmentstringid=501266 GROUP BY patientunitstayid
    UNION ALL SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid, 'systemic_glucocorticoid' AS typ,1 AS flag, MAX(treatmentoffset) AS toff FROM eicu_crd.treatment WHERE treatmentstringid=501265 GROUP BY patientunitstayid
),
-- Transplant & immunosuppressant drugs
drug_immuno_transplant AS (
    SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid, 'Transplant_surgery_consultation' AS typ,1 AS flag, MAX(treatmentoffset) AS toff FROM eicu_crd.treatment WHERE treatmentstringid=502699 GROUP BY patientunitstayid
    UNION ALL SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid, 'Cardiac_surgery_consultation' AS typ,1 AS flag, MAX(treatmentoffset) AS toff FROM eicu_crd.treatment WHERE treatmentstringid=502691 GROUP BY patientunitstayid
    UNION ALL SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid, 'thymoglobulin2' AS typ,1 AS flag, MAX(treatmentoffset) AS toff FROM eicu_crd.treatment WHERE treatmentstringid=502125 GROUP BY patientunitstayid
    UNION ALL SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid, 'trimethoprimsulfamethoxazole' AS typ,1 AS flag, MAX(treatmentoffset) AS toff FROM eicu_crd.treatment WHERE treatmentstringid=501264 GROUP BY patientunitstayid
    UNION ALL SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid, 'sulfonamide2' AS typ,1 AS flag, MAX(treatmentoffset) AS toff FROM eicu_crd.treatment WHERE treatmentstringid=501263 GROUP BY patientunitstayid
    UNION ALL SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid, 'macrolide' AS typ,1 AS flag, MAX(treatmentoffset) AS toff FROM eicu_crd.treatment WHERE treatmentstringid=501262 GROUP BY patientunitstayid
    UNION ALL SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid, 'for_transplantHIV2' AS typ,1 AS flag, MAX(treatmentoffset) AS toff FROM eicu_crd.treatment WHERE treatmentstringid=501261 GROUP BY patientunitstayid
    UNION ALL SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid, 'for_transplant' AS typ,1 AS flag, MAX(treatmentoffset) AS toff FROM eicu_crd.treatment WHERE treatmentstringid=501191 GROUP BY patientunitstayid
    UNION ALL SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid, 'immune_serum_globulin_human2' AS typ,1 AS flag, MAX(treatmentoffset) AS toff FROM eicu_crd.treatment WHERE treatmentstringid=501127 GROUP BY patientunitstayid
    UNION ALL SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid, 'IVIG_administration' AS typ,1 AS flag, MAX(treatmentoffset) AS toff FROM eicu_crd.treatment WHERE treatmentstringid=501126 GROUP BY patientunitstayid
    UNION ALL SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid, 'tacrolimus4' AS typ,1 AS flag, MAX(treatmentoffset) AS toff FROM eicu_crd.treatment WHERE treatmentstringid=501125 GROUP BY patientunitstayid
    UNION ALL SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid, 'sirolimus' AS typ,1 AS flag, MAX(treatmentoffset) AS toff FROM eicu_crd.treatment WHERE treatmentstringid=501124 GROUP BY patientunitstayid
    UNION ALL SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid, 'mycophenolate' AS typ,1 AS flag, MAX(treatmentoffset) AS toff FROM eicu_crd.treatment WHERE treatmentstringid=501123 GROUP BY patientunitstayid
    UNION ALL SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid, 'glatiramer' AS typ,1 AS flag, MAX(treatmentoffset) AS toff FROM eicu_crd.treatment WHERE treatmentstringid=501122 GROUP BY patientunitstayid
    UNION ALL SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid, 'cyclosporine4' AS typ,1 AS flag, MAX(treatmentoffset) AS toff FROM eicu_crd.treatment WHERE treatmentstringid=501121 GROUP BY patientunitstayid
    UNION ALL SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid, 'basiliximab3' AS typ,1 AS flag, MAX(treatmentoffset) AS toff FROM eicu_crd.treatment WHERE treatmentstringid=501120 GROUP BY patientunitstayid
    UNION ALL SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid, 'azathioprine1' AS typ,1 AS flag, MAX(treatmentoffset) AS toff FROM eicu_crd.treatment WHERE treatmentstringid=501119 GROUP BY patientunitstayid
    UNION ALL SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid, 'immunosuppressives' AS typ,1 AS flag, MAX(treatmentoffset) AS toff FROM eicu_crd.treatment WHERE treatmentstringid=501118 GROUP BY patientunitstayid
    UNION ALL SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid, 'sargramostim_Leukine_' AS typ,1 AS flag, MAX(treatmentoffset) AS toff FROM eicu_crd.treatment WHERE treatmentstringid=501117 GROUP BY patientunitstayid
    UNION ALL SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid, 'filgrastim_Neupogen' AS typ,1 AS flag, MAX(treatmentoffset) AS toff FROM eicu_crd.treatment WHERE treatmentstringid=501116 GROUP BY patientunitstayid
    UNION ALL SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid, 'erythropoietin' AS typ,1 AS flag, MAX(treatmentoffset) AS toff FROM eicu_crd.treatment WHERE treatmentstringid=501115 GROUP BY patientunitstayid
    UNION ALL SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid, 'darbepoetin_alfa' AS typ,1 AS flag, MAX(treatmentoffset) AS toff FROM eicu_crd.treatment WHERE treatmentstringid=501114 GROUP BY patientunitstayid
    UNION ALL SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid, 'allogeneic' AS typ,1 AS flag, MAX(treatmentoffset) AS toff FROM eicu_crd.treatment WHERE treatmentstringid=501113 GROUP BY patientunitstayid
    UNION ALL SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid, 'bone_marrow_transplantation' AS typ,1 AS flag, MAX(treatmentoffset) AS toff FROM eicu_crd.treatment WHERE treatmentstringid=501112 GROUP BY patientunitstayid
    UNION ALL SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid, 'heart_transplant' AS typ,1 AS flag, MAX(treatmentoffset) AS toff FROM eicu_crd.treatment WHERE treatmentstringid=500163 GROUP BY patientunitstayid
    UNION ALL SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid, 'routine' AS typ,1 AS flag, MAX(treatmentoffset) AS toff FROM eicu_crd.treatment WHERE treatmentstringid=500162 GROUP BY patientunitstayid
    UNION ALL SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid, 'emergent' AS typ,1 AS flag, MAX(treatmentoffset) AS toff FROM eicu_crd.treatment WHERE treatmentstringid=500161 GROUP BY patientunitstayid
    UNION ALL SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid, 'routine2' AS typ,1 AS flag, MAX(treatmentoffset) AS toff FROM eicu_crd.treatment WHERE treatmentstringid=500160 GROUP BY patientunitstayid
    UNION ALL SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid, 'emergent2' AS typ,1 AS flag, MAX(treatmentoffset) AS toff FROM eicu_crd.treatment WHERE treatmentstringid=500159 GROUP BY patientunitstayid
    UNION ALL SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid, 'CABG_and_valve' AS typ,1 AS flag, MAX(treatmentoffset) AS toff FROM eicu_crd.treatment WHERE treatmentstringid=500158 GROUP BY patientunitstayid
    UNION ALL SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid, 'CABG' AS typ,1 AS flag, MAX(treatmentoffset) AS toff FROM eicu_crd.treatment WHERE treatmentstringid=500157 GROUP BY patientunitstayid
),
-- Dialysis / CRRT related treatment
tx_dialysis AS (
    SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid, 'tunneled_catheter' AS typ,1 AS flag, MAX(treatmentoffset) AS toff FROM eicu_crd.treatment WHERE treatmentstringid=502162 GROUP BY patientunitstayid
    UNION ALL SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid, 'percutaneous_catheter' AS typ,1 AS flag, MAX(treatmentoffset) AS toff FROM eicu_crd.treatment WHERE treatmentstringid=502161 GROUP BY patientunitstayid
    UNION ALL SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid, 'insertion_of_venous_catheter_for_hemodialysis' AS typ,1 AS flag, MAX(treatmentoffset) AS toff FROM eicu_crd.treatment WHERE treatmentstringid=502160 GROUP BY patientunitstayid
    UNION ALL SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid, 'insertion_of_catheter_for_peritoneal_dialysis' AS typ,1 AS flag, MAX(treatmentoffset) AS toff FROM eicu_crd.treatment WHERE treatmentstringid=502159 GROUP BY patientunitstayid
    UNION ALL SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid, 'arteriovenous_shunt_for_renal_dialysis1' AS typ,1 AS flag, MAX(treatmentoffset) AS toff FROM eicu_crd.treatment WHERE treatmentstringid=502157 GROUP BY patientunitstayid
    UNION ALL SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid, 'dialysis1' AS typ,1 AS flag, MAX(treatmentoffset) AS toff FROM eicu_crd.treatment WHERE treatmentstringid=502042 GROUP BY patientunitstayid
    UNION ALL SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid, 'for_chronic_renal_failure1' AS typ,1 AS flag, MAX(treatmentoffset) AS toff FROM eicu_crd.treatment WHERE treatmentstringid=502009 GROUP BY patientunitstayid
    UNION ALL SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid, 'for_acute_renal_failure1' AS typ,1 AS flag, MAX(treatmentoffset) AS toff FROM eicu_crd.treatment WHERE treatmentstringid=502008 GROUP BY patientunitstayid
    UNION ALL SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid, 'emergent1' AS typ,1 AS flag, MAX(treatmentoffset) AS toff FROM eicu_crd.treatment WHERE treatmentstringid=502007 GROUP BY patientunitstayid
    UNION ALL SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid, 'ultrafiltration_fluid_removal_only' AS typ,1 AS flag, MAX(treatmentoffset) AS toff FROM eicu_crd.treatment WHERE treatmentstringid=502006 GROUP BY patientunitstayid
    UNION ALL SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid, 'SLED' AS typ,1 AS flag, MAX(treatmentoffset) AS toff FROM eicu_crd.treatment WHERE treatmentstringid=502005 GROUP BY patientunitstayid
    UNION ALL SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid, 'with_cannula_placement' AS typ,1 AS flag, MAX(treatmentoffset) AS toff FROM eicu_crd.treatment WHERE treatmentstringid=502004 GROUP BY patientunitstayid
    UNION ALL SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid, 'for_chronic_renal_failure2' AS typ,1 AS flag, MAX(treatmentoffset) AS toff FROM eicu_crd.treatment WHERE treatmentstringid=502003 GROUP BY patientunitstayid
    UNION ALL SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid, 'for_acute_renal_failure' AS typ,1 AS flag, MAX(treatmentoffset) AS toff FROM eicu_crd.treatment WHERE treatmentstringid=502002 GROUP BY patientunitstayid
    UNION ALL SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid, 'emergent2' AS typ,1 AS flag, MAX(treatmentoffset) AS toff FROM eicu_crd.treatment WHERE treatmentstringid=502001 GROUP BY patientunitstayid
    UNION ALL SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid, 'peritoneal_dialysis' AS typ,1 AS flag, MAX(treatmentoffset) AS toff FROM eicu_crd.treatment WHERE treatmentstringid=502000 GROUP BY patientunitstayid
    UNION ALL SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid, 'tunneled_catheter2' AS typ,1 AS flag, MAX(treatmentoffset) AS toff FROM eicu_crd.treatment WHERE treatmentstringid=501999 GROUP BY patientunitstayid
    UNION ALL SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid, 'percutaneous_catheter2' AS typ,1 AS flag, MAX(treatmentoffset) AS toff FROM eicu_crd.treatment WHERE treatmentstringid=501998 GROUP BY patientunitstayid
    UNION ALL SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid, 'insertion_of_venous_catheter_for_hemodialysis2' AS typ,1 AS flag, MAX(treatmentoffset) AS toff FROM eicu_crd.treatment WHERE treatmentstringid=501997 GROUP BY patientunitstayid
    UNION ALL SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid, 'for_chronic_renal_failure' AS typ,1 AS flag, MAX(treatmentoffset) AS toff FROM eicu_crd.treatment WHERE treatmentstringid=501996 GROUP BY patientunitstayid
    UNION ALL SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid, 'for_acute_renal_failure2' AS typ,1 AS flag, MAX(treatmentoffset) AS toff FROM eicu_crd.treatment WHERE treatmentstringid=501995 GROUP BY patientunitstayid
    UNION ALL SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid, 'emergent' AS typ,1 AS flag, MAX(treatmentoffset) AS toff FROM eicu_crd.treatment WHERE treatmentstringid=501994 GROUP BY patientunitstayid
    UNION ALL SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid, 'hemodialysis' AS typ,1 AS flag, MAX(treatmentoffset) AS toff FROM eicu_crd.treatment WHERE treatmentstringid=501993 GROUP BY patientunitstayid
    UNION ALL SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid, 'C_V_V_H_D' AS typ,1 AS flag, MAX(treatmentoffset) AS toff FROM eicu_crd.treatment WHERE treatmentstringid=501992 GROUP BY patientunitstayid
    UNION ALL SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid, 'C_V_V_H' AS typ,1 AS flag, MAX(treatmentoffset) AS toff FROM eicu_crd.treatment WHERE treatmentstringid=501991 GROUP BY patientunitstayid
    UNION ALL SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid, 'C_A_V_H_D' AS typ,1 AS flag, MAX(treatmentoffset) AS toff FROM eicu_crd.treatment WHERE treatmentstringid=501990 GROUP BY patientunitstayid
    UNION ALL SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid, 'arteriovenous_shunt_for_renal_dialysis' AS typ,1 AS flag, MAX(treatmentoffset) AS toff FROM eicu_crd.treatment WHERE treatmentstringid=501989 GROUP BY patientunitstayid
    UNION ALL SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid, 'dialysis' AS typ,1 AS flag, MAX(treatmentoffset) AS toff FROM eicu_crd.treatment WHERE treatmentstringid=502028 GROUP BY patientunitstayid
),
-- CMV comorbidity
com_cmv AS (
    SELECT DISTINCT ON(patientunitstayid) diagnosisid, patientunitstayid, 1 AS CMV
    FROM eicu_crd.diagnosis AS dia,
    (
        SELECT codeid, icd_code, original_icdcode, diagnosisstring,1 AS FLAG
        FROM "dictionary".d_icd_diagnosis
        WHERE codeid in ('801552','801551','801553','802064','802236')
    ) AS did
    WHERE CASE
        WHEN did.original_icdcode IS NULL THEN dia.diagnosisstring = did.diagnosisstring
        ELSE dia.icd9code LIKE CONCAT('%', did.original_icdcode, '%')
    END
),
-- Mechanical ventilation
vent AS (
    SELECT rc.patientunitstayid, 1 AS ventilation, rc.respcarestatusoffset AS ventilation_first_time
    FROM eicu_crd.respiratorycare rc
    WHERE rc.currenthistoryseqnum = 1
)
-- Final combined output
SELECT DISTINCT
    b.patientunitstayid,
    b.uniquepid,
    demo.age,
    demo.gender,
    demo.height,
    demo.race,
    demo.weight,
    demo.unittype,
    demo.hospitaladmittime24,
    demo.hospitaladmitoffset,
    demo.hospitaldischargetime24,
    demo.hospitaldischargeoffset,
    demo.unitadmittime24,
    demo.unitdischargetime24,
    demo.unitdischargeoffset,
    demo.hospitaldischargeyear,
    demo.hospitaldischargestatus,
    demo.hosplosday,
    demo.unitlosday,
    demo.unitadmitsource,
    demo.unitdischargelocation,
    demo.unitdischargestatus,
    demo.unitstaytype,
    -- 24h lab panel
    lab_24h.lab24Hours_WBC_x_1000,
    lab_24h.lab24Hours_WBC_x_1000_uom,
    lab_24h.lab24Hours_RBC,
    lab_24h.lab24Hours_RBC_uom,
    lab_24h.lab24Hours_platelets_x_1000,
    lab_24h.lab24Hours_platelets_x_1000_uom,
    lab_24h.lab24Hours_Hgb,
    lab_24h.lab24Hours_Hgb_uom,
    lab_24h.lab24Hours_lymphs,
    lab_24h.lab24Hours_lymphs_uom,
    lab_24h.lab24Hours_monos,
    lab_24h.lab24Hours_monos_uom,
    lab_24h.lab24Hours_CRP,
    lab_24h.lab24Hours_CRP_uom,
    lab_24h.lab24Hours_CRPhs,
    lab_24h.lab24Hours_CRPhs_uom,
    lab_24h.lab24Hours_basos,
    lab_24h.lab24Hours_basos_uom,
    lab_24h.lab24Hours_eos,
    lab_24h.lab24Hours_eos_uom,
    lab_24h.lab24Hours_polys,
    lab_24h.lab24Hours_polys_uom,
    lab_24h.lab24Hours_FiO2,
    lab_24h.lab24Hours_FiO2_uom,
    lab_24h.lab24Hours_paO2,
    lab_24h.lab24Hours_paO2_uom,
    lab_24h.lab24Hours_Peak_AirwayPressure,
    lab_24h.lab24Hours_Peak_AirwayPressure_uom,
    lab_24h.lab24Hours_LDH,
    lab_24h.lab24Hours_LDH_uom,
    -- Creatinine
    lab_creatinine.first_creatinine,
    lab_creatinine.first_creatinine_uom,
    lab_creatinine.first_creatinine_min_labresultoffset,
    -- CD4
    lab_cd4.first_cd_4,
    lab_cd4.first_cd_4_uom,
    lab_cd_4.first_cd_4_min_labresultoffset,
    -- Ventilation
    COALESCE(vent.ventilation,0) AS ventilation,
    vent.ventilation_first_time,
    -- CMV comorbidity
    COALESCE(com_cmv.CMV,0) AS CMV
FROM basic b
LEFT JOIN demographics demo ON b.patientunitstayid = demo.patientunitstayid
LEFT JOIN lab_24h ON b.patientunitstayid = lab_24h.patientunitstayid
LEFT JOIN lab_creatinine ON b.patientunitstayid = lab_creatinine.patientunitstayid
LEFT JOIN lab_cd4 ON b.patientunitstayid = lab_cd4.patientunitstayid
LEFT JOIN vent ON b.patientunitstayid = vent.patientunitstayid
LEFT JOIN com_cmv ON b.patientunitstayid = com_cmv.patientunitstayid
ORDER BY b.patientunitstayid;