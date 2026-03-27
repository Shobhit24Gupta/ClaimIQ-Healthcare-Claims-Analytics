# 🏥 ClaimIQ — Healthcare Claims Analytics

## 📌 Project Overview
An end-to-end data analytics project analyzing 266,000+ Medicare healthcare claims 
to uncover fraud patterns, provider performance trends, and patient risk profiles 
using SQL Server and Tableau Public.

**Tools Used:** SQL Server 2017 Developer Edition | Tableau Public 2026.1

---

## 🎯 Business Problem
Healthcare fraud costs the US billions of dollars every year.
This project analyzes Medicare claims data to:
- Identify providers with high fraud risk
- Analyze billing patterns between fraud vs legitimate providers
- Understand patient demographics and chronic conditions
- Compare Inpatient vs Outpatient claim costs
- Track monthly claim volume and reimbursement trends

---

## 📊 Live Tableau Dashboard
🔗 [View Interactive Dashboard on Tableau Public](https://public.tableau.com/app/profile/shobhit.gupta6409/viz/HealthcareClaimsAnalytics/Dashboard4-MonthlyTrends)

| Dashboard | Description |
|-----------|-------------|
| Dashboard 1 — Claims Overview | KPI tiles, Inpatient vs Outpatient cost & volume |
| Dashboard 2 — Fraud Analytics | Top fraud providers, Fraud vs Legit billing comparison |
| Dashboard 3 — Patient Insights | Demographics, Chronic conditions, High risk patients |
| Dashboard 4 — Monthly Trends | Claim volume & revenue trends over 14 months |

### Dashboard 1 — Claims Overview
![Claims Overview](https://public.tableau.com/app/profile/shobhit.gupta6409/viz/HealthcareClaimsAnalytics/Dashboard1-ClaimsOverview?publish=yes)

### Dashboard 2 — Fraud Analytics
![Fraud Analytics](https://public.tableau.com/app/profile/shobhit.gupta6409/viz/HealthcareClaimsAnalytics/Dashboard2-FraudAnalytics?publish=yes)

### Dashboard 3 — Patient Insights
![Patient Insights](https://public.tableau.com/app/profile/shobhit.gupta6409/viz/HealthcareClaimsAnalytics/Dashboard3-PatientInsights?publish=yes)

### Dashboard 4 — Monthly Trends
![Monthly Trends](https://public.tableau.com/app/profile/shobhit.gupta6409/viz/HealthcareClaimsAnalytics/Dashboard4-MonthlyTrends?publish=yes)

---

## 🔍 Key Insights

### Claims
- **50,625 total claims** across Inpatient and Outpatient
- Inpatient claims average **$10,088** vs Outpatient **$297** — a 34x difference
- Total reimbursed: **$411M** across the dataset

### Fraud
- Top 10 highest-paid providers are **all flagged for fraud**
- Fraud providers average **$10,000+** per claim vs legitimate providers
- Fraudulent providers account for majority of total reimbursements

### Patients
- **138,556 unique Medicare beneficiaries** with average age of 89
- Cancer is the most prevalent chronic condition
- High risk patients carry all **11 chronic conditions** simultaneously

### Trends
- Data spans **Nov 2008 – Dec 2009** (14 months)
- Inpatient claims dominate monthly reimbursement at **99%+ of total paid**

---

## 🗄️ Database Details
**Database:** HealthcareClaims_DB (SQL Server 2017)

| Table | Rows | Description |
|-------|------|-------------|
| Providers | 5,410 | Provider details + fraud flag |
| Patients | 138,556 | Patient demographics + chronic conditions |
| Diagnoses | 71,704 | ICD-10 diagnosis code reference |
| Claims | 50,625 | Inpatient + Outpatient claims combined |

---

## 📊 SQL Views Created for Tableau

| View Name | Based On | Purpose |
|-----------|----------|---------|
| `vw_ClaimsByType` | Query 2 | Inpatient vs Outpatient comparison |
| `vw_ProviderSummary` | Query 3 + 4 | Provider KPIs + fraud metrics |
| `vw_PatientDemographics` | Query 5 | Gender/Race + chronic conditions |
| `vw_DiagnosisDetail` | Query 6 | ICD code frequency analysis |
| `vw_MonthlyTrends` | Query 7 | Month-over-month claim trends |
| `vw_PatientRiskProfile` | Query 8 | Patient risk scoring |

---

## 📁 Project Structure
```
ClaimIQ-Healthcare-Claims-Analytics/
│
├── data/
│   ├── ClaimIQ_KPI.csv
│   ├── ClaimIQ_ClaimsByType.csv
│   ├── ClaimIQ_ProviderSummary.csv
│   ├── ClaimIQ_PatientDemographics.csv
│   ├── ClaimIQ_MonthlyTrends.csv
│   └── ClaimIQ_PatientRiskProfile.csv
│
├── sql/
│   ├── 01_create_database.sql       ← Database & table creation
│   ├── 02_staging_tables.sql        ← Staging table scripts
│   ├── 03_bulk_insert.sql           ← Data loading scripts
│   ├── 04_data_cleaning.sql         ← Data transformation
│   ├── 05_analysis_queries.sql      ← 8 analysis queries
│   └── 06_views_for_tableau.sql     ← 6 views for Tableau
│
├── tableau/
│   └── ClaimIQ_Dashboard.twbx       ← Packaged Tableau workbook
│
├── screenshots/
│   ├── dashboard1_claims_overview.png
│   ├── dashboard2_fraud_analytics.png
│   ├── dashboard3_patient_insights.png
│   └── dashboard4_monthly_trends.png
│
└── README.md
```

---

## 📂 Data Sources
This project uses real-world Medicare claims data publicly available on Kaggle.

### Dataset 1 — Healthcare Provider Fraud Detection
| File Name | Used As | Rows |
|-----------|---------|------|
| `Train-1542865627584.csv` | Providers Table | 5,410 |
| `Train_Beneficiarydata-1542865627584.csv` | Patients Table | 138,556 |
| `Train_Inpatientdata-1542865627584.csv` | Inpatient Claims | 40,474 |
| `Train_Outpatientdata-1542865627584.csv` | Outpatient Claims | 10,151 |

### Dataset 2 — ICD-10 Diagnosis Codes
| File Name | Used As | Rows |
|-----------|---------|------|
| `ICD10codes_clean.csv` | Diagnoses Table | 71,704 |

> ⚠️ **Important:** ICD10 file uses **pipe `\|` delimiter** — use `FIELDTERMINATOR = '\|'`

---

## 📊 Combined Dataset Summary
| Table | Source File | Rows |
|-------|------------|------|
| Providers | Train-1542865627584.csv | 5,410 |
| Patients | Train_Beneficiarydata-...csv | 138,556 |
| Diagnoses | ICD10codes_clean.csv | 71,704 |
| Claims | Inpatient + Outpatient combined | 50,625 |
| **Total** | | **266,295** |

---

## 🛠️ Technical Skills Demonstrated
- **SQL Server** — Database design, staging tables, bulk insert, data cleaning
- **T-SQL** — CTEs, window functions, CASE statements, aggregations
- **SQL Views** — 6 reusable views abstracting complex queries for Tableau
- **Tableau Public** — 4 interactive dashboards, KPI tiles, line/bar charts
- **Data Modeling** — Star schema design with fact and dimension tables
- **Healthcare Domain** — ICD-10 codes, Medicare claims, fraud detection, chronic conditions

---

## 👤 Author
**Shobhit Gupta**
Senior Business Analyst | US Healthcare | Data Analytics
🔗 [LinkedIn](https://www.linkedin.com/in/iamshobhitgupta/)
