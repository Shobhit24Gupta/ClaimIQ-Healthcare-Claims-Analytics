/* ============================================================
   VIEW 1 — vw_ClaimKPISummary
   Based on: Query 1
   Purpose : Single-row KPI scorecard for Tableau header tiles
============================================================ */
CREATE OR ALTER VIEW dbo.vw_ClaimKPISummary AS
SELECT
    COUNT(ClaimID)                          AS Total_Claims,
    COUNT(DISTINCT BeneID)                  AS Total_Patients,
    COUNT(DISTINCT ProviderID)              AS Total_Providers,
    SUM(InscClaimAmtReimbursed)             AS Total_Paid,
    SUM(DeductibleAmtPaid)                  AS Total_Deductible,
    SUM(InscClaimAmtReimbursed)
        + SUM(DeductibleAmtPaid)            AS Total_Billed,
    ROUND(AVG(InscClaimAmtReimbursed), 2)   AS Avg_Paid_Per_Claim
FROM dbo.Claims;
GO


/* ============================================================
   VIEW 2 — vw_ClaimsByType
   Based on: Query 2
   Purpose : Inpatient vs Outpatient cost comparison
============================================================ */
CREATE OR ALTER VIEW dbo.vw_ClaimsByType AS
SELECT
    ClaimType,
    COUNT(ClaimID)                          AS Total_Claims,
    COUNT(DISTINCT BeneID)                  AS Unique_Patients,
    COUNT(DISTINCT ProviderID)              AS Unique_Providers,
    SUM(InscClaimAmtReimbursed)             AS Total_Paid,
    ROUND(AVG(InscClaimAmtReimbursed), 2)   AS Avg_Paid_Per_Claim,
    MIN(InscClaimAmtReimbursed)             AS Min_Claim_Amount,
    MAX(InscClaimAmtReimbursed)             AS Max_Claim_Amount
FROM dbo.Claims
GROUP BY ClaimType;
GO


/* ============================================================
   VIEW 3 — vw_ProviderSummary
   Based on: Query 3 + Query 4 merged
   Purpose : Per-provider KPIs + fraud flag for all providers
             (Tableau will handle Top 10 filtering)
   Change  : Removed TOP 10 — let Tableau rank dynamically
============================================================ */
CREATE OR ALTER VIEW dbo.vw_ProviderSummary AS
SELECT
    p.ProviderID,
    p.PotentialFraud,
    COUNT(c.ClaimID)                                        AS Total_Claims,
    COUNT(DISTINCT c.BeneID)                                AS Unique_Patients,
    SUM(c.InscClaimAmtReimbursed)                           AS Total_Paid,
    ROUND(AVG(c.InscClaimAmtReimbursed), 2)                 AS Avg_Paid_Per_Claim,
    MAX(c.InscClaimAmtReimbursed)                           AS Max_Claim_Amount,
    SUM(CASE WHEN c.ClaimType = 'Inpatient'
             THEN 1 ELSE 0 END)                             AS Inpatient_Claims,
    SUM(CASE WHEN c.ClaimType = 'Outpatient'
             THEN 1 ELSE 0 END)                             AS Outpatient_Claims,
    -- Fraud amount vs legit amount
    SUM(CASE WHEN p.PotentialFraud = 'Yes'
             THEN c.InscClaimAmtReimbursed ELSE 0 END)      AS Fraud_Reimbursed_Amt,
    SUM(CASE WHEN p.PotentialFraud = 'No'
             THEN c.InscClaimAmtReimbursed ELSE 0 END)      AS Legit_Reimbursed_Amt,
    -- Fraud rate per provider
    ROUND(
        100.0 * SUM(CASE WHEN p.PotentialFraud = 'Yes' THEN 1 ELSE 0 END)
        / NULLIF(COUNT(c.ClaimID), 0), 2
    )                                                       AS Fraud_Rate_Pct
FROM dbo.Claims c
JOIN dbo.Providers p ON c.ProviderID = p.ProviderID
GROUP BY p.ProviderID, p.PotentialFraud;
GO


/* ============================================================
   VIEW 4 — vw_PatientDemographics
   Based on: Query 5
   Purpose : Gender/Race breakdown with chronic condition counts
   Changes : Added Gender & Race decode labels (tinyint → text)
             Added RenalDiseaseIndicator (present in table)
============================================================ */
CREATE OR ALTER VIEW dbo.vw_PatientDemographics AS
SELECT
    CASE WHEN Gender = 1 THEN 'Male'
         WHEN Gender = 2 THEN 'Female'
         ELSE 'Unknown'
    END                                             AS Gender,
    CASE WHEN Race = 1 THEN 'White'
         WHEN Race = 2 THEN 'Black'
         WHEN Race = 3 THEN 'Asian'
         WHEN Race = 5 THEN 'Hispanic'
         ELSE 'Other'
    END                                             AS Race,
    COUNT(DISTINCT BeneID)                          AS Total_Patients,
    ROUND(AVG(DATEDIFF(YEAR, DOB, GETDATE())), 1)   AS Avg_Age,
    -- Chronic conditions (stored as 1=No, 2=Yes → convert to 0/1)
    SUM(ChronicCond_Alzheimer - 1)                  AS Alzheimer,
    SUM(ChronicCond_Heartfailure - 1)               AS Heart_Failure,
    SUM(ChronicCond_KidneyDisease - 1)              AS Kidney_Disease,
    SUM(ChronicCond_Cancer - 1)                     AS Cancer,
    SUM(ChronicCond_ObstrPulmonary - 1)             AS Pulmonary_Disease,
    SUM(ChronicCond_Depression - 1)                 AS Depression,
    SUM(ChronicCond_Diabetes - 1)                   AS Diabetes,
    SUM(ChronicCond_IschemicHeart - 1)              AS Ischemic_Heart,
    SUM(ChronicCond_Osteoporasis - 1)               AS Osteoporosis,
    SUM(ChronicCond_Rheumatoid - 1)                 AS Rheumatoid_Arthritis,
    SUM(ChronicCond_Stroke - 1)                     AS Stroke,
    -- Renal flag count
    SUM(CASE WHEN RenalDiseaseIndicator = 'Y'
             THEN 1 ELSE 0 END)                     AS Renal_Disease,
    ROUND(AVG(IPAnnualReimbursementAmt), 2)         AS Avg_IP_Reimbursement,
    ROUND(AVG(OPAnnualReimbursementAmt), 2)         AS Avg_OP_Reimbursement
FROM dbo.Patients
GROUP BY Gender, Race;
GO


/* ============================================================
   VIEW 5 — vw_DiagnosisDetail
   Based on: Query 6
   Purpose : All diagnosis code rows unpivoted — Tableau filters top 10
   Change  : Removed TOP 10 and ORDER BY (not allowed in views)
             CTE converted to inline subquery for view compatibility
============================================================ */
CREATE OR ALTER VIEW dbo.vw_DiagnosisDetail AS
SELECT
    cd.DiagnosisCode,
    d.ShortDesc                                 AS Diagnosis_Name,
    d.Category                                  AS Diagnosis_Category,
    COUNT(cd.ClaimID)                           AS Total_Claims,
    COUNT(DISTINCT cd.BeneID)                   AS Unique_Patients,
    COUNT(DISTINCT cd.ProviderID)               AS Unique_Providers,
    SUM(cd.InscClaimAmtReimbursed)              AS Total_Reimbursed,
    ROUND(AVG(cd.InscClaimAmtReimbursed), 2)    AS Avg_Per_Claim,
    SUM(CASE WHEN cd.ClaimType = 'Inpatient'
             THEN 1 ELSE 0 END)                 AS Inpatient_Claims,
    SUM(CASE WHEN cd.ClaimType = 'Outpatient'
             THEN 1 ELSE 0 END)                 AS Outpatient_Claims
FROM (
    SELECT ClaimID, BeneID, ProviderID, ClaimType,
           InscClaimAmtReimbursed, ClmDiagnosisCode_1  AS DiagnosisCode
    FROM dbo.Claims WHERE ClmDiagnosisCode_1  IS NOT NULL
    UNION ALL
    SELECT ClaimID, BeneID, ProviderID, ClaimType,
           InscClaimAmtReimbursed, ClmDiagnosisCode_2
    FROM dbo.Claims WHERE ClmDiagnosisCode_2  IS NOT NULL
    UNION ALL
    SELECT ClaimID, BeneID, ProviderID, ClaimType,
           InscClaimAmtReimbursed, ClmDiagnosisCode_3
    FROM dbo.Claims WHERE ClmDiagnosisCode_3  IS NOT NULL
    UNION ALL
    SELECT ClaimID, BeneID, ProviderID, ClaimType,
           InscClaimAmtReimbursed, ClmDiagnosisCode_4
    FROM dbo.Claims WHERE ClmDiagnosisCode_4  IS NOT NULL
    UNION ALL
    SELECT ClaimID, BeneID, ProviderID, ClaimType,
           InscClaimAmtReimbursed, ClmDiagnosisCode_5
    FROM dbo.Claims WHERE ClmDiagnosisCode_5  IS NOT NULL
    UNION ALL
    SELECT ClaimID, BeneID, ProviderID, ClaimType,
           InscClaimAmtReimbursed, ClmDiagnosisCode_6
    FROM dbo.Claims WHERE ClmDiagnosisCode_6  IS NOT NULL
    UNION ALL
    SELECT ClaimID, BeneID, ProviderID, ClaimType,
           InscClaimAmtReimbursed, ClmDiagnosisCode_7
    FROM dbo.Claims WHERE ClmDiagnosisCode_7  IS NOT NULL
    UNION ALL
    SELECT ClaimID, BeneID, ProviderID, ClaimType,
           InscClaimAmtReimbursed, ClmDiagnosisCode_8
    FROM dbo.Claims WHERE ClmDiagnosisCode_8  IS NOT NULL
    UNION ALL
    SELECT ClaimID, BeneID, ProviderID, ClaimType,
           InscClaimAmtReimbursed, ClmDiagnosisCode_9
    FROM dbo.Claims WHERE ClmDiagnosisCode_9  IS NOT NULL
    UNION ALL
    SELECT ClaimID, BeneID, ProviderID, ClaimType,
           InscClaimAmtReimbursed, ClmDiagnosisCode_10
    FROM dbo.Claims WHERE ClmDiagnosisCode_10 IS NOT NULL
) cd
JOIN dbo.Diagnoses d ON cd.DiagnosisCode = d.DiagnosisCode
GROUP BY cd.DiagnosisCode, d.ShortDesc, d.Category;
GO


/* ============================================================
   VIEW 6 — vw_MonthlyTrends
   Based on: Query 7
   Purpose : Month-over-month claim volume and cost trends
   Change  : Removed redundant Inpatient/Outpatient split columns
             (ClaimType is already the GROUP BY dimension)
============================================================ */
CREATE OR ALTER VIEW dbo.vw_MonthlyTrends AS
SELECT
    YEAR(ClaimStartDt)                      AS Claim_Year,
    MONTH(ClaimStartDt)                     AS Claim_Month,
    FORMAT(ClaimStartDt, 'yyyy-MM')         AS Year_Month,
    ClaimType,
    COUNT(ClaimID)                          AS Total_Claims,
    COUNT(DISTINCT BeneID)                  AS Unique_Patients,
    COUNT(DISTINCT ProviderID)              AS Unique_Providers,
    SUM(InscClaimAmtReimbursed)             AS Total_Reimbursed,
    ROUND(AVG(InscClaimAmtReimbursed), 2)   AS Avg_Per_Claim
FROM dbo.Claims
GROUP BY
    YEAR(ClaimStartDt),
    MONTH(ClaimStartDt),
    FORMAT(ClaimStartDt, 'yyyy-MM'),
    ClaimType;
GO


/* ============================================================
   VIEW 7 — vw_PatientRiskProfile
   Based on: Query 8
   Purpose : Full patient risk scoring with chronic conditions
             and claim costs — Tableau handles Top N ranking
   Changes : Removed TOP 20 and ORDER BY (not allowed in views)
             Kept (ChronicCond - 1) decode logic (1=No, 2=Yes)
             Added Gender/Race decode labels
             Added RenalDiseaseIndicator
============================================================ */
CREATE OR ALTER VIEW dbo.vw_PatientRiskProfile AS
SELECT
    pt.BeneID,
    CASE WHEN pt.Gender = 1 THEN 'Male'
         WHEN pt.Gender = 2 THEN 'Female'
         ELSE 'Unknown'
    END                                             AS Gender,
    CASE WHEN pt.Race = 1 THEN 'White'
         WHEN pt.Race = 2 THEN 'Black'
         WHEN pt.Race = 3 THEN 'Asian'
         WHEN pt.Race = 5 THEN 'Hispanic'
         ELSE 'Other'
    END                                             AS Race,
    DATEDIFF(YEAR, MAX(pt.DOB), GETDATE())          AS Age,
    pt.State,
    pt.County,
    pt.RenalDiseaseIndicator,
    pt.NoOfMonths_PartACov,
    pt.NoOfMonths_PartBCov,
    -- Chronic condition flags (decoded to 0/1)
    (pt.ChronicCond_Alzheimer      - 1)             AS Alzheimer,
    (pt.ChronicCond_Heartfailure   - 1)             AS Heart_Failure,
    (pt.ChronicCond_KidneyDisease  - 1)             AS Kidney_Disease,
    (pt.ChronicCond_Cancer         - 1)             AS Cancer,
    (pt.ChronicCond_ObstrPulmonary - 1)             AS Pulmonary_Disease,
    (pt.ChronicCond_Depression     - 1)             AS Depression,
    (pt.ChronicCond_Diabetes       - 1)             AS Diabetes,
    (pt.ChronicCond_IschemicHeart  - 1)             AS Ischemic_Heart,
    (pt.ChronicCond_Osteoporasis   - 1)             AS Osteoporosis,
    (pt.ChronicCond_Rheumatoid     - 1)             AS Rheumatoid_Arthritis,
    (pt.ChronicCond_Stroke         - 1)             AS Stroke,
    -- Total chronic condition count (risk score)
    (
        (pt.ChronicCond_Alzheimer      - 1) +
        (pt.ChronicCond_Heartfailure   - 1) +
        (pt.ChronicCond_KidneyDisease  - 1) +
        (pt.ChronicCond_Cancer         - 1) +
        (pt.ChronicCond_ObstrPulmonary - 1) +
        (pt.ChronicCond_Depression     - 1) +
        (pt.ChronicCond_Diabetes       - 1) +
        (pt.ChronicCond_IschemicHeart  - 1) +
        (pt.ChronicCond_Osteoporasis   - 1) +
        (pt.ChronicCond_Rheumatoid     - 1) +
        (pt.ChronicCond_Stroke         - 1)
    )                                               AS Chronic_Condition_Count,
    -- Annual reimbursement benchmarks (MAX since constant per patient)
    MAX(pt.IPAnnualReimbursementAmt)                AS IP_Annual_Reimbursement,
    MAX(pt.OPAnnualReimbursementAmt)                AS OP_Annual_Reimbursement,
    MAX(pt.IPAnnualDeductibleAmt)                   AS IP_Annual_Deductible,
    MAX(pt.OPAnnualDeductibleAmt)                   AS OP_Annual_Deductible,
    -- Claim rollup from Claims table
    COUNT(c.ClaimID)                                AS Total_Claims,
    SUM(c.InscClaimAmtReimbursed)                   AS Total_Reimbursed,
    SUM(CASE WHEN c.ClaimType = 'Inpatient'
             THEN 1 ELSE 0 END)                     AS Inpatient_Claims,
    SUM(CASE WHEN c.ClaimType = 'Outpatient'
             THEN 1 ELSE 0 END)                     AS Outpatient_Claims
FROM dbo.Patients pt
JOIN dbo.Claims c ON pt.BeneID = c.BeneID
GROUP BY
    pt.BeneID, pt.Gender, pt.Race, pt.State, pt.County,
    pt.RenalDiseaseIndicator, pt.NoOfMonths_PartACov, pt.NoOfMonths_PartBCov,
    pt.ChronicCond_Alzheimer, pt.ChronicCond_Heartfailure,
    pt.ChronicCond_KidneyDisease, pt.ChronicCond_Cancer,
    pt.ChronicCond_ObstrPulmonary, pt.ChronicCond_Depression,
    pt.ChronicCond_Diabetes, pt.ChronicCond_IschemicHeart,
    pt.ChronicCond_Osteoporasis, pt.ChronicCond_Rheumatoid,
    pt.ChronicCond_Stroke;
GO
