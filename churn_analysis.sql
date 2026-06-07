-- ============================================================
--  INVESTOR CHURN INTELLIGENCE PLATFORM
--  Author  : Afsar Ahamed | Data Analyst
--  Dataset : 64,374 investor records
--  Tools   : MySQL 8.0+
-- ============================================================

-- ────────────────────────────────────────────────────────────
--  SECTION 0 : SCHEMA & DATA LOAD
-- ────────────────────────────────────────────────────────────

CREATE DATABASE IF NOT EXISTS investor_churn_db;
USE investor_churn_db;

DROP TABLE IF EXISTS investors;

CREATE TABLE investors (
    CustomerID        INT           PRIMARY KEY,
    Age               INT           NOT NULL,
    Gender            VARCHAR(10)   NOT NULL,
    Tenure            INT           NOT NULL COMMENT 'Months since onboarding',
    UsageFrequency    INT           NOT NULL COMMENT 'Platform logins per month',
    SupportCalls      INT           NOT NULL COMMENT 'Support tickets raised',
    PaymentDelay      INT           NOT NULL COMMENT 'Days delayed on last payment',
    SubscriptionType  VARCHAR(20)   NOT NULL COMMENT 'Basic / Standard / Premium',
    ContractLength    VARCHAR(20)   NOT NULL COMMENT 'Monthly / Quarterly / Annual',
    TotalSpend        DECIMAL(10,2) NOT NULL COMMENT 'Lifetime investment amount (USD)',
    LastInteraction   INT           NOT NULL COMMENT 'Days since last login',
    Churn             TINYINT(1)    NOT NULL COMMENT '1 = churned, 0 = active'
);

-- Load CSV (update path to your local file location)
LOAD DATA INFILE '/var/lib/mysql-files/customer_churn_dataset-testing-master.csv'
INTO TABLE investors
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(CustomerID, Age, Gender, Tenure, UsageFrequency, SupportCalls,
 PaymentDelay, SubscriptionType, ContractLength, TotalSpend,
 LastInteraction, Churn);


-- ────────────────────────────────────────────────────────────
--  SECTION 1 : OVERVIEW & BASIC METRICS
-- ────────────────────────────────────────────────────────────

-- 1.1  Overall churn rate
SELECT
    COUNT(*)                                          AS total_investors,
    SUM(Churn)                                        AS total_churned,
    COUNT(*) - SUM(Churn)                             AS total_active,
    ROUND(SUM(Churn) * 100.0 / COUNT(*), 2)          AS churn_rate_pct,
    ROUND((COUNT(*) - SUM(Churn)) * 100.0 / COUNT(*), 2) AS retention_rate_pct
FROM investors;

-- 1.2  Gender distribution and churn
SELECT
    Gender,
    COUNT(*)                                          AS total,
    SUM(Churn)                                        AS churned,
    ROUND(SUM(Churn) * 100.0 / COUNT(*), 2)          AS churn_rate_pct,
    ROUND(AVG(TotalSpend), 2)                         AS avg_spend
FROM investors
GROUP BY Gender
ORDER BY churn_rate_pct DESC;

-- 1.3  Average metrics: churned vs active
SELECT
    CASE WHEN Churn = 1 THEN 'Churned' ELSE 'Active' END AS investor_status,
    COUNT(*)                              AS count,
    ROUND(AVG(Age), 1)                   AS avg_age,
    ROUND(AVG(Tenure), 1)                AS avg_tenure_months,
    ROUND(AVG(UsageFrequency), 1)        AS avg_logins_per_month,
    ROUND(AVG(SupportCalls), 1)          AS avg_support_calls,
    ROUND(AVG(PaymentDelay), 1)          AS avg_payment_delay_days,
    ROUND(AVG(TotalSpend), 2)            AS avg_total_spend,
    ROUND(AVG(LastInteraction), 1)       AS avg_days_since_last_login
FROM investors
GROUP BY Churn
ORDER BY Churn DESC;


-- ────────────────────────────────────────────────────────────
--  SECTION 2 : SEGMENTATION ANALYSIS
-- ────────────────────────────────────────────────────────────

-- 2.1  Churn by subscription type
SELECT
    SubscriptionType,
    COUNT(*)                                          AS total_investors,
    SUM(Churn)                                        AS churned,
    ROUND(SUM(Churn) * 100.0 / COUNT(*), 2)          AS churn_rate_pct,
    ROUND(AVG(TotalSpend), 2)                         AS avg_spend,
    ROUND(AVG(Tenure), 1)                             AS avg_tenure
FROM investors
GROUP BY SubscriptionType
ORDER BY churn_rate_pct DESC;

-- 2.2  Churn by contract length
SELECT
    ContractLength,
    COUNT(*)                                          AS total_investors,
    SUM(Churn)                                        AS churned,
    ROUND(SUM(Churn) * 100.0 / COUNT(*), 2)          AS churn_rate_pct,
    ROUND(AVG(TotalSpend), 2)                         AS avg_spend
FROM investors
GROUP BY ContractLength
ORDER BY churn_rate_pct DESC;

-- 2.3  Cross-segment: Subscription × Contract
SELECT
    SubscriptionType,
    ContractLength,
    COUNT(*)                                          AS total,
    SUM(Churn)                                        AS churned,
    ROUND(SUM(Churn) * 100.0 / COUNT(*), 2)          AS churn_rate_pct
FROM investors
GROUP BY SubscriptionType, ContractLength
ORDER BY churn_rate_pct DESC;

-- 2.4  Churn by age group
SELECT
    CASE
        WHEN Age BETWEEN 18 AND 25 THEN '18-25'
        WHEN Age BETWEEN 26 AND 35 THEN '26-35'
        WHEN Age BETWEEN 36 AND 45 THEN '36-45'
        WHEN Age BETWEEN 46 AND 55 THEN '46-55'
        ELSE '56-65'
    END                                               AS age_group,
    COUNT(*)                                          AS total,
    SUM(Churn)                                        AS churned,
    ROUND(SUM(Churn) * 100.0 / COUNT(*), 2)          AS churn_rate_pct,
    ROUND(AVG(TotalSpend), 2)                         AS avg_spend
FROM investors
GROUP BY age_group
ORDER BY age_group;


-- ────────────────────────────────────────────────────────────
--  SECTION 3 : TENURE COHORT ANALYSIS
-- ────────────────────────────────────────────────────────────

-- 3.1  Churn by tenure band
SELECT
    CASE
        WHEN Tenure BETWEEN 0  AND 12 THEN '0-12 months'
        WHEN Tenure BETWEEN 13 AND 24 THEN '13-24 months'
        WHEN Tenure BETWEEN 25 AND 36 THEN '25-36 months'
        WHEN Tenure BETWEEN 37 AND 48 THEN '37-48 months'
        WHEN Tenure BETWEEN 49 AND 60 THEN '49-60 months'
        ELSE '60+ months'
    END                                               AS tenure_band,
    COUNT(*)                                          AS total,
    SUM(Churn)                                        AS churned,
    ROUND(SUM(Churn) * 100.0 / COUNT(*), 2)          AS churn_rate_pct,
    ROUND(AVG(TotalSpend), 2)                         AS avg_spend,
    ROUND(AVG(UsageFrequency), 1)                     AS avg_usage
FROM investors
GROUP BY tenure_band
ORDER BY MIN(Tenure);

-- 3.2  Cohort retention matrix: tenure × contract type
SELECT
    CASE
        WHEN Tenure BETWEEN 0  AND 12 THEN '0-12m'
        WHEN Tenure BETWEEN 13 AND 24 THEN '13-24m'
        WHEN Tenure BETWEEN 25 AND 36 THEN '25-36m'
        WHEN Tenure BETWEEN 37 AND 48 THEN '37-48m'
        ELSE '49-60m'
    END                                               AS tenure_band,
    ContractLength,
    COUNT(*)                                          AS total,
    ROUND((COUNT(*) - SUM(Churn)) * 100.0 / COUNT(*), 2) AS retention_rate_pct
FROM investors
GROUP BY tenure_band, ContractLength
ORDER BY MIN(Tenure), ContractLength;


-- ────────────────────────────────────────────────────────────
--  SECTION 4 : RISK & BEHAVIOURAL SIGNALS
-- ────────────────────────────────────────────────────────────

-- 4.1  High-risk investor profile (top churn drivers)
SELECT
    CASE
        WHEN SupportCalls >= 7 THEN 'High (7+)'
        WHEN SupportCalls BETWEEN 4 AND 6 THEN 'Medium (4-6)'
        ELSE 'Low (0-3)'
    END                                               AS support_call_band,
    COUNT(*)                                          AS total,
    SUM(Churn)                                        AS churned,
    ROUND(SUM(Churn) * 100.0 / COUNT(*), 2)          AS churn_rate_pct
FROM investors
GROUP BY support_call_band
ORDER BY churn_rate_pct DESC;

-- 4.2  Payment delay impact on churn
SELECT
    CASE
        WHEN PaymentDelay = 0       THEN 'No Delay'
        WHEN PaymentDelay <= 10     THEN '1-10 Days'
        WHEN PaymentDelay <= 20     THEN '11-20 Days'
        ELSE '21+ Days'
    END                                               AS delay_band,
    COUNT(*)                                          AS total,
    SUM(Churn)                                        AS churned,
    ROUND(SUM(Churn) * 100.0 / COUNT(*), 2)          AS churn_rate_pct,
    ROUND(AVG(TotalSpend), 2)                         AS avg_spend
FROM investors
GROUP BY delay_band
ORDER BY churn_rate_pct DESC;

-- 4.3  Usage frequency vs churn
SELECT
    CASE
        WHEN UsageFrequency <= 5    THEN 'Very Low (≤5)'
        WHEN UsageFrequency <= 10   THEN 'Low (6-10)'
        WHEN UsageFrequency <= 20   THEN 'Medium (11-20)'
        ELSE 'High (21+)'
    END                                               AS usage_band,
    COUNT(*)                                          AS total,
    SUM(Churn)                                        AS churned,
    ROUND(SUM(Churn) * 100.0 / COUNT(*), 2)          AS churn_rate_pct
FROM investors
GROUP BY usage_band
ORDER BY churn_rate_pct DESC;

-- 4.4  Last interaction recency vs churn
SELECT
    CASE
        WHEN LastInteraction <= 7   THEN 'Active (≤7 days)'
        WHEN LastInteraction <= 15  THEN 'Moderate (8-15 days)'
        WHEN LastInteraction <= 22  THEN 'At Risk (16-22 days)'
        ELSE 'Dormant (23+ days)'
    END                                               AS recency_band,
    COUNT(*)                                          AS total,
    SUM(Churn)                                        AS churned,
    ROUND(SUM(Churn) * 100.0 / COUNT(*), 2)          AS churn_rate_pct
FROM investors
GROUP BY recency_band
ORDER BY churn_rate_pct DESC;


-- ────────────────────────────────────────────────────────────
--  SECTION 5 : WINDOW FUNCTIONS — ADVANCED ANALYTICS
-- ────────────────────────────────────────────────────────────

-- 5.1  Rank investors by total spend within each subscription type
SELECT
    CustomerID,
    SubscriptionType,
    TotalSpend,
    Churn,
    RANK() OVER (PARTITION BY SubscriptionType ORDER BY TotalSpend DESC)  AS spend_rank,
    ROUND(AVG(TotalSpend) OVER (PARTITION BY SubscriptionType), 2)        AS avg_spend_in_segment,
    TotalSpend - AVG(TotalSpend) OVER (PARTITION BY SubscriptionType)     AS spend_vs_segment_avg
FROM investors
ORDER BY SubscriptionType, spend_rank
LIMIT 30;

-- 5.2  Cumulative churn count ordered by tenure (trend over time)
SELECT
    Tenure,
    COUNT(*)                                               AS investors_at_tenure,
    SUM(Churn)                                             AS churned_at_tenure,
    SUM(SUM(Churn)) OVER (ORDER BY Tenure ROWS UNBOUNDED PRECEDING) AS cumulative_churn,
    ROUND(SUM(Churn) * 100.0 / COUNT(*), 2)               AS churn_rate_pct
FROM investors
GROUP BY Tenure
ORDER BY Tenure;

-- 5.3  Support call percentile ranking
SELECT
    CustomerID,
    SupportCalls,
    Churn,
    NTILE(4) OVER (ORDER BY SupportCalls)                 AS support_quartile,
    PERCENT_RANK() OVER (ORDER BY SupportCalls)           AS support_percentile
FROM investors
ORDER BY SupportCalls DESC
LIMIT 20;

-- 5.4  Rolling 5-tenure avg churn rate (smoothed trend)
WITH tenure_churn AS (
    SELECT
        Tenure,
        ROUND(AVG(Churn) * 100, 2) AS churn_rate
    FROM investors
    GROUP BY Tenure
)
SELECT
    Tenure,
    churn_rate,
    ROUND(AVG(churn_rate) OVER (ORDER BY Tenure ROWS BETWEEN 2 PRECEDING AND 2 FOLLOWING), 2) AS rolling_avg_churn
FROM tenure_churn
ORDER BY Tenure;

-- 5.5  LAG: detect churn acceleration — compare each tenure to previous
WITH tenure_churn AS (
    SELECT
        Tenure,
        ROUND(AVG(Churn) * 100, 2) AS churn_rate
    FROM investors
    GROUP BY Tenure
)
SELECT
    Tenure,
    churn_rate,
    LAG(churn_rate) OVER (ORDER BY Tenure)                               AS prev_tenure_churn,
    ROUND(churn_rate - LAG(churn_rate) OVER (ORDER BY Tenure), 2)        AS churn_delta
FROM tenure_churn
ORDER BY Tenure;


-- ────────────────────────────────────────────────────────────
--  SECTION 6 : HIGH-VALUE INVESTOR RETENTION
-- ────────────────────────────────────────────────────────────

-- 6.1  Top 10% spenders who churned (revenue leakage)
WITH spend_ranks AS (
    SELECT *,
        NTILE(10) OVER (ORDER BY TotalSpend DESC) AS spend_decile
    FROM investors
)
SELECT
    COUNT(*)                                          AS high_value_churned,
    ROUND(AVG(TotalSpend), 2)                         AS avg_lost_spend,
    SUM(TotalSpend)                                   AS total_revenue_at_risk,
    ROUND(AVG(Tenure), 1)                             AS avg_tenure,
    ROUND(AVG(SupportCalls), 1)                       AS avg_support_calls
FROM spend_ranks
WHERE spend_decile = 1 AND Churn = 1;

-- 6.2  High-value active investors at risk (early warning)
SELECT
    CustomerID,
    Age,
    Gender,
    Tenure,
    SubscriptionType,
    ContractLength,
    TotalSpend,
    SupportCalls,
    PaymentDelay,
    LastInteraction,
    -- Risk score: higher = more likely to churn
    (SupportCalls * 2 + PaymentDelay + LastInteraction - UsageFrequency) AS risk_score
FROM investors
WHERE Churn = 0
  AND TotalSpend > (SELECT PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY TotalSpend) FROM investors)
ORDER BY risk_score DESC
LIMIT 20;

-- 6.3  Revenue at risk by segment
SELECT
    SubscriptionType,
    ContractLength,
    SUM(CASE WHEN Churn = 1 THEN TotalSpend ELSE 0 END)  AS revenue_lost,
    SUM(CASE WHEN Churn = 0 THEN TotalSpend ELSE 0 END)  AS revenue_retained,
    ROUND(SUM(CASE WHEN Churn = 1 THEN TotalSpend ELSE 0 END) * 100.0
          / SUM(TotalSpend), 2)                          AS pct_revenue_at_risk
FROM investors
GROUP BY SubscriptionType, ContractLength
ORDER BY revenue_lost DESC;


-- ────────────────────────────────────────────────────────────
--  SECTION 7 : FUNNEL ANALYSIS (ENGAGEMENT → RETENTION)
-- ────────────────────────────────────────────────────────────

-- 7.1  Investor engagement funnel
SELECT
    'Total Investors'           AS funnel_stage,
    COUNT(*)                    AS count,
    100.0                       AS pct_of_total
FROM investors
UNION ALL
SELECT
    'Active Users (login ≤15 days)',
    COUNT(*),
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM investors), 2)
FROM investors WHERE LastInteraction <= 15
UNION ALL
SELECT
    'Regular Users (usage ≥10/mo)',
    COUNT(*),
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM investors), 2)
FROM investors WHERE UsageFrequency >= 10 AND LastInteraction <= 15
UNION ALL
SELECT
    'Low Risk (support calls ≤3)',
    COUNT(*),
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM investors), 2)
FROM investors WHERE UsageFrequency >= 10 AND LastInteraction <= 15 AND SupportCalls <= 3
UNION ALL
SELECT
    'Retained (no payment delay)',
    COUNT(*),
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM investors), 2)
FROM investors WHERE UsageFrequency >= 10 AND LastInteraction <= 15 AND SupportCalls <= 3 AND PaymentDelay <= 10 AND Churn = 0;

-- 7.2  Churn rate by engagement level (actionable retention buckets)
SELECT
    CASE
        WHEN UsageFrequency >= 20 AND LastInteraction <= 7  THEN 'Highly Engaged'
        WHEN UsageFrequency >= 10 AND LastInteraction <= 15 THEN 'Moderately Engaged'
        WHEN UsageFrequency >= 5  AND LastInteraction <= 22 THEN 'Passively Engaged'
        ELSE 'Disengaged'
    END                                               AS engagement_tier,
    COUNT(*)                                          AS total,
    SUM(Churn)                                        AS churned,
    ROUND(SUM(Churn) * 100.0 / COUNT(*), 2)          AS churn_rate_pct,
    ROUND(AVG(TotalSpend), 2)                         AS avg_spend
FROM investors
GROUP BY engagement_tier
ORDER BY churn_rate_pct DESC;


-- ────────────────────────────────────────────────────────────
--  SECTION 8 : EXECUTIVE SUMMARY VIEW (for Power BI)
-- ────────────────────────────────────────────────────────────

CREATE OR REPLACE VIEW vw_investor_summary AS
SELECT
    CustomerID,
    Age,
    Gender,
    Tenure,
    UsageFrequency,
    SupportCalls,
    PaymentDelay,
    SubscriptionType,
    ContractLength,
    TotalSpend,
    LastInteraction,
    Churn,
    CASE WHEN Churn = 1 THEN 'Churned' ELSE 'Active' END AS ChurnStatus,
    CASE
        WHEN Age BETWEEN 18 AND 25 THEN '18-25'
        WHEN Age BETWEEN 26 AND 35 THEN '26-35'
        WHEN Age BETWEEN 36 AND 45 THEN '36-45'
        WHEN Age BETWEEN 46 AND 55 THEN '46-55'
        ELSE '56-65'
    END AS AgeGroup,
    CASE
        WHEN Tenure BETWEEN 0  AND 12 THEN '0-12 months'
        WHEN Tenure BETWEEN 13 AND 24 THEN '13-24 months'
        WHEN Tenure BETWEEN 25 AND 36 THEN '25-36 months'
        WHEN Tenure BETWEEN 37 AND 48 THEN '37-48 months'
        ELSE '49-60 months'
    END AS TenureBand,
    CASE
        WHEN UsageFrequency >= 20 AND LastInteraction <= 7  THEN 'Highly Engaged'
        WHEN UsageFrequency >= 10 AND LastInteraction <= 15 THEN 'Moderately Engaged'
        WHEN UsageFrequency >= 5  AND LastInteraction <= 22 THEN 'Passively Engaged'
        ELSE 'Disengaged'
    END AS EngagementTier,
    CASE
        WHEN PaymentDelay = 0       THEN 'No Delay'
        WHEN PaymentDelay <= 10     THEN '1-10 Days'
        WHEN PaymentDelay <= 20     THEN '11-20 Days'
        ELSE '21+ Days'
    END AS PaymentDelayBand,
    (SupportCalls * 2 + PaymentDelay + LastInteraction - UsageFrequency) AS RiskScore
FROM investors;

-- Export this view to CSV for Power BI
-- SELECT * FROM vw_investor_summary;
