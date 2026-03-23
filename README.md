# 🏥 ClaimIQ — Healthcare Claims Analytics

## 📌 Project Overview
An end-to-end data analytics project analyzing 266,000+ 
Medicare healthcare claims to uncover fraud patterns, 
denial rates, and provider performance trends.

**Tools Used:** SQL Server 2017 | Tableau Public 2020.4

---

## 🎯 Business Problem
Healthcare fraud costs the US billions of dollars every year.
This project analyzes Medicare claims data to:
- Identify providers with high fraud risk
- Understand claim denial patterns
- Analyze patient demographics and chronic conditions
- Compare Inpatient vs Outpatient claim costs

---

## 🗄️ Database Details

**Database:** HealthcareClaims_DB (SQL Server 2017)

| Table      | Rows    | Description                        |
|------------|---------|------------------------------------|
| Providers  | 5,410   | Provider details + fraud flag      |
| Patients   | 138,556 | Patient demographics + conditions  |
| Diagnoses  | 71,704  | ICD-10 diagnosis code reference    |
| Claims     | 50,625  | Inpatient + Outpatient claims      |

---

## 📁 Project Structure
```
ClaimIQ-Healthcare-Claims-Analytics/
│
├── data/               ← Dataset source information
├── sql/
│   ├── 01_create_database.sql     ← Database & table creation
│   ├── 02_staging_tables.sql      ← Staging table scripts
│   ├── 03_bulk_insert.sql         ← Data loading scripts
│   ├── 04_data_cleaning.sql       ← Data transformation
│   ├── 05_analysis_queries.sql    ← Analysis queries
│   └── 06_views_for_tableau.sql   ← Views for Tableau
├── tableau/
│   └── ClaimIQ_Dashboard.twbx    ← Tableau workbook
└── README.md
```

---

## 📊 Dashboards (Coming Soon)
- Dashboard 1 → Claims Overview
- Dashboard 2 → Provider Analysis  
- Dashboard 3 → Patient Demographics

---

## 📂 Data Source
- [Healthcare Provider Fraud Detection — Kaggle]
- ICD-10 Diagnosis Codes (CMS.gov)

---

## 👤 Author
**Shobhit Gupta**  
US Healthcare | Data Analytics  
[https://www.linkedin.com/in/iamshobhitgupta/]
