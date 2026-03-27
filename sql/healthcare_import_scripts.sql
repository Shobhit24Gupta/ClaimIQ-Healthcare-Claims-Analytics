
/*
=============================================================
  HEALTHCARE CLAIMS ANALYTICS PROJECT
  FIXED IMPORT SCRIPTS — SQL Server 2017
=============================================================
*/

Create DATABASE HealthcareClaims_DB;

USE HealthcareClaims_DB;
GO
 
 
/* ============================================================
   PART 1 — DROP TABLES IF THEY EXIST
============================================================ */
 
IF OBJECT_ID('Claims',    'U') IS NOT NULL DROP TABLE Claims;
IF OBJECT_ID('Patients',  'U') IS NOT NULL DROP TABLE Patients;
IF OBJECT_ID('Diagnoses', 'U') IS NOT NULL DROP TABLE Diagnoses;
IF OBJECT_ID('Providers', 'U') IS NOT NULL DROP TABLE Providers;
GO
 
 
/* ============================================================
   PART 2 — CREATE STAGING TABLES (All VARCHAR)
   
   EXPLANATION:
   Staging tables store RAW data exactly as it is in the CSV.
   Every column is VARCHAR so SQL Server accepts anything —
   "NA", quoted values, mixed date formats — no errors!
   ============================================================ */
 
-- Drop staging tables if they exist
IF OBJECT_ID('stg_Providers',   'U') IS NOT NULL DROP TABLE stg_Providers;
IF OBJECT_ID('stg_Patients',    'U') IS NOT NULL DROP TABLE stg_Patients;
IF OBJECT_ID('stg_Diagnoses',   'U') IS NOT NULL DROP TABLE stg_Diagnoses;
IF OBJECT_ID('stg_Inpatient',   'U') IS NOT NULL DROP TABLE stg_Inpatient;
IF OBJECT_ID('stg_Outpatient',  'U') IS NOT NULL DROP TABLE stg_Outpatient;
GO
 
-- Staging: Providers
CREATE TABLE stg_Providers (
    ProviderID      VARCHAR(50),
    PotentialFraud  VARCHAR(50)
);
 
-- Staging: Patients (all 25 columns as VARCHAR)
CREATE TABLE stg_Patients (
    BeneID                          VARCHAR(50),
    DOB                             VARCHAR(50),
    DOD                             VARCHAR(50),
    Gender                          VARCHAR(10),
    Race                            VARCHAR(10),
    RenalDiseaseIndicator           VARCHAR(10),
    State                           VARCHAR(10),
    County                          VARCHAR(10),
    NoOfMonths_PartACov             VARCHAR(10),
    NoOfMonths_PartBCov             VARCHAR(10),
    ChronicCond_Alzheimer           VARCHAR(10),
    ChronicCond_Heartfailure        VARCHAR(10),
    ChronicCond_KidneyDisease       VARCHAR(10),
    ChronicCond_Cancer              VARCHAR(10),
    ChronicCond_ObstrPulmonary      VARCHAR(10),
    ChronicCond_Depression          VARCHAR(10),
    ChronicCond_Diabetes            VARCHAR(10),
    ChronicCond_IschemicHeart       VARCHAR(10),
    ChronicCond_Osteoporasis        VARCHAR(10),
    ChronicCond_Rheumatoid          VARCHAR(10),
    ChronicCond_Stroke              VARCHAR(10),
    IPAnnualReimbursementAmt        VARCHAR(20),
    IPAnnualDeductibleAmt           VARCHAR(20),
    OPAnnualReimbursementAmt        VARCHAR(20),
    OPAnnualDeductibleAmt           VARCHAR(20)
);
 
-- Staging: Diagnoses (6 columns in ICD10 file)
CREATE TABLE stg_Diagnoses (
    Col1            VARCHAR(50),
    Col2            VARCHAR(50),
    DiagnosisCode   VARCHAR(50),
    ShortDesc       VARCHAR(100),
    LongDesc        VARCHAR(250),   -- Max in file is 228
    Category        VARCHAR(250)    -- Max in file is 206
);
GO

-- Staging: Inpatient Claims
CREATE TABLE stg_Inpatient (
    BeneID                  VARCHAR(50),
    ClaimID                 VARCHAR(50),
    ClaimStartDt            VARCHAR(50),
    ClaimEndDt              VARCHAR(50),
    Provider                VARCHAR(50),
    InscClaimAmtReimbursed  VARCHAR(50),
    AttendingPhysician      VARCHAR(50),
    OperatingPhysician      VARCHAR(50),
    OtherPhysician          VARCHAR(50),
    AdmissionDt             VARCHAR(50),
    ClmAdmitDiagnosisCode   VARCHAR(50),
    DeductibleAmtPaid       VARCHAR(50),
    DischargeDt             VARCHAR(50),
    DiagnosisGroupCode      VARCHAR(50),
    ClmDiagnosisCode_1      VARCHAR(50),
    ClmDiagnosisCode_2      VARCHAR(50),
    ClmDiagnosisCode_3      VARCHAR(50),
    ClmDiagnosisCode_4      VARCHAR(50),
    ClmDiagnosisCode_5      VARCHAR(50),
    ClmDiagnosisCode_6      VARCHAR(50),
    ClmDiagnosisCode_7      VARCHAR(50),
    ClmDiagnosisCode_8      VARCHAR(50),
    ClmDiagnosisCode_9      VARCHAR(50),
    ClmDiagnosisCode_10     VARCHAR(50),
    ClmProcedureCode_1      VARCHAR(50),
    ClmProcedureCode_2      VARCHAR(50),
    ClmProcedureCode_3      VARCHAR(50),
    ClmProcedureCode_4      VARCHAR(50),
    ClmProcedureCode_5      VARCHAR(50),
    ClmProcedureCode_6      VARCHAR(50)
);
 
-- Staging: Outpatient Claims
-- Note: Different column order than Inpatient!
CREATE TABLE stg_Outpatient (
    BeneID                  VARCHAR(50),
    ClaimID                 VARCHAR(50),
    ClaimStartDt            VARCHAR(50),
    ClaimEndDt              VARCHAR(50),
    Provider                VARCHAR(50),
    InscClaimAmtReimbursed  VARCHAR(50),
    AttendingPhysician      VARCHAR(50),
    OperatingPhysician      VARCHAR(50),
    OtherPhysician          VARCHAR(50),
    ClmDiagnosisCode_1      VARCHAR(50),
    ClmDiagnosisCode_2      VARCHAR(50),
    ClmDiagnosisCode_3      VARCHAR(50),
    ClmDiagnosisCode_4      VARCHAR(50),
    ClmDiagnosisCode_5      VARCHAR(50),
    ClmDiagnosisCode_6      VARCHAR(50),
    ClmDiagnosisCode_7      VARCHAR(50),
    ClmDiagnosisCode_8      VARCHAR(50),
    ClmDiagnosisCode_9      VARCHAR(50),
    ClmDiagnosisCode_10     VARCHAR(50),
    ClmProcedureCode_1      VARCHAR(50),
    ClmProcedureCode_2      VARCHAR(50),
    ClmProcedureCode_3      VARCHAR(50),
    ClmProcedureCode_4      VARCHAR(50),
    ClmProcedureCode_5      VARCHAR(50),
    ClmProcedureCode_6      VARCHAR(50),
    DeductibleAmtPaid       VARCHAR(50),
    ClmAdmitDiagnosisCode   VARCHAR(50)
);
GO
 
 
/* ============================================================
   PART 3 — BULK INSERT INTO STAGING TABLES
   
   EXPLANATION:
   Now we load raw CSV data into staging tables.
   FIELDQUOTE = '"' tells SQL Server to ignore the quotes
   around values like "PRV51001" → stores as PRV51001
============================================================ */
 
-- Load Providers
BULK INSERT stg_Providers
FROM 'C:\Users\shobh\OneDrive\Shobhit Gupta\Data Science\SQL\Healthcare Claims Analytics using SQL & Tableau\Datasets\Train-1542865627584.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR   = '0x0a',   -- Unix line ending fix
    FIRSTROW        = 2,         -- Skip header
    FIELDQUOTE      = '"',       -- Handle quoted values
    TABLOCK
);
GO
PRINT 'Providers loaded: ' + CAST(@@ROWCOUNT AS VARCHAR);

-- Load Patients
BULK INSERT stg_Patients
FROM 'C:\Users\shobh\OneDrive\Shobhit Gupta\Data Science\SQL\Healthcare Claims Analytics using SQL & Tableau\Datasets\Train_Beneficiarydata-1542865627584.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR   = '0x0a',
    FIRSTROW        = 2,
    FIELDQUOTE      = '"',
    TABLOCK
);
GO
PRINT 'Patients loaded: ' + CAST(@@ROWCOUNT AS VARCHAR);
 
-- Load Diagnoses
BULK INSERT stg_Diagnoses
FROM 'C:\Users\shobh\OneDrive\Shobhit Gupta\Data Science\SQL\Healthcare Claims Analytics using SQL & Tableau\Datasets\ICD10codes_clean.csv'
WITH (
    FIELDTERMINATOR = '|',      -- Pipe delimiter now!
    ROWTERMINATOR   = '0x0a',
    FIRSTROW        = 1,
    TABLOCK
);
GO
PRINT 'Diagnoses loaded: ' + CAST(@@ROWCOUNT AS VARCHAR);


-- Load Inpatient Claims
BULK INSERT stg_Inpatient
FROM 'C:\Users\shobh\OneDrive\Shobhit Gupta\Data Science\SQL\Healthcare Claims Analytics using SQL & Tableau\Datasets\Train_Inpatientdata-1542865627584.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR   = '0x0a',
    FIRSTROW        = 2,
    FIELDQUOTE      = '"',
    TABLOCK
);
GO
PRINT 'Inpatient Claims loaded: ' + CAST(@@ROWCOUNT AS VARCHAR);
 
-- Load Outpatient Claims
BULK INSERT stg_Outpatient
FROM 'C:\Users\shobh\OneDrive\Shobhit Gupta\Data Science\SQL\Healthcare Claims Analytics using SQL & Tableau\Datasets\Train_Outpatientdata-1542865627584.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR   = '0x0a',
    FIRSTROW        = 2,
    FIELDQUOTE      = '"',
    TABLOCK
);
GO
PRINT 'Outpatient Claims loaded: ' + CAST(@@ROWCOUNT AS VARCHAR);
 
/* ============================================================
   PART 4 — VERIFY STAGING DATA
   Run these to confirm rows loaded correctly
============================================================ */
 
SELECT 'stg_Providers'  AS TableName, COUNT(*) AS Row_Count FROM stg_Providers   -- ~5,410
UNION ALL
SELECT 'stg_Patients',                COUNT(*) FROM stg_Patients                -- ~138,556
UNION ALL
SELECT 'stg_Diagnoses',               COUNT(*) FROM stg_Diagnoses               -- ~71,704
UNION ALL
SELECT 'stg_Inpatient',               COUNT(*) FROM stg_Inpatient               -- ~40,474
UNION ALL
SELECT 'stg_Outpatient',              COUNT(*) FROM stg_Outpatient;             -- ~10,151
GO
 
 
/* ============================================================
   PART 5 — CREATE FINAL TABLES (Proper Data Types)
============================================================ */
 
-- Final: Providers
CREATE TABLE Providers (
    ProviderID      VARCHAR(20)  NOT NULL,
    PotentialFraud  VARCHAR(5)   NOT NULL,
    CONSTRAINT PK_Providers PRIMARY KEY (ProviderID)
);
GO
 
-- Final: Patients
CREATE TABLE Patients (
    BeneID                          VARCHAR(20)     NOT NULL,
    DOB                             DATE            NULL,
    DOD                             DATE            NULL,
    Gender                          TINYINT         NULL,
    Race                            TINYINT         NULL,
    RenalDiseaseIndicator           VARCHAR(5)      NULL,
    State                           TINYINT         NULL,
    County                          SMALLINT        NULL,
    NoOfMonths_PartACov             TINYINT         NULL,
    NoOfMonths_PartBCov             TINYINT         NULL,
    ChronicCond_Alzheimer           TINYINT         NULL,
    ChronicCond_Heartfailure        TINYINT         NULL,
    ChronicCond_KidneyDisease       TINYINT         NULL,
    ChronicCond_Cancer              TINYINT         NULL,
    ChronicCond_ObstrPulmonary      TINYINT         NULL,
    ChronicCond_Depression          TINYINT         NULL,
    ChronicCond_Diabetes            TINYINT         NULL,
    ChronicCond_IschemicHeart       TINYINT         NULL,
    ChronicCond_Osteoporasis        TINYINT         NULL,
    ChronicCond_Rheumatoid          TINYINT         NULL,
    ChronicCond_Stroke              TINYINT         NULL,
    IPAnnualReimbursementAmt        DECIMAL(12,2)   NULL,
    IPAnnualDeductibleAmt           DECIMAL(12,2)   NULL,
    OPAnnualReimbursementAmt        DECIMAL(12,2)   NULL,
    OPAnnualDeductibleAmt           DECIMAL(12,2)   NULL,
    CONSTRAINT PK_Patients PRIMARY KEY (BeneID)
);
GO

-- Final: Diagnoses
CREATE TABLE Diagnoses (
    DiagnosisCode   VARCHAR(20)     NOT NULL,
    ShortDesc       VARCHAR(100)    NULL,
    LongDesc        VARCHAR(250)    NULL,
    Category        VARCHAR(250)    NULL,
    CONSTRAINT PK_Diagnoses PRIMARY KEY (DiagnosisCode)
);
GO 
-- Final: Claims (Inpatient + Outpatient combined)
CREATE TABLE Claims (
    ClaimID                 VARCHAR(20)     NOT NULL,
    BeneID                  VARCHAR(20)     NOT NULL,
    ProviderID              VARCHAR(20)     NOT NULL,
    ClaimType               VARCHAR(15)     NOT NULL,
    ClaimStartDt            DATE            NULL,
    ClaimEndDt              DATE            NULL,
    InscClaimAmtReimbursed  DECIMAL(12,2)   NULL,
    DeductibleAmtPaid       DECIMAL(12,2)   NULL,
    AttendingPhysician      VARCHAR(20)     NULL,
    OperatingPhysician      VARCHAR(20)     NULL,
    OtherPhysician          VARCHAR(20)     NULL,
    AdmissionDt             DATE            NULL,
    DischargeDt             DATE            NULL,
    DiagnosisGroupCode      VARCHAR(20)     NULL,
    ClmAdmitDiagnosisCode   VARCHAR(20)     NULL,
    ClmDiagnosisCode_1      VARCHAR(20)     NULL,
    ClmDiagnosisCode_2      VARCHAR(20)     NULL,
    ClmDiagnosisCode_3      VARCHAR(20)     NULL,
    ClmDiagnosisCode_4      VARCHAR(20)     NULL,
    ClmDiagnosisCode_5      VARCHAR(20)     NULL,
    ClmDiagnosisCode_6      VARCHAR(20)     NULL,
    ClmDiagnosisCode_7      VARCHAR(20)     NULL,
    ClmDiagnosisCode_8      VARCHAR(20)     NULL,
    ClmDiagnosisCode_9      VARCHAR(20)     NULL,
    ClmDiagnosisCode_10     VARCHAR(20)     NULL,
    ClmProcedureCode_1      VARCHAR(20)     NULL,
    ClmProcedureCode_2      VARCHAR(20)     NULL,
    ClmProcedureCode_3      VARCHAR(20)     NULL,
    ClmProcedureCode_4      VARCHAR(20)     NULL,
    ClmProcedureCode_5      VARCHAR(20)     NULL,
    ClmProcedureCode_6      VARCHAR(20)     NULL,
    CONSTRAINT PK_Claims PRIMARY KEY (ClaimID),
    CONSTRAINT FK_Claims_Patients
        FOREIGN KEY (BeneID)     REFERENCES Patients(BeneID),
    CONSTRAINT FK_Claims_Providers
        FOREIGN KEY (ProviderID) REFERENCES Providers(ProviderID)
);
GO
 
/* ============================================================
   PART 6 — TRANSFORM & INSERT INTO FINAL TABLES
   
   EXPLANATION:
   Here we clean the data while moving it from staging
   to final tables:
   
   - NULLIF(col, 'NA')  → converts 'NA' string to proper NULL
   - TRY_CAST           → safely converts VARCHAR to DATE/DECIMAL
                          returns NULL if conversion fails
   - CONVERT style 101  → converts MM/DD/YYYY date format
                          (used in Outpatient file)
============================================================ */
 
-- Insert into Providers

INSERT INTO Providers (ProviderID, PotentialFraud)
SELECT ProviderID, PotentialFraud
FROM stg_Providers
WHERE ProviderID IS NOT NULL;
GO
PRINT 'Providers inserted: ' + CAST(@@ROWCOUNT AS VARCHAR);


 
-- Insert into Patients
-- Key fix: NULLIF converts 'NA' → NULL for date columns
INSERT INTO Patients
SELECT
    BeneID,
    TRY_CAST(NULLIF(DOB, 'NA') AS DATE),
    TRY_CAST(NULLIF(DOD, 'NA') AS DATE),
    TRY_CAST(NULLIF(Gender, 'NA') AS TINYINT),
    TRY_CAST(NULLIF(Race,   'NA') AS TINYINT),
    NULLIF(RenalDiseaseIndicator, 'NA'),
    TRY_CAST(NULLIF(State,  'NA') AS TINYINT),
    TRY_CAST(NULLIF(County, 'NA') AS SMALLINT),
    TRY_CAST(NULLIF(NoOfMonths_PartACov, 'NA') AS TINYINT),
    TRY_CAST(NULLIF(NoOfMonths_PartBCov, 'NA') AS TINYINT),
    TRY_CAST(NULLIF(ChronicCond_Alzheimer,      'NA') AS TINYINT),
    TRY_CAST(NULLIF(ChronicCond_Heartfailure,   'NA') AS TINYINT),
    TRY_CAST(NULLIF(ChronicCond_KidneyDisease,  'NA') AS TINYINT),
    TRY_CAST(NULLIF(ChronicCond_Cancer,         'NA') AS TINYINT),
    TRY_CAST(NULLIF(ChronicCond_ObstrPulmonary, 'NA') AS TINYINT),
    TRY_CAST(NULLIF(ChronicCond_Depression,     'NA') AS TINYINT),
    TRY_CAST(NULLIF(ChronicCond_Diabetes,       'NA') AS TINYINT),
    TRY_CAST(NULLIF(ChronicCond_IschemicHeart,  'NA') AS TINYINT),
    TRY_CAST(NULLIF(ChronicCond_Osteoporasis,   'NA') AS TINYINT),
    TRY_CAST(NULLIF(ChronicCond_Rheumatoid,     'NA') AS TINYINT),
    TRY_CAST(NULLIF(ChronicCond_Stroke,         'NA') AS TINYINT),
    TRY_CAST(NULLIF(IPAnnualReimbursementAmt,   'NA') AS DECIMAL(12,2)),
    TRY_CAST(NULLIF(IPAnnualDeductibleAmt,      'NA') AS DECIMAL(12,2)),
    TRY_CAST(NULLIF(OPAnnualReimbursementAmt,   'NA') AS DECIMAL(12,2)),
    TRY_CAST(NULLIF(OPAnnualDeductibleAmt,      'NA') AS DECIMAL(12,2))
FROM stg_Patients
WHERE BeneID IS NOT NULL;
GO
PRINT 'Patients inserted: ' + CAST(@@ROWCOUNT AS VARCHAR);

-- Insert into Diagnoses
-- We only need columns 3, 4, 5, 6 from the ICD10 file
INSERT INTO Diagnoses (DiagnosisCode, ShortDesc, LongDesc, Category)
SELECT DISTINCT
    DiagnosisCode,
    ShortDesc,
    LongDesc,
    Category
FROM stg_Diagnoses
WHERE DiagnosisCode IS NOT NULL
  AND LEN(TRIM(DiagnosisCode)) > 0;
GO
PRINT 'Diagnoses inserted: ' + CAST(@@ROWCOUNT AS VARCHAR); 
 
-- Insert Inpatient Claims
-- Dates are YYYY-MM-DD format → TRY_CAST works directly
INSERT INTO Claims
SELECT
    REPLACE(ClaimID, '"', ''),
    REPLACE(BeneID,  '"', ''),
    REPLACE(Provider,'"', '')                           AS ProviderID,
    'Inpatient'                                         AS ClaimType,
    TRY_CAST(NULLIF(ClaimStartDt,  'NA') AS DATE),
    TRY_CAST(NULLIF(ClaimEndDt,    'NA') AS DATE),
    TRY_CAST(NULLIF(InscClaimAmtReimbursed, 'NA') AS DECIMAL(12,2)),
    TRY_CAST(NULLIF(DeductibleAmtPaid,      'NA') AS DECIMAL(12,2)),
    NULLIF(REPLACE(AttendingPhysician, '"', ''), 'NA'),
    NULLIF(REPLACE(OperatingPhysician, '"', ''), 'NA'),
    NULLIF(REPLACE(OtherPhysician,     '"', ''), 'NA'),
    TRY_CAST(NULLIF(AdmissionDt,   'NA') AS DATE),
    TRY_CAST(NULLIF(DischargeDt,   'NA') AS DATE),
    NULLIF(DiagnosisGroupCode,    'NA'),
    NULLIF(ClmAdmitDiagnosisCode, 'NA'),
    NULLIF(ClmDiagnosisCode_1,  'NA'),
    NULLIF(ClmDiagnosisCode_2,  'NA'),
    NULLIF(ClmDiagnosisCode_3,  'NA'),
    NULLIF(ClmDiagnosisCode_4,  'NA'),
    NULLIF(ClmDiagnosisCode_5,  'NA'),
    NULLIF(ClmDiagnosisCode_6,  'NA'),
    NULLIF(ClmDiagnosisCode_7,  'NA'),
    NULLIF(ClmDiagnosisCode_8,  'NA'),
    NULLIF(ClmDiagnosisCode_9,  'NA'),
    NULLIF(ClmDiagnosisCode_10, 'NA'),
    NULLIF(ClmProcedureCode_1,  'NA'),
    NULLIF(ClmProcedureCode_2,  'NA'),
    NULLIF(ClmProcedureCode_3,  'NA'),
    NULLIF(ClmProcedureCode_4,  'NA'),
    NULLIF(ClmProcedureCode_5,  'NA'),
    NULLIF(ClmProcedureCode_6,  'NA')
FROM stg_Inpatient
WHERE REPLACE(ClaimID, '"', '') IS NOT NULL
  AND REPLACE(BeneID,  '"', '') IN (SELECT BeneID     FROM Patients)
  AND REPLACE(Provider,'"', '') IN (SELECT ProviderID FROM Providers);
GO
PRINT 'Inpatient Claims inserted: ' + CAST(@@ROWCOUNT AS VARCHAR);

-- Insert Outpatient Claims
-- Key fix: Dates are MM/DD/YYYY → use CONVERT with style 101
-- Outpatient has NULL for Inpatient-only columns
INSERT INTO Claims
SELECT
    ClaimID,
    BeneID,
    Provider                                            AS ProviderID,
    'Outpatient'                                        AS ClaimType,
    TRY_CONVERT(DATE, NULLIF(ClaimStartDt, 'NA'), 101),
    TRY_CONVERT(DATE, NULLIF(ClaimEndDt,   'NA'), 101),
    TRY_CAST(NULLIF(InscClaimAmtReimbursed, 'NA') AS DECIMAL(12,2)),
    TRY_CAST(NULLIF(DeductibleAmtPaid,      'NA') AS DECIMAL(12,2)),
    NULLIF(AttendingPhysician,  'NA'),
    NULLIF(OperatingPhysician,  'NA'),
    NULLIF(OtherPhysician,      'NA'),
    NULL,
    NULL,
    NULL,
    NULLIF(ClmAdmitDiagnosisCode, 'NA'),
    NULLIF(ClmDiagnosisCode_1,  'NA'),
    NULLIF(ClmDiagnosisCode_2,  'NA'),
    NULLIF(ClmDiagnosisCode_3,  'NA'),
    NULLIF(ClmDiagnosisCode_4,  'NA'),
    NULLIF(ClmDiagnosisCode_5,  'NA'),
    NULLIF(ClmDiagnosisCode_6,  'NA'),
    NULLIF(ClmDiagnosisCode_7,  'NA'),
    NULLIF(ClmDiagnosisCode_8,  'NA'),
    NULLIF(ClmDiagnosisCode_9,  'NA'),
    NULLIF(ClmDiagnosisCode_10, 'NA'),
    NULLIF(ClmProcedureCode_1,  'NA'),
    NULLIF(ClmProcedureCode_2,  'NA'),
    NULLIF(ClmProcedureCode_3,  'NA'),
    NULLIF(ClmProcedureCode_4,  'NA'),
    NULLIF(ClmProcedureCode_5,  'NA'),
    NULLIF(ClmProcedureCode_6,  'NA')
FROM stg_Outpatient
WHERE ClaimID IS NOT NULL
  AND BeneID   IN (SELECT BeneID     FROM Patients)
  AND Provider IN (SELECT ProviderID FROM Providers);
GO
PRINT 'Outpatient Claims inserted: ' + CAST(@@ROWCOUNT AS VARCHAR); 
 

-- Remove quotes from stg_Providers
UPDATE stg_Providers
SET ProviderID     = REPLACE(ProviderID,    '"', ''),
    PotentialFraud = REPLACE(PotentialFraud,'"', '');
GO
PRINT 'Providers cleaned: ' + CAST(@@ROWCOUNT AS VARCHAR);

-- Remove quotes from stg_Patients
UPDATE stg_Patients
SET BeneID = REPLACE(BeneID, '"', ''),
    DOB    = REPLACE(DOB,    '"', ''),
    DOD    = REPLACE(DOD,    '"', '');
GO
PRINT 'Patients cleaned: ' + CAST(@@ROWCOUNT AS VARCHAR);


-- Verify that the data is loaded correctly
SELECT 'Providers' AS TableName, COUNT(*) AS Row_Count FROM Providers
UNION ALL
SELECT 'Patients',  COUNT(*) FROM Patients
UNION ALL
SELECT 'Diagnoses', COUNT(*) FROM Diagnoses
UNION ALL
SELECT 'Claims',    COUNT(*) FROM Claims;

/* ============================================================
   PART 7 — FINAL VERIFICATION
   Run these to confirm everything is loaded correctly
============================================================ */
 
-- Row counts in final tables
SELECT 'Providers' AS TableName, COUNT(*) AS Row_Count FROM Providers
UNION ALL
SELECT 'Patients',  COUNT(*) FROM Patients
UNION ALL
SELECT 'Diagnoses', COUNT(*) FROM Diagnoses
UNION ALL
SELECT 'Claims',    COUNT(*) FROM Claims;
GO
 
-- Claims split by type
SELECT 
    ClaimType,
    COUNT(*)                        AS TotalClaims,
    SUM(InscClaimAmtReimbursed)     AS TotalReimbursed
FROM Claims
GROUP BY ClaimType;
GO
 
-- Fraud distribution
SELECT 
    PotentialFraud,
    COUNT(*)    AS ProviderCount
FROM Providers
GROUP BY PotentialFraud;
GO
 
-- Sample data check
SELECT TOP 5 * FROM Providers;
SELECT TOP 5 * FROM Patients;
SELECT TOP 5 * FROM Claims WHERE ClaimType = 'Inpatient';
SELECT TOP 5 * FROM Claims WHERE ClaimType = 'Outpatient';
GO
 
 
/* ============================================================
   PART 8 — CLEANUP STAGING TABLES
   Run this ONLY after verifying final tables look correct!
   Removes staging tables to keep database clean.
============================================================ */
 
-- DROP TABLE stg_Providers;
-- DROP TABLE stg_Patients;
-- DROP TABLE stg_Diagnoses;
-- DROP TABLE stg_Inpatient;
-- DROP TABLE stg_Outpatient;
-- GO
 
/* ============================================================
   DATABASE SETUP COMPLETE!
============================================================ */
 
