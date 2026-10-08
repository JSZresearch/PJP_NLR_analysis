WITH basic AS (
    WITH
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
        AND (
            pat.patientunitstayid IN (SELECT patientunitstayid FROM included_disease1)
            OR pat.patientunitstayid IN (SELECT patientunitstayid FROM included_disease2)
        )
),
patient_discharge_offset AS (
    SELECT patientunitstayid, unitdischargeoffset
    FROM eicu_crd.patient
),
cbc_combined AS (
    SELECT
        wbc.patientunitstayid,
        wbc.labresult AS WBC_x_1000,
        wbc.labmeasurenamesystem AS WBC_x_1000_uom,
        polys.labresult AS polys_pct,
        polys.labmeasurenamesystem AS polys_pct_uom,
        lymphs.labresult AS lymphs_pct,
        lymphs.labmeasurenamesystem AS lymphs_pct_uom,
        monos.labresult AS monos_pct,
        monos.labmeasurenamesystem AS monos_pct_uom,
        wbc.labresultoffset AS cbc_offset,
        ROUND(polys.labresult * wbc.labresult, 2) AS neut_abs,
        ROUND(lymphs.labresult * wbc.labresult, 2) AS lymph_abs,
        ROUND(monos.labresult * wbc.labresult, 2) AS mono_abs,
        ROUND(
            polys.labresult * wbc.labresult
            / NULLIF(lymphs.labresult * wbc.labresult, 0),
            3
        ) AS NLR,
        ROW_NUMBER() OVER(PARTITION BY wbc.patientunitstayid ORDER BY wbc.labresultoffset ASC) AS rn
    FROM eicu_crd.lab wbc
    INNER JOIN eicu_crd.lab polys
        ON wbc.patientunitstayid = polys.patientunitstayid AND wbc.labresultoffset = polys.labresultoffset
    INNER JOIN eicu_crd.lab lymphs
        ON wbc.patientunitstayid = lymphs.patientunitstayid AND wbc.labresultoffset = lymphs.labresultoffset
    INNER JOIN eicu_crd.lab monos
        ON wbc.patientunitstayid = monos.patientunitstayid AND wbc.labresultoffset = monos.labresultoffset
    INNER JOIN patient_discharge_offset pd
        ON wbc.patientunitstayid = pd.patientunitstayid
    WHERE
        wbc.labnameid = 100157
        AND polys.labnameid = 100005
        AND lymphs.labnameid = 100003
        AND monos.labnameid = 100004
        AND wbc.labresultoffset > 0
        AND wbc.labresultoffset <= pd.unitdischargeoffset
),
RBC AS(
    SELECT patientunitstayid, labresult AS first_RBC, labmeasurenamesystem AS first_RBC_uom, labresultoffset AS first_RBC_min_labresultoffset
    FROM (
        SELECT patientunitstayid,labresult,labmeasurenamesystem,labresultoffset,
        ROW_NUMBER() OVER(PARTITION BY patientunitstayid ORDER BY labresultoffset ASC) AS rn
        FROM eicu_crd.lab
        INNER JOIN patient_discharge_offset pd ON lab.patientunitstayid=pd.patientunitstayid
        WHERE labresultoffset > 0 AND labresultoffset <= pd.unitdischargeoffset AND labnameid IN (100108)
    ) t
    WHERE rn=1
),
platelets_x_1000 AS(
    SELECT patientunitstayid, labresult AS first_platelets_x_1000, labmeasurenamesystem AS first_platelets_x_1000_uom, labresultoffset AS first_platelets_x_1000_min_labresultoffset
    FROM (
        SELECT patientunitstayid,labresult,labmeasurenamesystem,labresultoffset,
        ROW_NUMBER() OVER(PARTITION BY patientunitstayid ORDER BY labresultoffset ASC) AS rn
        FROM eicu_crd.lab
        INNER JOIN patient_discharge_offset pd ON lab.patientunitstayid=pd.patientunitstayid
        WHERE labresultoffset > 0 AND labresultoffset <= pd.unitdischargeoffset AND labnameid IN (100094)
    ) t
    WHERE rn=1
),
Hgb AS(
    SELECT patientunitstayid, labresult AS first_Hgb, labmeasurenamesystem AS first_Hgb_uom, labresultoffset AS first_Hgb_min_labresultoffset
    FROM (
        SELECT patientunitstayid,labresult,labmeasurenamesystem,labresultoffset,
        ROW_NUMBER() OVER(PARTITION BY patientunitstayid ORDER BY labresultoffset ASC) AS rn
        FROM eicu_crd.lab
        INNER JOIN patient_discharge_offset pd ON lab.patientunitstayid=pd.patientunitstayid
        WHERE labresultoffset > 0 AND labresultoffset <= pd.unitdischargeoffset AND labnameid IN (100061)
    ) t
    WHERE rn=1
),
FiO2 AS(
    SELECT patientunitstayid, labresult AS first_FiO2, labmeasurenamesystem AS first_FiO2_uom, labresultoffset AS first_FiO2_min_labresultoffset
    FROM (
        SELECT patientunitstayid,labresult,labmeasurenamesystem,labresultoffset,
        ROW_NUMBER() OVER(PARTITION BY patientunitstayid ORDER BY labresultoffset ASC) AS rn
        FROM eicu_crd.lab
        INNER JOIN patient_discharge_offset pd ON lab.patientunitstayid=pd.patientunitstayid
        WHERE labresultoffset > 0 AND labresultoffset <= pd.unitdischargeoffset AND labnameid IN (100049)
    ) t
    WHERE rn=1
),
paO2 AS(
    SELECT patientunitstayid, labresult AS first_paO2, labmeasurenamesystem AS first_paO2_uom, labresultoffset AS first_paO2_min_labresultoffset
    FROM (
        SELECT patientunitstayid,labresult,labmeasurenamesystem,labresultoffset,
        ROW_NUMBER() OVER(PARTITION BY patientunitstayid ORDER BY labresultoffset ASC) AS rn
        FROM eicu_crd.lab
        INNER JOIN patient_discharge_offset pd ON lab.patientunitstayid=pd.patientunitstayid
        WHERE labresultoffset > 0 AND labresultoffset <= pd.unitdischargeoffset AND labnameid IN (100087)
    ) t
    WHERE rn=1
),
LDH AS(
    SELECT patientunitstayid, labresult AS first_LDH, labmeasurenamesystem AS first_LDH_uom, labresultoffset AS first_LDH_min_labresultoffset
    FROM (
        SELECT patientunitstayid,labresult,labmeasurenamesystem,labresultoffset,
        ROW_NUMBER() OVER(PARTITION BY patientunitstayid ORDER BY labresultoffset ASC) AS rn
        FROM eicu_crd.lab
        INNER JOIN patient_discharge_offset pd ON lab.patientunitstayid=pd.patientunitstayid
        WHERE labresultoffset > 0 AND labresultoffset <= pd.unitdischargeoffset AND labnameid IN (100067)
    ) t
    WHERE rn=1
),
creatinine AS(
    SELECT patientunitstayid, labresult AS first_creatinine, labmeasurenamesystem AS first_creatinine_uom, labresultoffset AS first_creatinine_min_labresultoffset
    FROM (
        SELECT patientunitstayid,labresult,labmeasurenamesystem,labresultoffset,
        ROW_NUMBER() OVER(PARTITION BY patientunitstayid ORDER BY labresultoffset ASC) AS rn
        FROM eicu_crd.lab
        INNER JOIN patient_discharge_offset pd ON lab.patientunitstayid=pd.patientunitstayid
        WHERE labresultoffset > 0 AND labresultoffset <= pd.unitdischargeoffset AND labnameid IN (100036)
    ) t
    WHERE rn=1
),
albumin AS(
    SELECT patientunitstayid, labresult AS first_albumin, labmeasurenamesystem AS first_albumin_uom, labresultoffset AS first_albumin_min_labresultoffset
    FROM (
        SELECT patientunitstayid,labresult,labmeasurenamesystem,labresultoffset,
        ROW_NUMBER() OVER(PARTITION BY patientunitstayid ORDER BY labresultoffset ASC) AS rn
        FROM eicu_crd.lab
        INNER JOIN patient_discharge_offset pd ON lab.patientunitstayid=pd.patientunitstayid
        WHERE labresultoffset > 0 AND labresultoffset <= pd.unitdischargeoffset AND labnameid IN (100009)
    ) t
    WHERE rn=1
),
cd_4 AS(
    SELECT patientunitstayid, labresult AS first_cd_4, labmeasurenamesystem AS first_cd_4_uom, labresultoffset AS first_cd_4_min_labresultoffset
    FROM (
        SELECT patientunitstayid,labresult,labmeasurenamesystem,labresultoffset,
        ROW_NUMBER() OVER(PARTITION BY patientunitstayid ORDER BY labresultoffset ASC) AS rn
        FROM eicu_crd.lab
        INNER JOIN patient_discharge_offset pd ON lab.patientunitstayid=pd.patientunitstayid
        WHERE labresultoffset > 0 AND labresultoffset <= pd.unitdischargeoffset AND labnameid IN (100029)
    ) t
    WHERE rn=1
),
htn AS(
    SELECT DISTINCT ON(patientunitstayid) diagnosisid,patientunitstayid,dia.diagnosisstring,icd9code,codeid,original_icdcode,1 AS FLAG
    FROM eicu_crd.diagnosis AS dia,
            (SELECT codeid,icd_code,original_icdcode,diagnosisstring FROM "dictionary".d_icd_diagnosis WHERE codeid in ('800329','801748','800079','800080')) AS did
    WHERE True
            AND (CASE
                WHEN did.original_icdcode IS NULL THEN dia.diagnosisstring = did.diagnosisstring
                ELSE dia.icd9code LIKE CONCAT('%', did.original_icdcode, '%')
            END)
),
Diabetes AS(
    SELECT DISTINCT ON(patientunitstayid) diagnosisid,patientunitstayid,dia.diagnosisstring,icd9code,codeid,original_icdcode,1 AS FLAG
    FROM eicu_crd.diagnosis AS dia,
            (SELECT codeid,icd_code,original_icdcode,diagnosisstring FROM "dictionary".d_icd_diagnosis WHERE codeid in ('800091','800429','801220','800162','800732','800264','801496','800427','801497','800733','801221','800163','800430')) AS did
    WHERE True
            AND (CASE
                WHEN did.original_icdcode IS NULL THEN dia.diagnosisstring = did.diagnosisstring
                ELSE dia.icd9code LIKE CONCAT('%', did.original_icdcode, '%')
            END)
),
MACE AS(
    SELECT DISTINCT ON(patientunitstayid) diagnosisid,patientunitstayid,dia.diagnosisstring,icd9code,codeid,original_icdcode,1 AS FLAG
    FROM eicu_crd.diagnosis AS dia,
            (SELECT codeid,icd_code,original_icdcode,diagnosisstring FROM "dictionary".d_icd_diagnosis WHERE codeid in ('800666','800684','800982','801947','800321','800663','801400','801155','800504','801193','800584','800680','800260','800323','800330','800393','800124','800836','800248','800635','800357','800524','800759','801355','800452','800492','801859','800681','800837','800261','800249','800322','801401','800505','800585','800358','800525','800125','800636','800667','800324','800331','800394','800760','801356','800453','800320')) AS did
    WHERE True
            AND (CASE
                WHEN did.original_icdcode IS NULL THEN dia.diagnosisstring = did.diagnosisstring
                ELSE dia.icd9code LIKE CONCAT('%', did.original_icdcode, '%')
            END)
),
liver AS(
    SELECT DISTINCT ON(patientunitstayid) diagnosisid,patientunitstayid,dia.diagnosisstring,icd9code,codeid,original_icdcode,1 AS FLAG
    FROM eicu_crd.diagnosis AS dia,
            (SELECT codeid,icd_code,original_icdcode,diagnosisstring FROM "dictionary".d_icd_diagnosis WHERE codeid in ('800675','800342','800506','801389','800652','800509','800602','801581','801967','800676','800343','800507','800752','801966','800510')) AS did
    WHERE True
            AND (CASE
                WHEN did.original_icdcode IS NULL THEN dia.diagnosisstring = did.diagnosisstring
                ELSE dia.icd9code LIKE CONCAT('%', did.original_icdcode, '%')
            END)
),
Renal AS(
    SELECT DISTINCT ON(patientunitstayid) diagnosisid,patientunitstayid,dia.diagnosisstring,icd9code,codeid,original_icdcode,1 AS FLAG
    FROM eicu_crd.diagnosis AS dia,
            (SELECT codeid,icd_code,original_icdcode,diagnosisstring FROM "dictionary".d_icd_diagnosis WHERE codeid in ('801039','801033','800117','800312','800973','800270','801816','801040','801034','800118','800313','800974','800271')) AS did
    WHERE True
            AND (CASE
                WHEN did.original_icdcode IS NULL THEN dia.diagnosisstring = did.diagnosisstring
                ELSE dia.icd9code LIKE CONCAT('%', did.original_icdcode, '%')
            END)
),
pulmonary AS(
    SELECT DISTINCT ON(patientunitstayid) diagnosisid,patientunitstayid,dia.diagnosisstring,icd9code,codeid,original_icdcode,1 AS FLAG
    FROM eicu_crd.diagnosis AS dia,
            (SELECT codeid,icd_code,original_icdcode,diagnosisstring FROM "dictionary".d_icd_diagnosis WHERE codeid in ('800070','800108','801176','801177','800109','800071')) AS did
    WHERE True
            AND (CASE
                WHEN did.original_icdcode IS NULL THEN dia.diagnosisstring = did.diagnosisstring
                ELSE dia.icd9code LIKE CONCAT('%', did.original_icdcode, '%')
            END)
),
Malignant AS(
    SELECT DISTINCT ON(patientunitstayid) diagnosisid,patientunitstayid,dia.diagnosisstring,icd9code,codeid,original_icdcode,1 AS FLAG
    FROM eicu_crd.diagnosis AS dia,
            (SELECT codeid,icd_code,original_icdcode,diagnosisstring FROM "dictionary".d_icd_diagnosis WHERE codeid in ('801633','800158','800454','800578','801035','800545','801329','801099','800519','801684','801991','800695','800739','801593','801253','800520','801685','800132','801272','801304','801735','800515','802461','800778','800600','801186','800682','801969','800728','800735','801460','800787','802208','800694','801992','800696','800915','802336','801110','801406','802364','800740','801594','801036','801017','801123','801227','801228','802409','801379','801386','801302','801540','801723','801563','801582','801584','800088','801509','801643','801599','801100','801855','801091','800572','800336','801491','801598','801303','801734','801697','801620','800777','801185','801109','801405','801459','800693','800364','800741','801113','802150','800340','800766','800378','800576','801958','801197','801052','800688','801121','802313','800174','801320','800351','802107','801288','801611','801038','800583','800692','800579','801330','801934','802187','801037','800413','802108','800407','801456','800365','800742','801114','800542','802151','800341','801634','800767','800159','800379','800577','801959','801053','801198','800547','800689','801122','802314','800455','800240','801289','801612','801254','801273','801856','801092','800812','800573','800337','801621','801492','800239')) AS did
    WHERE True
            AND (CASE
                WHEN did.original_icdcode IS NULL THEN dia.diagnosisstring = did.diagnosisstring
                ELSE dia.icd9code LIKE CONCAT('%', did.original_icdcode, '%')
            END)
),
transplant AS(
    SELECT DISTINCT ON(patientunitstayid) diagnosisid,patientunitstayid,dia.diagnosisstring,icd9code,codeid,original_icdcode,1 AS FLAG
    FROM eicu_crd.diagnosis AS dia,
            (SELECT codeid,icd_code,original_icdcode,diagnosisstring FROM "dictionary".d_icd_diagnosis WHERE codeid in ('801950','800570','800748','801894','801880','801251','800826','800957','801203','800956','801202')) AS did
    WHERE True
            AND (CASE
                WHEN did.original_icdcode IS NULL THEN dia.diagnosisstring = did.diagnosisstring
                ELSE dia.icd9code LIKE CONCAT('%', did.original_icdcode, '%')
            END)
),
HIV AS(
    SELECT DISTINCT ON(patientunitstayid) diagnosisid,patientunitstayid,dia.diagnosisstring,icd9code,codeid,original_icdcode,1 AS FLAG
    FROM eicu_crd.diagnosis AS dia,
            (SELECT codeid,icd_code,original_icdcode,diagnosisstring FROM "dictionary".d_icd_diagnosis WHERE codeid in ('801204','801205','800233','800234')) AS did
    WHERE True
            AND (CASE
                WHEN did.original_icdcode IS NULL THEN dia.diagnosisstring = did.diagnosisstring
                ELSE dia.icd9code LIKE CONCAT('%', did.original_icdcode, '%')
            END)
),
CMV AS(
    SELECT DISTINCT ON(patientunitstayid) diagnosisid,patientunitstayid,dia.diagnosisstring,icd9code,codeid,original_icdcode,1 AS FLAG
    FROM eicu_crd.diagnosis AS dia,
            (SELECT codeid,icd_code,original_icdcode,diagnosisstring FROM "dictionary".d_icd_diagnosis WHERE codeid in ('801552','801551','801553','802064','802236')) AS did
    WHERE True
            AND (CASE
                WHEN did.original_icdcode IS NULL THEN dia.diagnosisstring = did.diagnosisstring
                ELSE dia.icd9code LIKE CONCAT('%', did.original_icdcode, '%')
            END)
),
-- ===================== 药物CTE =====================
Glu AS (
    SELECT DISTINCT ON(medication.patientunitstayid) patientunitstayid,1 AS FLAG,drugstartoffset,drugorderoffset
    FROM eicu_crd.medication
    WHERE TRUE
        AND drugnameid in ('300436','300437','300438','300439','300678','300679','300680','300681','300890','300891','300892','300893','300894','300895','300896','300897','300029','301188','301189','301190','301191','301192','301193','301194','301195')
),
Vasopressor AS (
    SELECT DISTINCT ON(medication.patientunitstayid) patientunitstayid,1 AS FLAG,drugstartoffset,drugorderoffset
    FROM eicu_crd.medication
    WHERE TRUE
        AND drugnameid in ('300001','300130','300140','300166','300352','300509','300528','300529','300803','300804','300805','300806','300807','300808','300809','300810','300811','300812','300813','301018','301019','301020','301021','301022','301023','301024','301025','301103','301104','301105','301106','301107','301108','301198','301376')
        AND drugstartoffset >0
),
resp AS (
    SELECT rc.patientunitstayid,
           rc.currenthistoryseqnum AS ventilation,
           rc.respcarestatusoffset AS ventilation_first_time
    FROM eicu_crd.respiratorycare rc
    WHERE rc.currenthistoryseqnum = 1
),
renal_dialysis1 AS(
SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid,1 AS FLAG,treatmentoffset
FROM eicu_crd.treatment
WHERE TRUE
    AND treatmentstringid in (502162)
),
renal_dialysis2 AS(
SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid,1 AS FLAG,treatmentoffset
FROM eicu_crd.treatment
WHERE TRUE
    AND treatmentstringid in (502161)
),
renal_dialysis3 AS(
SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid,1 AS FLAG,treatmentoffset
FROM eicu_crd.treatment
WHERE TRUE
    AND treatmentstringid in (502160)
),
renal_dialysis4 AS(
SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid,1 AS FLAG,treatmentoffset
FROM eicu_crd.treatment
WHERE TRUE
    AND treatmentstringid in (502159)
),
renal_dialysis5 AS(
SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid,1 AS FLAG,treatmentoffset
FROM eicu_crd.treatment
WHERE TRUE
    AND treatmentstringid in (502157)
),
renal_dialysis6 AS(
SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid,1 AS FLAG,treatmentoffset
FROM eicu_crd.treatment
WHERE TRUE
    AND treatmentstringid in (502042)
),
renal_dialysis7 AS(
SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid,1 AS FLAG,treatmentoffset
FROM eicu_crd.treatment
WHERE TRUE
    AND treatmentstringid in (502009)
),
renal_dialysis8 AS(
SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid,1 AS FLAG,treatmentoffset
FROM eicu_crd.treatment
WHERE TRUE
    AND treatmentstringid in (502008)
),
renal_dialysis9 AS(
SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid,1 AS FLAG,treatmentoffset
FROM eicu_crd.treatment
WHERE TRUE
    AND treatmentstringid in (502007)
),
renal_dialysis10 AS(
SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid,1 AS FLAG,treatmentoffset
FROM eicu_crd.treatment
WHERE TRUE
    AND treatmentstringid in (502006)
),
renal_dialysis11 AS(
SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid,1 AS FLAG,treatmentoffset
FROM eicu_crd.treatment
WHERE TRUE
    AND treatmentstringid in (502005)
),
renal_dialysis12 AS(
SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid,1 AS FLAG,treatmentoffset
FROM eicu_crd.treatment
WHERE TRUE
    AND treatmentstringid in (502004)
),
renal_dialysis13 AS(
SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid,1 AS FLAG,treatmentoffset
FROM eicu_crd.treatment
WHERE TRUE
    AND treatmentstringid in (502003)
),
renal_dialysis14 AS(
SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid,1 AS FLAG,treatmentoffset
FROM eicu_crd.treatment
WHERE TRUE
    AND treatmentstringid in (502002)
),
renal_dialysis15 AS(
SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid,1 AS FLAG,treatmentoffset
FROM eicu_crd.treatment
WHERE TRUE
    AND treatmentstringid in (502001)
),
renal_dialysis16 AS(
SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid,1 AS FLAG,treatmentoffset
FROM eicu_crd.treatment
WHERE TRUE
    AND treatmentstringid in (502000)
),
renal_dialysis17 AS(
SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid,1 AS FLAG,treatmentoffset
FROM eicu_crd.treatment
WHERE TRUE
    AND treatmentstringid in (501999)
),
renal_dialysis18 AS(
SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid,1 AS FLAG,treatmentoffset
FROM eicu_crd.treatment
WHERE TRUE
    AND treatmentstringid in (501998)
),
renal_dialysis19 AS(
SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid,1 AS FLAG,treatmentoffset
FROM eicu_crd.treatment
WHERE TRUE
    AND treatmentstringid in (501997)
),
renal_dialysis20 AS(
SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid,1 AS FLAG,treatmentoffset
FROM eicu_crd.treatment
WHERE TRUE
    AND treatmentstringid in (501996)
),
renal_dialysis21 AS(
SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid,1 AS FLAG,treatmentoffset
FROM eicu_crd.treatment
WHERE TRUE
    AND treatmentstringid in (501995)
),
renal_dialysis22 AS(
SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid,1 AS FLAG,treatmentoffset
FROM eicu_crd.treatment
WHERE TRUE
    AND treatmentstringid in (501994)
),
renal_dialysis23 AS(
SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid,1 AS FLAG,treatmentoffset
FROM eicu_crd.treatment
WHERE TRUE
    AND treatmentstringid in (501993)
),
renal_dialysis24 AS(
SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid,1 AS FLAG,treatmentoffset
FROM eicu_crd.treatment
WHERE TRUE
    AND treatmentstringid in (501992)
),
renal_dialysis25 AS(
SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid,1 AS FLAG,treatmentoffset
FROM eicu_crd.treatment
WHERE TRUE
    AND treatmentstringid in (501991)
),
renal_dialysis26 AS(
SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid,1 AS FLAG,treatmentoffset
FROM eicu_crd.treatment
WHERE TRUE
    AND treatmentstringid in (501990)
),
renal_dialysis27 AS(
SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid,1 AS FLAG,treatmentoffset
FROM eicu_crd.treatment
WHERE TRUE
    AND treatmentstringid in (501989)
),
dialysis AS(
SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid,1 AS FLAG,treatmentoffset
FROM eicu_crd.treatment
WHERE TRUE
    AND treatmentstringid in (502028)
),
x1sulfonamide AS(
SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid,1 AS FLAG,treatmentoffset
FROM eicu_crd.treatment
WHERE TRUE
    AND treatmentstringid in (502416)
),
x3sulfonamide AS(
SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid,1 AS FLAG,treatmentoffset
FROM eicu_crd.treatment
WHERE TRUE
    AND treatmentstringid in (502152)
),
x4sulfonamide AS(
SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid,1 AS FLAG,treatmentoffset
FROM eicu_crd.treatment
WHERE TRUE
    AND treatmentstringid in (501724)
),
x5sulfonamide AS(
SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid,1 AS FLAG,treatmentoffset
FROM eicu_crd.treatment
WHERE TRUE
    AND treatmentstringid in (501723)
),
x6sulfonamide AS(
SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid,1 AS FLAG,treatmentoffset
FROM eicu_crd.treatment
WHERE TRUE
    AND treatmentstringid in (501722)
),
x7sulfonamide AS(
SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid,1 AS FLAG,treatmentoffset
FROM eicu_crd.treatment
WHERE TRUE
    AND treatmentstringid in (501326)
),
x8sulfonamide AS(
SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid,1 AS FLAG,treatmentoffset
FROM eicu_crd.treatment
WHERE TRUE
    AND treatmentstringid in (501325)
),
x9sulfonamide AS(
SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid,1 AS FLAG,treatmentoffset
FROM eicu_crd.treatment
WHERE TRUE
    AND treatmentstringid in (501324)
),
x10sulfonamide AS(
SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid,1 AS FLAG,treatmentoffset
FROM eicu_crd.treatment
WHERE TRUE
    AND treatmentstringid in (501323)
),
x11sulfonamide AS(
SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid,1 AS FLAG,treatmentoffset
FROM eicu_crd.treatment
WHERE TRUE
    AND treatmentstringid in (501183)
),
x12sulfonamide AS(
SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid,1 AS FLAG,treatmentoffset
FROM eicu_crd.treatment
WHERE TRUE
    AND treatmentstringid in (500875)
),
x13sulfonamide AS(
SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid,1 AS FLAG,treatmentoffset
FROM eicu_crd.treatment
WHERE TRUE
    AND treatmentstringid in (500464)
),
x14sulfonamide AS(
SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid,1 AS FLAG,treatmentoffset
FROM eicu_crd.treatment
WHERE TRUE
    AND treatmentstringid in (500463)
),
x15sulfonamide AS(
SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid,1 AS FLAG,treatmentoffset
FROM eicu_crd.treatment
WHERE TRUE
    AND treatmentstringid in (500462)
),
x2sulfonamide AS(
SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid,1 AS FLAG,treatmentoffset
FROM eicu_crd.treatment
WHERE TRUE
    AND treatmentstringid in (500461)
),
caspofungin AS(
SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid,1 AS FLAG,treatmentoffset
FROM eicu_crd.treatment
WHERE TRUE
    AND treatmentstringid in (502347)
),
caspofungin2 AS(
SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid,1 AS FLAG,treatmentoffset
FROM eicu_crd.treatment
WHERE TRUE
    AND treatmentstringid in (501750)
),
caspofungin3 AS(
SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid,1 AS FLAG,treatmentoffset
FROM eicu_crd.treatment
WHERE TRUE
    AND treatmentstringid in (501187)
),
atovaquone AS(
SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid,1 AS FLAG,treatmentoffset
FROM eicu_crd.treatment
WHERE TRUE
    AND treatmentstringid in (501797)
),
atovaquone2 AS(
SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid,1 AS FLAG,treatmentoffset
FROM eicu_crd.treatment
WHERE TRUE
    AND treatmentstringid in (501241)
),
atovaquone3 AS(
SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid,1 AS FLAG,treatmentoffset
FROM eicu_crd.treatment
WHERE TRUE
    AND treatmentstringid in (501179)
),
primaquine AS(
SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid,1 AS FLAG,treatmentoffset
FROM eicu_crd.treatment
WHERE TRUE
    AND treatmentstringid in (501802)
),
primaquine2 AS(
SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid,1 AS FLAG,treatmentoffset
FROM eicu_crd.treatment
WHERE TRUE
    AND treatmentstringid in (501246)
),
pentamidine AS(
SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid,1 AS FLAG,treatmentoffset
FROM eicu_crd.treatment
WHERE TRUE
    AND treatmentstringid in (501801)
),
pentamidine2 AS(
SELECT DISTINCT ON(treatment.patientunitstayid) patientunitstayid,1 AS FLAG,treatmentoffset
FROM eicu_crd.treatment
WHERE TRUE
    AND treatmentstringid in (501245)
),
-- ===================== 评分系统CTE =====================
sofa AS (
    SELECT patientunitstayid, *
    FROM eicu_crd_derived.sofa
),
sapsii AS (
    SELECT patientunitstayid, *
    FROM eicu_crd_derived.sapsii
),
pivoted_score_agg AS (
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
    id.apache_iv
)
SELECT
    b.patientunitstayid,
    b.uniquepid,
    b.age,
    b.gender,
    p.hospitaldischargestatus,
    cbc_combined.WBC_x_1000,
    cbc_combined.WBC_x_1000_uom,
    cbc_combined.polys_pct,
    cbc_combined.polys_pct_uom,
    cbc_combined.lymphs_pct,
    cbc_combined.lymphs_pct_uom,
    cbc_combined.monos_pct,
    cbc_combined.monos_pct_uom,
    cbc_combined.cbc_offset,
    cbc_combined.neut_abs,
    cbc_combined.lymph_abs,
    cbc_combined.mono_abs,
    cbc_combined.NLR,
    RBC.first_RBC,
    RBC.first_RBC_uom,
    RBC.first_RBC_min_labresultoffset,
    platelets_x_1000.first_platelets_x_1000,
    platelets_x_1000.first_platelets_x_1000_uom,
    platelets_x_1000.first_platelets_x_1000_min_labresultoffset,
    Hgb.first_Hgb,
    Hgb.first_Hgb_uom,
    Hgb.first_Hgb_min_labresultoffset,
    FiO2.first_FiO2,
    FiO2.first_FiO2_uom,
    FiO2.first_FiO2_min_labresultoffset,
    paO2.first_paO2,
    paO2.first_paO2_uom,
    paO2.first_paO2_min_labresultoffset,
    LDH.first_LDH,
    LDH.first_LDH_uom,
    LDH.first_LDH_min_labresultoffset,
    creatinine.first_creatinine,
    creatinine.first_creatinine_uom,
    creatinine.first_creatinine_min_labresultoffset,
    albumin.first_albumin,
    albumin.first_albumin_uom,
    albumin.first_albumin_min_labresultoffset,
    cd_4.first_cd_4,
    cd_4.first_cd_4_uom,
    cd_4.first_cd_4_min_labresultoffset,
    htn.FLAG AS htn,
    Diabetes.FLAG AS Diabetes,
    MACE.FLAG AS MACE,
    liver.FLAG AS liver,
    Renal.FLAG AS Renal,
    pulmonary.FLAG AS pulmonary,
    Malignant.FLAG AS Malignant,
    transplant.FLAG AS transplant,
    HIV.FLAG AS HIV,
    CMV.FLAG AS CMV,
    Glu.FLAG AS Glu,
    Glu.drugstartoffset AS Glu_drugstartoffset,
    Glu.drugorderoffset AS Glu_drugorderoffset,
    Vasopressor.FLAG AS Vasopressor,
    Vasopressor.drugstartoffset AS Vasopressor_drugstartoffset,
    Vasopressor.drugorderoffset AS Vasopressor_drugorderoffset,
    resp.ventilation,
    resp.ventilation_first_time,
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
    dialysis.treatmentoffset AS dialysis_treatmentoffset,
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
    x2sulfonamide.treatmentoffset AS x2sulfonamide_treatmentoffset,
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
    pentamidine2.treatmentoffset AS pentamidine2_treatmentoffset,
    sofa.*,
    sapsii.*,
    pivoted_score_agg.apache_score,
    pivoted_score_agg.gcs,
    pivoted_score_agg.gcs_eyes,
    pivoted_score_agg.gcs_motor,
    pivoted_score_agg.gcs_verbal,
    pivoted_score_agg.delirium_score,
    pivoted_score_agg.pain_score
FROM basic b
LEFT JOIN eicu_crd.patient p
    ON b.patientunitstayid = p.patientunitstayid
LEFT JOIN (SELECT * FROM cbc_combined WHERE rn=1) cbc_combined
    ON b.patientunitstayid = cbc_combined.patientunitstayid
LEFT JOIN RBC
    ON b.patientunitstayid=RBC.patientunitstayid
LEFT JOIN platelets_x_1000
    ON b.patientunitstayid=platelets_x_1000.patientunitstayid
LEFT JOIN Hgb
    ON b.patientunitstayid=Hgb.patientunitstayid
LEFT JOIN FiO2
    ON b.patientunitstayid=FiO2.patientunitstayid
LEFT JOIN paO2
    ON b.patientunitstayid=paO2.patientunitstayid
LEFT JOIN LDH
    ON b.patientunitstayid=LDH.patientunitstayid
LEFT JOIN creatinine
    ON b.patientunitstayid=creatinine.patientunitstayid
LEFT JOIN albumin
    ON b.patientunitstayid=albumin.patientunitstayid
LEFT JOIN cd_4
    ON b.patientunitstayid=cd_4.patientunitstayid
LEFT JOIN htn
    ON b.patientunitstayid=htn.patientunitstayid
LEFT JOIN Diabetes
    ON b.patientunitstayid=Diabetes.patientunitstayid
LEFT JOIN MACE
    ON b.patientunitstayid=MACE.patientunitstayid
LEFT JOIN liver
    ON b.patientunitstayid=liver.patientunitstayid
LEFT JOIN Renal
    ON b.patientunitstayid=Renal.patientunitstayid
LEFT JOIN pulmonary
    ON b.patientunitstayid=pulmonary.patientunitstayid
LEFT JOIN Malignant
    ON b.patientunitstayid=Malignant.patientunitstayid
LEFT JOIN transplant
    ON b.patientunitstayid=transplant.patientunitstayid
LEFT JOIN HIV
    ON b.patientunitstayid=HIV.patientunitstayid
LEFT JOIN CMV
    ON b.patientunitstayid=CMV.patientunitstayid
LEFT JOIN Glu
    ON b.patientunitstayid=Glu.patientunitstayid
LEFT JOIN Vasopressor
    ON b.patientunitstayid=Vasopressor.patientunitstayid
LEFT JOIN resp
    ON b.patientunitstayid=resp.patientunitstayid
LEFT JOIN renal_dialysis1 ON b.patientunitstayid=renal_dialysis1.patientunitstayid
LEFT JOIN renal_dialysis2 ON b.patientunitstayid=renal_dialysis2.patientunitstayid
LEFT JOIN renal_dialysis3 ON b.patientunitstayid=renal_dialysis3.patientunitstayid
LEFT JOIN renal_dialysis4 ON b.patientunitstayid=renal_dialysis4.patientunitstayid
LEFT JOIN renal_dialysis5 ON b.patientunitstayid=renal_dialysis5.patientunitstayid
LEFT JOIN renal_dialysis6 ON b.patientunitstayid=renal_dialysis6.patientunitstayid
LEFT JOIN renal_dialysis7 ON b.patientunitstayid=renal_dialysis7.patientunitstayid
LEFT JOIN renal_dialysis8 ON b.patientunitstayid=renal_dialysis8.patientunitstayid
LEFT JOIN renal_dialysis9 ON b.patientunitstayid=renal_dialysis9.patientunitstayid
LEFT JOIN renal_dialysis10 ON b.patientunitstayid=renal_dialysis10.patientunitstayid
LEFT JOIN renal_dialysis11 ON b.patientunitstayid=renal_dialysis11.patientunitstayid
LEFT JOIN renal_dialysis12 ON b.patientunitstayid=renal_dialysis12.patientunitstayid
LEFT JOIN renal_dialysis13 ON b.patientunitstayid=renal_dialysis13.patientunitstayid
LEFT JOIN renal_dialysis14 ON b.patientunitstayid=renal_dialysis14.patientunitstayid
LEFT JOIN renal_dialysis15 ON b.patientunitstayid=renal_dialysis15.patientunitstayid
LEFT JOIN renal_dialysis16 ON b.patientunitstayid=renal_dialysis16.patientunitstayid
LEFT JOIN renal_dialysis17 ON b.patientunitstayid=renal_dialysis17.patientunitstayid
LEFT JOIN renal_dialysis18 ON b.patientunitstayid=renal_dialysis18.patientunitstayid
LEFT JOIN renal_dialysis19 ON b.patientunitstayid=renal_dialysis19.patientunitstayid
LEFT JOIN renal_dialysis20 ON b.patientunitstayid=renal_dialysis20.patientunitstayid
LEFT JOIN renal_dialysis21 ON b.patientunitstayid=renal_dialysis21.patientunitstayid
LEFT JOIN renal_dialysis22 ON b.patientunitstayid=renal_dialysis22.patientunitstayid
LEFT JOIN renal_dialysis23 ON b.patientunitstayid=renal_dialysis23.patientunitstayid
LEFT JOIN renal_dialysis24 ON b.patientunitstayid=renal_dialysis24.patientunitstayid
LEFT JOIN renal_dialysis25 ON b.patientunitstayid=renal_dialysis25.patientunitstayid
LEFT JOIN renal_dialysis26 ON b.patientunitstayid=renal_dialysis26.patientunitstayid
LEFT JOIN renal_dialysis27 ON b.patientunitstayid=renal_dialysis27.patientunitstayid
LEFT JOIN dialysis ON b.patientunitstayid=dialysis.patientunitstayid
LEFT JOIN x1sulfonamide ON b.patientunitstayid=x1sulfonamide.patientunitstayid
LEFT JOIN x3sulfonamide ON b.patientunitstayid=x3sulfonamide.patientunitstayid
LEFT JOIN x4sulfonamide ON b.patientunitstayid=x4sulfonamide.patientunitstayid
LEFT JOIN x5sulfonamide ON b.patientunitstayid=x5sulfonamide.patientunitstayid
LEFT JOIN x6sulfonamide ON b.patientunitstayid=x6sulfonamide.patientunitstayid
LEFT JOIN x7sulfonamide ON b.patientunitstayid=x7sulfonamide.patientunitstayid
LEFT JOIN x8sulfonamide ON b.patientunitstayid=x8sulfonamide.patientunitstayid
LEFT JOIN x9sulfonamide ON b.patientunitstayid=x9sulfonamide.patientunitstayid
LEFT JOIN x10sulfonamide ON b.patientunitstayid=x10sulfonamide.patientunitstayid
LEFT JOIN x11sulfonamide ON b.patientunitstayid=x11sulfonamide.patientunitstayid
LEFT JOIN x12sulfonamide ON b.patientunitstayid=x12sulfonamide.patientunitstayid
LEFT JOIN x13sulfonamide ON b.patientunitstayid=x13sulfonamide.patientunitstayid
LEFT JOIN x14sulfonamide ON b.patientunitstayid=x14sulfonamide.patientunitstayid
LEFT JOIN x15sulfonamide ON b.patientunitstayid=x15sulfonamide.patientunitstayid
LEFT JOIN x2sulfonamide ON b.patientunitstayid=x2sulfonamide.patientunitstayid
LEFT JOIN caspofungin ON b.patientunitstayid=caspofungin.patientunitstayid
LEFT JOIN caspofungin2 ON b.patientunitstayid=caspofungin2.patientunitstayid
LEFT JOIN caspofungin3 ON b.patientunitstayid=caspofungin3.patientunitstayid
LEFT JOIN atovaquone ON b.patientunitstayid=atovaquone.patientunitstayid
LEFT JOIN atovaquone2 ON b.patientunitstayid=atovaquone2.patientunitstayid
LEFT JOIN atovaquone3 ON b.patientunitstayid=atovaquone3.patientunitstayid
LEFT JOIN primaquine ON b.patientunitstayid=primaquine.patientunitstayid
LEFT JOIN primaquine2 ON b.patientunitstayid=primaquine2.patientunitstayid
LEFT JOIN pentamidine ON b.patientunitstayid=pentamidine.patientunitstayid
LEFT JOIN pentamidine2 ON b.patientunitstayid=pentamidine2.patientunitstayid
LEFT JOIN sofa ON b.patientunitstayid=sofa.patientunitstayid
LEFT JOIN sapsii ON b.patientunitstayid=sapsii.patientunitstayid
LEFT JOIN pivoted_score_agg ON b.patientunitstayid=pivoted_score_agg.patientunitstayid
ORDER BY b.patientunitstayid;
