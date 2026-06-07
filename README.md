# 📊 Investor Churn Intelligence Platform

**Analysing why investors leave — and how to retain them**

> A full end-to-end data analytics project built for a fintech investment platform.  
> Tools: **MySQL · Python · Power BI · Matplotlib · Seaborn**

---

## 🔍 Project Overview

An investment platform with **64,374 investor records** and a **47.4% churn rate** — nearly 1 in 2 investors stops using the platform. This project identifies who is churning, why they leave, and delivers actionable retention strategies backed by data.

This is not just an analysis — it is a business intelligence system with:
- A clean relational database schema
- 30+ SQL queries covering EDA, cohort analysis, window functions, and risk scoring
- 8 Python visualisation charts
- A Power BI-ready enriched dataset
- A 5-slide executive insight deck

---

## 📁 Project Structure

```
investor-churn-analysis/
│
├── churn_analysis.sql              # Full MySQL analysis — schema to advanced queries
├── visualisations.py               # Python charts (Matplotlib + Seaborn)
├── investor_churn_powerbi.csv      # Enriched dataset for Power BI dashboard
├── Investor_Churn_Intelligence_Platform.pptx   # 5-slide executive deck
│
├── charts/
│   ├── 01_churn_overview.png
│   ├── 02_churn_by_contract.png
│   ├── 03_churn_by_tenure.png
│   ├── 04_payment_delay_churn.png
│   ├── 05_engagement_churn.png
│   ├── 06_subscription_churn.png
│   ├── 07_cohort_heatmap.png
│   └── 08_support_calls_churn.png
│
└── README.md
```

---

## 📊 Dataset

| Field | Description |
|---|---|
| CustomerID | Unique investor identifier |
| Age | Investor age (18–65) |
| Gender | Male / Female |
| Tenure | Months since onboarding |
| UsageFrequency | Platform logins per month |
| SupportCalls | Support tickets raised |
| PaymentDelay | Days delayed on last payment |
| SubscriptionType | Basic / Standard / Premium |
| ContractLength | Monthly / Quarterly / Annual |
| TotalSpend | Lifetime investment amount |
| LastInteraction | Days since last login |
| **Churn** | **Target — 1 = churned, 0 = active** |

**Source:** Kaggle — Customer Churn Dataset (adapted for fintech/investment context)  
**Records:** 64,374 | **Churned:** 30,493 | **Active:** 33,881

---

## 🔑 Key Findings

| Finding | Insight |
|---|---|
| **Monthly contracts churn most** | 51.6% churn vs 44.0% for Quarterly — 7.6pp gap |
| **Mid-tenure danger zone** | Churn spikes to 55–56% at months 25–60 |
| **Payment delay = churn signal** | 21+ day delay investors churn at significantly higher rates |
| **High support calls predict churn** | Churned investors averaged 6.4 calls vs 4.5 for active |
| **Female investors churn more** | 55.0% churn vs 38.6% for male — demographic gap |
| **Older investors churn more** | 56–65 age group churn rate: 52.7% |

---

## 🛠️ SQL Analysis Sections

The `churn_analysis.sql` file is organised into 8 sections:

1. **Schema & Data Load** — Table creation and CSV import
2. **Overview & Basic Metrics** — Overall churn rate, gender breakdown, status comparison
3. **Segmentation Analysis** — By subscription, contract type, age group
4. **Tenure Cohort Analysis** — Churn by tenure band, cohort retention matrix
5. **Risk & Behavioural Signals** — Support calls, payment delay, usage frequency, recency
6. **Window Functions** — RANK, NTILE, PERCENT_RANK, cumulative churn, LAG/LEAD
7. **High-Value Investor Retention** — Revenue at risk, early warning system
8. **Funnel Analysis** — Engagement funnel, retention by engagement tier

---

## 📈 Power BI Dashboard Guide

Import `investor_churn_powerbi.csv` into Power BI Desktop.

**Recommended visuals:**

| Visual | Fields |
|---|---|
| KPI Card | Churn Rate = DIVIDE(SUM(Churn), COUNT(CustomerID)) |
| Donut Chart | ChurnStatus (Active vs Churned) |
| Bar Chart | Churn Rate by ContractLength |
| Heatmap | TenureBand × ContractLength → Churn Rate |
| Funnel | EngagementTier → Churn Rate |
| Table | Top 20 at-risk investors by RiskScore |

**Key calculated columns already in the CSV:**
- `ChurnStatus` — Active / Churned label
- `AgeGroup` — 18-25, 26-35, 36-45, 46-55, 56-65
- `TenureBand` — 0-12m through 60m+
- `EngagementTier` — Highly / Moderately / Passively / Disengaged
- `PaymentDelayBand` — No Delay through 21+ Days
- `RiskScore` — Composite early-warning score

---

## 💡 Strategic Recommendations

1. **Convert monthly users to quarterly/annual plans** — 51.6% monthly churn vs 44.0% quarterly. Incentivise upgrades with fee waivers.
2. **Launch a Month-24 loyalty programme** — Churn spikes at month 25. A milestone reward at exactly month 24 intercepts the highest-risk transition.
3. **Automated risk flagging** — Investors with 5+ support calls AND 15+ day payment delay should trigger a CRM intervention workflow.
4. **Re-engage dormant investors** — Last interaction > 22 days = highest churn segment. Personalised push notifications and RM outreach.

---

## ⚙️ Setup & Run

### MySQL
```sql
-- Create database and run the full script
mysql -u root -p < churn_analysis.sql
```

### Python (charts)
```bash
pip install pandas matplotlib seaborn
python visualisations.py
```

---

## 👤 Author

**Afsar Ahamed**  
Data Analyst | ECE, MVJ College of Engineering | CGPA 8.4  
📧 afsarmulla256@gmail.com  
🔗 [linkedin.com/in/afsar-ahamed2](https://www.linkedin.com/in/afsar-ahamed2)

---

*Built as a capstone project applying SQL, Python, and Power BI to a real-world fintech business problem.*
