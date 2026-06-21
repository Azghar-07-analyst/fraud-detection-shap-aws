
-- creating database ---
CREATE DATABASE IF NOT EXISTS fraud_detection;
USE fraud_detection;

-- Query 1: Overall fraud statistics
SELECT 
	COUNT(*) AS total_transactions,
    SUM(Class) AS fraud_count,
    COUNT(*) -  SUM(Class) AS legit_count,
    ROUND(SUM(Class) * 100.0 / COUNT(*), 3) AS fraud_percentage
FROM transactions;
    
-- Query 2: Avg amount — fraud vs legitimate
SELECT 
	CASE WHEN Class = 1 THEN 'Fraud' ELSE 'Legitimate' END AS transaction_type,
		COUNT(*) AS count,
		ROUND(AVG(Amount), 2) AS avg_amount,
		ROUND(MAX(Amount), 2) AS max_amount,
		ROUND(MIN(Amount), 2) AS min_amount
FROM transactions
GROUP BY Class;

-- Query 3: Fraud rate by hour of day
SELECT 
    FLOOR(MOD(Time / 3600, 24)) AS hour_of_day,
    COUNT(*) AS total_txn,
    SUM(Class) AS fraud_count,
    ROUND(SUM(Class) * 100.0 / COUNT(*), 4) AS fraud_rate_pct
FROM transactions
GROUP BY hour_of_day
ORDER BY fraud_rate_pct DESC
LIMIT 10;

-- Query 4: Transaction amount buckets vs fraud rate
SELECT 
    CASE 
        WHEN Amount < 10   THEN 'Micro (<10)'
        WHEN Amount < 100  THEN 'Small (10-100)'
        WHEN Amount < 500  THEN 'Medium (100-500)'
        WHEN Amount < 1000 THEN 'Large (500-1000)'
        ELSE 'Very Large (1000+)'
    END AS amount_tier,
    COUNT(*) AS total,
    SUM(Class) AS fraud_count,
    ROUND(SUM(Class) * 100.0 / COUNT(*), 3) AS fraud_rate_pct
FROM transactions
GROUP BY amount_tier
ORDER BY fraud_rate_pct DESC;

-- Query 5: Top 10 highest-value fraud transactions
SELECT 
    ROUND(Amount, 2) AS amount,
    FLOOR(MOD(Time / 3600, 24)) AS hour,
    Class
FROM transactions
WHERE Class = 1
ORDER BY Amount DESC
LIMIT 10;

-- Query 6: Window function — running fraud rate over time
SELECT 
    FLOOR(Time / 3600) AS hour_bucket,
    SUM(Class) AS fraud_in_hour,
    COUNT(*) AS total_in_hour,
    ROUND(SUM(SUM(Class)) OVER (ORDER BY FLOOR(Time/3600)) / 
          SUM(COUNT(*)) OVER (ORDER BY FLOOR(Time/3600)) * 100, 4) 
          AS cumulative_fraud_rate
FROM transactions
GROUP BY hour_bucket
ORDER BY hour_bucket
LIMIT 20;