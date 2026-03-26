/*
=============================================================
  ClaimIQ — Healthcare Claims Analytics
  Analysis Queries
  
  Total Queries: 8
  1.  Total Claims & Amount Summary
  2.  Claims by Type (Inpatient vs Outpatient)
  3.  Top 10 Providers by Claims
  4.  Provider Fraud vs Non-Fraud Analysis
  5.  Patient Demographics & Chronic Conditions
  6.  Top 10 Diagnosis Codes by Claim Frequency
  7.  Monthly Claim Trends
  8.  Chronic Disease Cost Impact
=============================================================
*/
 
USE HealthcareClaims_DB;
GO

/* ============================================================
   QUERY 1 — Total Claims & Amount Summary
 
   BUSINESS QUESTION:
   "How many total claims do we have and what is the
    total amount billed, paid and unpaid?"
 
   KEY METRICS:
   - Total Claims     → How many claims exist
   - Total Billed     → What providers charged
   - Total Paid       → What insurance actually paid
   - Avg per Claim    → Average payment per claim
============================================================ */

SELECT
    COUNT(ClaimID)                              AS Total_Claims,
    COUNT(DISTINCT BeneID)                      AS Total_Patients,
    COUNT(DISTINCT ProviderID)                  AS Total_Providers,
    SUM(InscClaimAmtReimbursed)                 AS Total_Paid,
    SUM(DeductibleAmtPaid)                      AS Total_Deductible,
    SUM(InscClaimAmtReimbursed) 
        + SUM(DeductibleAmtPaid)                AS Total_Billed,
    ROUND(AVG(InscClaimAmtReimbursed), 2)       AS Avg_Paid_Per_Claim
FROM Claims;
GO


/* ============================================================
   QUERY 2 — Claims by Type (Inpatient vs Outpatient)

   BUSINESS QUESTION:
   "What is the cost difference between inpatient
    and outpatient claims?"

   WHY IT MATTERS:
   Insurance companies and hospitals track this closely
   because inpatient claims cost significantly more.
   This is a standard metric in Revenue Cycle Analytics.
============================================================ */


SELECT
    ClaimType,
    COUNT(ClaimID)                              AS Total_Claims,
    COUNT(DISTINCT BeneID)                      AS Unique_Patients,
    COUNT(DISTINCT ProviderID)                  AS Unique_Providers,
    SUM(InscClaimAmtReimbursed)                 AS Total_Paid,
    ROUND(AVG(InscClaimAmtReimbursed), 2)       AS Avg_Paid_Per_Claim,
    MIN(InscClaimAmtReimbursed)                 AS Min_Claim_Amount,
    MAX(InscClaimAmtReimbursed)                 AS Max_Claim_Amount
FROM Claims
GROUP BY ClaimType
ORDER BY Total_Claims DESC;
GO


/* ============================================================
   QUERY 3 — Top 10 Providers by Claims

   EXPLANATION:
   Identifies which providers submitted the most claims.
   High volume providers need extra scrutiny — they could
   be large hospitals OR potential fraud cases.

   BUSINESS QUESTION:
   "Which providers are submitting the most claims
    and how much are they being paid?"

   WHY IT MATTERS:
   Provider performance monitoring is a key function
   in healthcare payer organizations (insurance companies).
   This is used in network management and fraud detection.
============================================================ */



SELECT TOP 10
    p.ProviderID,
    p.PotentialFraud,
    COUNT(c.ClaimID)                            AS Total_Claims,
    COUNT(DISTINCT c.BeneID)                    AS Unique_Patients,
    SUM(c.InscClaimAmtReimbursed)               AS Total_Paid,
    ROUND(AVG(c.InscClaimAmtReimbursed), 2)     AS Avg_Paid_Per_Claim,
    SUM(CASE WHEN c.ClaimType = 'Inpatient'  
             THEN 1 ELSE 0 END)                 AS Inpatient_Claims,
    SUM(CASE WHEN c.ClaimType = 'Outpatient' 
             THEN 1 ELSE 0 END)                 AS Outpatient_Claims
FROM Claims c
JOIN Providers p 
ON c.ProviderID = p.ProviderID
GROUP BY p.ProviderID, p.PotentialFraud
ORDER BY Total_Claims DESC;
GO

/* ============================================================
   QUERY 4 — Provider Fraud vs Non-Fraud Analysis

   BUSINESS QUESTION:
   "What is the difference in billing patterns between
    providers flagged for fraud vs clean providers?"

   WHY IT MATTERS:
   Fraud detection is a billion dollar problem in US Healthcare.
   CMS estimates $60 billion lost to fraud annually.
   This query shows you can identify fraud patterns using data.

   KEY INSIGHT TO LOOK FOR:
   Fraudulent providers typically show:
   → Higher average claim amounts
   → More claims per patient
   → Higher total billed amounts
============================================================ */




SELECT
    p.PotentialFraud,
    COUNT(DISTINCT p.ProviderID)                AS Provider_Count,
    COUNT(c.ClaimID)                            AS Total_Claims,
    COUNT(DISTINCT c.BeneID)                    AS Unique_Patients,
    SUM(c.InscClaimAmtReimbursed)               AS Total_Paid,
    ROUND(AVG(c.InscClaimAmtReimbursed), 2)     AS Avg_Paid_Per_Claim,
    ROUND(SUM(c.InscClaimAmtReimbursed) * 100.0 /
    (SELECT SUM(InscClaimAmtReimbursed) FROM Claims), 2)  AS Pct_Of_Total_Paid,
	ROUND(CAST(COUNT(c.ClaimID) AS FLOAT) / 
        COUNT(DISTINCT p.ProviderID), 2)        AS Avg_Claims_Per_Provider
FROM Providers p
JOIN Claims c ON p.ProviderID = c.ProviderID
GROUP BY p.PotentialFraud
ORDER BY p.PotentialFraud;
GO


-- =====================================================
-- Query 5: Patient Demographics & Chronic Conditions
-- =====================================================

SELECT
    Gender,
    Race,
    COUNT(DISTINCT BeneID)                      AS Total_Patients,
    ROUND(AVG(DATEDIFF(YEAR, DOB, GETDATE())),1)AS Avg_Age,
    SUM(ChronicCond_Alzheimer)                  AS Alzheimer,
    SUM(ChronicCond_Heartfailure)               AS Heart_Failure,
    SUM(ChronicCond_KidneyDisease)              AS Kidney_Disease,
    SUM(ChronicCond_Cancer)                     AS Cancer,
    SUM(ChronicCond_ObstrPulmonary)             AS Pulmonary_Disease,
    SUM(ChronicCond_Depression)                 AS Depression,
    SUM(ChronicCond_Diabetes)                   AS Diabetes,
    SUM(ChronicCond_IschemicHeart)              AS Ischemic_Heart,
    SUM(ChronicCond_Osteoporasis)               AS Osteoporosis,
    SUM(ChronicCond_Rheumatoid)                 AS Rheumatoid_Arthritis,
    SUM(ChronicCond_Stroke)                     AS Stroke,
    ROUND(AVG(IPAnnualReimbursementAmt), 2)     AS Avg_IP_Reimbursement,
    ROUND(AVG(OPAnnualReimbursementAmt), 2)     AS Avg_OP_Reimbursement
FROM Patients
GROUP BY Gender, Race
ORDER BY Total_Patients DESC;
GO

-- =====================================================
-- Query 6: Top 10 Diagnosis Codes by Claim Frequency
-- ClaimIQ - Healthcare Claims Analytics
-- =====================================================

-- Step 1: Unpivot all 10 diagnosis codes into one column
WITH ClaimDiagnoses AS (
    SELECT ClaimID, BeneID, ProviderID, ClaimType,
           InscClaimAmtReimbursed, ClmDiagnosisCode_1  AS DiagnosisCode FROM Claims WHERE ClmDiagnosisCode_1  IS NOT NULL
    UNION ALL
    SELECT ClaimID, BeneID, ProviderID, ClaimType,
           InscClaimAmtReimbursed, ClmDiagnosisCode_2  FROM Claims WHERE ClmDiagnosisCode_2  IS NOT NULL
    UNION ALL
    SELECT ClaimID, BeneID, ProviderID, ClaimType,
           InscClaimAmtReimbursed, ClmDiagnosisCode_3  FROM Claims WHERE ClmDiagnosisCode_3  IS NOT NULL
    UNION ALL
    SELECT ClaimID, BeneID, ProviderID, ClaimType,
           InscClaimAmtReimbursed, ClmDiagnosisCode_4  FROM Claims WHERE ClmDiagnosisCode_4  IS NOT NULL
    UNION ALL
    SELECT ClaimID, BeneID, ProviderID, ClaimType,
           InscClaimAmtReimbursed, ClmDiagnosisCode_5  FROM Claims WHERE ClmDiagnosisCode_5  IS NOT NULL
    UNION ALL
    SELECT ClaimID, BeneID, ProviderID, ClaimType,
           InscClaimAmtReimbursed, ClmDiagnosisCode_6  FROM Claims WHERE ClmDiagnosisCode_6  IS NOT NULL
    UNION ALL
    SELECT ClaimID, BeneID, ProviderID, ClaimType,
           InscClaimAmtReimbursed, ClmDiagnosisCode_7  FROM Claims WHERE ClmDiagnosisCode_7  IS NOT NULL
    UNION ALL
    SELECT ClaimID, BeneID, ProviderID, ClaimType,
           InscClaimAmtReimbursed, ClmDiagnosisCode_8  FROM Claims WHERE ClmDiagnosisCode_8  IS NOT NULL
    UNION ALL
    SELECT ClaimID, BeneID, ProviderID, ClaimType,
           InscClaimAmtReimbursed, ClmDiagnosisCode_9  FROM Claims WHERE ClmDiagnosisCode_9  IS NOT NULL
    UNION ALL
    SELECT ClaimID, BeneID, ProviderID, ClaimType,
           InscClaimAmtReimbursed, ClmDiagnosisCode_10 FROM Claims WHERE ClmDiagnosisCode_10 IS NOT NULL
)

-- Step 2: Join with Diagnoses table and aggregate
SELECT TOP 10
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
FROM ClaimDiagnoses cd
JOIN Diagnoses d ON cd.DiagnosisCode = d.DiagnosisCode
GROUP BY cd.DiagnosisCode, d.ShortDesc, d.Category
ORDER BY Total_Claims DESC;
GO

-- Query 7: Monthly Claims Trend
-- ClaimIQ - Healthcare Claims Analytics
-- =====================================================

SELECT
    YEAR(c.ClaimStartDt)                        AS Claim_Year,
    MONTH(c.ClaimStartDt)                       AS Claim_Month,
    FORMAT(c.ClaimStartDt, 'yyyy-MM')           AS Year_Month,
    c.ClaimType,
    COUNT(c.ClaimID)                            AS Total_Claims,
    COUNT(DISTINCT c.BeneID)                    AS Unique_Patients,
    COUNT(DISTINCT c.ProviderID)                AS Unique_Providers,
    SUM(c.InscClaimAmtReimbursed)               AS Total_Reimbursed,
    ROUND(AVG(c.InscClaimAmtReimbursed), 2)     AS Avg_Per_Claim,
    SUM(CASE WHEN c.ClaimType = 'Inpatient'
             THEN 1 ELSE 0 END)                 AS Inpatient_Claims,
    SUM(CASE WHEN c.ClaimType = 'Outpatient'
             THEN 1 ELSE 0 END)                 AS Outpatient_Claims
FROM Claims c
GROUP BY
    YEAR(c.ClaimStartDt),
    MONTH(c.ClaimStartDt),
    FORMAT(c.ClaimStartDt, 'yyyy-MM'),
    c.ClaimType
ORDER BY Claim_Year, Claim_Month, c.ClaimType;
GO

-- =====================================================
-- Query 8: High Risk Patients (Chronic Conditions + High Cost)
-- ClaimIQ - Healthcare Claims Analytics
-- =====================================================

SELECT TOP 20
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
    DATEDIFF(YEAR, pt.DOB, GETDATE())               AS Age,
    pt.State,
    (
        (pt.ChronicCond_Alzheimer       - 1) +
        (pt.ChronicCond_Heartfailure    - 1) +
        (pt.ChronicCond_KidneyDisease   - 1) +
        (pt.ChronicCond_Cancer          - 1) +
        (pt.ChronicCond_ObstrPulmonary  - 1) +
        (pt.ChronicCond_Depression      - 1) +
        (pt.ChronicCond_Diabetes        - 1) +
        (pt.ChronicCond_IschemicHeart   - 1) +
        (pt.ChronicCond_Osteoporasis    - 1) +
        (pt.ChronicCond_Rheumatoid      - 1) +
        (pt.ChronicCond_Stroke          - 1)
    )                                               AS Chronic_Condition_Count,
    COUNT(c.ClaimID)                                AS Total_Claims,
    SUM(c.InscClaimAmtReimbursed)                   AS Total_Reimbursed,
    MAX(pt.IPAnnualReimbursementAmt)                AS IP_Annual_Reimbursement,
    MAX(pt.OPAnnualReimbursementAmt)                AS OP_Annual_Reimbursement,
    SUM(CASE WHEN c.ClaimType = 'Inpatient'
             THEN 1 ELSE 0 END)                     AS Inpatient_Claims,
    SUM(CASE WHEN c.ClaimType = 'Outpatient'
             THEN 1 ELSE 0 END)                     AS Outpatient_Claims
FROM Patients pt
JOIN Claims c ON pt.BeneID = c.BeneID
GROUP BY
    pt.BeneID, pt.Gender, pt.Race, pt.DOB, pt.State,
    pt.ChronicCond_Alzheimer, pt.ChronicCond_Heartfailure,
    pt.ChronicCond_KidneyDisease, pt.ChronicCond_Cancer,
    pt.ChronicCond_ObstrPulmonary, pt.ChronicCond_Depression,
    pt.ChronicCond_Diabetes, pt.ChronicCond_IschemicHeart,
    pt.ChronicCond_Osteoporasis, pt.ChronicCond_Rheumatoid,
    pt.ChronicCond_Stroke
ORDER BY Chronic_Condition_Count DESC, Total_Reimbursed DESC;
GO
