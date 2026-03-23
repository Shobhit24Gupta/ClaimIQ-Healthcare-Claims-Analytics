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

# 📂 Data Sources

This project uses real-world Medicare claims data publicly 
available on Kaggle.

---

### Dataset 1 — Healthcare Provider Fraud Detection

| File Name | Used As | Rows |
|-----------|---------|------|
| `Train-1542865627584.csv` | Providers Table | 5,410 |
| `Train_Beneficiarydata-1542865627584.csv` | Patients Table | 138,556 |
| `Train_Inpatientdata-1542865627584.csv` | Inpatient Claims | 40,474 |
| `Train_Outpatientdata-1542865627584.csv` | Outpatient Claims | 10,151 |

---

### Dataset 2 — ICD-10 Diagnosis Codes
> 🔗 Source: Cleaned and prepared

| File Name | Used As | Rows |
|-----------|---------|------|
| `ICD10codes_clean.csv` | Diagnoses Table | 71,704 |

> ⚠️ **Important:** This file uses **pipe `\|` delimiter** 
> instead of comma used `FIELDTERMINATOR = '\|'` 

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

## 👤 Author
**Shobhit Gupta**  
US Healthcare | Data Analytics  
[https://www.linkedin.com/in/iamshobhitgupta/]
